/// main.dart
/// Application entry point for Diggle.
///
/// Navigation flow:
///   Main Menu → New Game → Save Slots (new) → Game
///   Main Menu → Continue → loads most recent save → Game
///   Main Menu → Load Game → Save Slots (load) → Game
///   Main Menu → Account → Profile/wallet/stats
///   Main Menu → Settings → Language selector
///   Game → Pause → Main Menu (saves first)
///
/// Services initialized:
///   - SupabaseService (cloud persistence)
///   - WalletService (Solana wallet connection)
///   - CandyMachineService (NFT minting via Candy Machine)
///   - StatsService, WorldSaveService, PlayerService, PointsLedgerService
///   - GameLifecycleManager (orchestrates bootstrap + save/load)
///   - LocaleProvider (language selection with persistence)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';

import 'game/diggle_game.dart';
import 'game/systems/boost_manager.dart';
import 'l10n/app_localizations.dart';
import 'services/game_lifecycle_manager.dart';
import 'services/locale_provider.dart';
import 'services/player_service.dart';
import 'services/points_ledger_service.dart';
import 'services/stats_service.dart';
import 'services/supabase_service.dart';
import 'services/world_save_service.dart';
import 'solana/wallet_service.dart';
import 'solana/candy_machine_service.dart';
import 'services/update_service.dart';
import 'ui/update_dialog.dart';
import 'ui/main_menu.dart';
import 'ui/save_slots_screen.dart';
import 'ui/account_screen.dart';
import 'ui/settings_screen.dart';
import 'ui/premium_store_overlay.dart';
import 'ui/xp_hud_widget.dart';
import 'ui/hud_overlay.dart';
import 'ui/shop_overlay.dart';
import 'ui/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Fullscreen mode
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [],
  );

  // ── Initialize Supabase ──────────────────────────────────────
  try {
    await SupabaseService.instance.initialize();
    debugPrint('Supabase initialized');
  } catch (e) {
    debugPrint('Supabase init failed (game will work offline): $e');
  }

  // Initialize wallet service
  final walletService = WalletService();
  await walletService.initialize();

  // ── Initialize Candy Machine Service ─────────────────────────
  final candyMachineService = CandyMachineService(
    wallet: walletService,
    supabaseUrl: 'https://vdcpbqsnkivokroqxelq.supabase.co',
    supabaseAnonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'sb_publishable_3Lt47dggCSWufo6kLq6fzg_B7yvx0Lm',
    ),
  );

  // ── Create Backend Services ──────────────────────────────────
  final statsService = StatsService();
  final worldSaveService = WorldSaveService();
  final playerService = PlayerService();
  final pointsLedgerService = PointsLedgerService();

  // ── Create Lifecycle Manager ─────────────────────────────────
  final lifecycleManager = GameLifecycleManager(
    walletService: walletService,
    statsService: statsService,
    worldSaveService: worldSaveService,
    playerService: playerService,
  );

  // ── Initialize Locale Provider ───────────────────────────────
  final localeProvider = LocaleProvider();
  await localeProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: walletService),
        ChangeNotifierProvider.value(value: candyMachineService),
        ChangeNotifierProvider.value(value: localeProvider),
        Provider.value(value: statsService),
        Provider.value(value: worldSaveService),
        Provider.value(value: playerService),
        Provider.value(value: pointsLedgerService),
        Provider.value(value: lifecycleManager),
      ],
      child: const DiggleApp(),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
// App Widget
// ═══════════════════════════════════════════════════════════════════

class DiggleApp extends StatelessWidget {
  const DiggleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'Diggle',
      debugShowCheckedModeBanner: false,

      // ── Localization ───────────────────────────────────────────
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AppNavigator(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// App Navigator — manages all screen transitions
// ═══════════════════════════════════════════════════════════════════

enum AppScreen { auth, mainMenu, game }

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator>
    with WidgetsBindingObserver {
  /// Start at auth if no session, main menu if already authenticated
  late AppScreen _screen;
  bool _bootstrapping = false;

  /// Current game config (set when starting/loading a game)
  int? _gameSeed;
  int? _gameSlot;
  bool _isNewGame = true;

  /// Whether saves exist (checked on menu load)
  bool _hasSaves = false;

  /// Most recent save slot + seed (for Continue)
  int? _mostRecentSlot;
  int? _mostRecentSeed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Determine starting screen based on auth state
    if (SupabaseService.instance.isAuthenticated) {
      _screen = AppScreen.mainMenu;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _runBootstrap();
        _checkForSaves();
        _checkForUpdate();
      });
    } else {
      _screen = AppScreen.auth;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final lifecycle = context.read<GameLifecycleManager>();
      lifecycle.onAppBackground();
    }
  }

  Future<void> _checkForUpdate() async {
    // Temporarily override in _checkForUpdate():
    /* final status = UpdateStatus(
      action: UpdateAction.optional,  // or .forced
      currentVersion: '0.1.0',
      latestVersion: '0.2.0',
      message: 'Test update message',
      dappStoreId: 'com.example.diggle',
    );
    UpdateDialog.show(context, status);
*/
    final status = await UpdateService.instance.checkForUpdate();
    if (status.needsUpdate && mounted) {
      UpdateDialog.show(context, status);
    }
  }

  // ── Save Detection ─────────────────────────────────────────────

  Future<void> _checkForSaves() async {
    try {
      final lifecycle = context.read<GameLifecycleManager>();
      final summaries = await lifecycle.getSaveSummaries();
      if (!mounted) return;

      if (summaries.isNotEmpty) {
        summaries.sort((a, b) => b.savedAt.compareTo(a.savedAt));
        final mostRecent = summaries.first;

        setState(() {
          _hasSaves = true;
          _mostRecentSlot = mostRecent.slot;
          _mostRecentSeed = mostRecent.seed;
        });
      } else {
        setState(() {
          _hasSaves = false;
          _mostRecentSlot = null;
          _mostRecentSeed = null;
        });
      }
    } catch (e) {
      debugPrint('AppNavigator: error checking saves: $e');
      setState(() => _hasSaves = false);
    }
  }

  // ── Navigation Actions ─────────────────────────────────────────

  Future<void> _runBootstrap() async {
    if (_bootstrapping) return;
    _bootstrapping = true;
    try {
      final lifecycle = context.read<GameLifecycleManager>();
      await lifecycle.bootstrap();
    } catch (e) {
      debugPrint('AppNavigator: bootstrap error: $e');
    } finally {
      _bootstrapping = false;
    }
  }

  void _onAuthenticated() {
    setState(() => _screen = AppScreen.mainMenu);
    _runBootstrap();
    _checkForSaves();
    _checkForUpdate();
  }

  void _onNewGame() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SaveSlotsScreen(
          mode: SaveSlotMode.newGame,
          onSlotSelected: (slot, seed) {
            Navigator.of(context).pop();
            _startGame(slot: slot, seed: seed, isNewGame: true);
          },
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _onContinue() {
    if (_mostRecentSlot != null && _mostRecentSeed != null) {
      _startGame(slot: _mostRecentSlot!, seed: _mostRecentSeed, isNewGame: false);
    }
  }

  void _onLoadGame() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SaveSlotsScreen(
          mode: SaveSlotMode.loadGame,
          onSlotSelected: (slot, seed) {
            Navigator.of(context).pop();
            _startGame(slot: slot, seed: seed, isNewGame: false);
          },
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _onAccount() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AccountScreen(
          onBack: () => Navigator.of(context).pop(),
          onSignOut: () {
            Navigator.of(context).pop();
            _signOut();
          },
        ),
      ),
    );
  }

  /// Open Settings screen
  void _onSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      final lifecycle = context.read<GameLifecycleManager>();
      lifecycle.reset();
      await SupabaseService.instance.signOut();
    } catch (e) {
      debugPrint('AppNavigator: sign out error: $e');
    }
    if (mounted) {
      setState(() {
        _screen = AppScreen.auth;
        _hasSaves = false;
        _mostRecentSlot = null;
        _mostRecentSeed = null;
        _gameSeed = null;
        _gameSlot = null;
        _isNewGame = true;
      });
    }
  }

  void _startGame({required int slot, int? seed, bool isNewGame = true}) {
    setState(() {
      _gameSeed = seed ?? (DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF);
      _gameSlot = slot;
      _isNewGame = isNewGame;
      _screen = AppScreen.game;
    });
  }

  void _returnToMenu() {
    setState(() {
      _screen = AppScreen.mainMenu;
      _gameSeed = null;
      _gameSlot = null;
      _isNewGame = true;
    });
    _checkForSaves();
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    switch (_screen) {
      case AppScreen.auth:
        return AuthScreen(onAuthenticated: _onAuthenticated);

      case AppScreen.mainMenu:
        return MainMenu(
          onNewGame: _onNewGame,
          onLoadGame: _onLoadGame,
          onContinue: _onContinue,
          onAccount: _onAccount,
          onSettings: _onSettings,
          hasSaves: _hasSaves,
        );

      case AppScreen.game:
        return GameScreen(
          seed: _gameSeed ?? (DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF),
          slot: _gameSlot,
          isNewGame: _isNewGame,
          onReturnToMenu: _returnToMenu,
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// GameScreen — owns DiggleGame + BoostManager lifecycle
// ═══════════════════════════════════════════════════════════════════

class GameScreen extends StatefulWidget {
  final int seed;
  final int? slot;
  final bool isNewGame;
  final VoidCallback onReturnToMenu;

  const GameScreen({
    super.key,
    required this.seed,
    this.slot,
    this.isNewGame = true,
    required this.onReturnToMenu,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final DiggleGame _game;
  late final BoostManager _boostManager;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _game = DiggleGame(seed: widget.seed);

    final walletService = context.read<WalletService>();
    final candyMachineService = context.read<CandyMachineService>();

    _boostManager = BoostManager(
      xpSystem: _game.xpPointsSystem,
      walletService: walletService,
      candyMachineService: candyMachineService,
    );
    _game.boostManager = _boostManager;

    _game.attachServices(context);

    try {
      final statsService = context.read<StatsService>();
      statsService.startPeriodicSync();
    } catch (e) {
      debugPrint('GameScreen: periodic sync start error: $e');
    }

    if (!widget.isNewGame && widget.slot != null) {
      _loadSavedGame();
    }
  }

  Future<void> _loadSavedGame() async {
    setState(() => _isLoading = true);
    try {
      final lifecycle = context.read<GameLifecycleManager>();
      final save = await lifecycle.loadWorld(slot: widget.slot!);

      if (save != null) {
        if (save.worldData != null && save.worldData!.isNotEmpty) {
          _game.importTileMapBytes(save.worldData!);
        }
        if (save.gameSystems != null) {
          _game.importGameSystems(save.gameSystems!);
        }
        if (save.playerPosition != null) {
          _game.drill.restorePosition(
              save.playerPosition!['x'] ?? 0, save.playerPosition!['y'] ?? 0);
        }
        debugPrint(
            'GameScreen: restored save from slot ${widget.slot} , pos: ${save.playerPosition!['x']} '
                '(depth: ${save.depthReached}, seed: ${save.seed})');
      } else {
        debugPrint('GameScreen: no save found for slot ${widget.slot}');
      }
    } catch (e) {
      debugPrint('GameScreen: error loading save: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    try {
      final statsService = context.read<StatsService>();
      statsService.syncToServer();
      statsService.stopPeriodicSync();
    } catch (_) {}

    _boostManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          'hud': (context, game) => HudOverlay(game: game as DiggleGame),
          'shop': (context, game) => ShopOverlay(game: game as DiggleGame),
          'premiumStore': (context, game) {
            final g = game as DiggleGame;
            return PremiumStoreOverlay(
              game: g,
              xpSystem: g.xpPointsSystem,
              boostManager: _boostManager,
              candyMachineService: context.read<CandyMachineService>(),
            );
          },
          'xpHud': (context, game) {
            final g = game as DiggleGame;
            return XPHudWidget(
              xpSystem: g.xpPointsSystem,
              boostManager: _boostManager,
              onTapStore: () => g.overlays.add('premiumStore'),
            );
          },
          'gameOver': (context, game) =>
              _buildGameOverOverlay(context, game as DiggleGame),
          'pause': (context, game) =>
              _buildPauseOverlay(context, game as DiggleGame),
        },
        loadingBuilder: (context) => _buildLoadingScreen(context),
        errorBuilder: (context, error) => _buildErrorScreen(context, error),
        backgroundBuilder: (context) =>
            Container(color: const Color(0xFF1a1a2e)),
      ),
    );
  }

  // ── Pause Overlay ──────────────────────────────────────────────

  Widget _buildPauseOverlay(BuildContext context, DiggleGame game) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.paused,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 32),

              // Resume
              ElevatedButton.icon(
                onPressed: () {
                  game.overlays.remove('pause');
                  game.resume();
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.resume),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  minimumSize: const Size(200, 50),
                ),
              ),
              const SizedBox(height: 16),

              // Save Game
              if (widget.slot != null) ...[
                ElevatedButton.icon(
                  onPressed: () async {
                    final lifecycle = context.read<GameLifecycleManager>();
                    await lifecycle.saveWorld(
                      slot: widget.slot!,
                      seed: widget.seed,
                      tileMapBytes: game.exportTileMapBytes(),
                      gameSystems: game.exportGameSystems(),
                      playerPosition: {
                        'x': game.drill.position.x,
                        'y': game.drill.position.y,
                      },
                      depthReached: game.drill.depth,
                      playtimeSeconds: game.playtimeSeconds,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.savedToSlot(widget.slot! + 1)),
                          backgroundColor: Colors.green.shade800,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: Text(l10n.saveGame),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    minimumSize: const Size(200, 50),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Restart
              ElevatedButton(
                onPressed: () => game.restart(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  minimumSize: const Size(200, 50),
                ),
                child: Text(l10n.restart),
              ),
              const SizedBox(height: 16),

              // Main Menu
              ElevatedButton(
                onPressed: () {
                  if (widget.slot != null) {
                    final lifecycle = context.read<GameLifecycleManager>();
                    lifecycle.saveWorld(
                      slot: widget.slot!,
                      seed: widget.seed,
                      tileMapBytes: game.exportTileMapBytes(),
                      gameSystems: game.exportGameSystems(),
                      playerPosition: {
                        'x': game.drill.position.x,
                        'y': game.drill.position.y,
                      },
                      depthReached: game.drill.depth,
                      playtimeSeconds: game.playtimeSeconds,
                    );
                  }
                  game.resume();
                  widget.onReturnToMenu();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  minimumSize: const Size(200, 50),
                ),
                child: Text(l10n.mainMenu),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Game Over Overlay ──────────────────────────────────────────

  Widget _buildGameOverOverlay(BuildContext context, DiggleGame game) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Colors.black.withOpacity(0.9),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                l10n.gameOver,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.depthReached(game.drill.depth),
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: () => game.restart(),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.tryAgain),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  minimumSize: const Size(200, 50),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: widget.onReturnToMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  minimumSize: const Size(200, 50),
                ),
                child: Text(l10n.mainMenu),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Loading / Error Screens ────────────────────────────────────

  Widget _buildLoadingScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: const Color(0xFF1a1a2e),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.amber),
            const SizedBox(height: 20),
            Text(
              l10n.loadingDiggle,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, Object error) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: const Color(0xFF1a1a2e),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              l10n.failedToLoadGame(error.toString()),
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.onReturnToMenu,
              child: Text(l10n.backToMenu),
            ),
          ],
        ),
      ),
    );
  }
}