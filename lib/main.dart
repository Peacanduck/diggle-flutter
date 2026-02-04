/// main.dart
/// Application entry point for Diggle.
///
/// This file:
/// - Initializes Flutter binding
/// - Creates the game instance
/// - Registers all overlays
/// - Sets up the GameWidget
/// - Initializes optional Solana wallet service
/// - Shows main menu first

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';

import 'game/diggle_game.dart';
import 'ui/hud_overlay.dart';
import 'ui/shop_overlay.dart';
import 'ui/main_menu.dart';
import 'solana/wallet_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode for consistent gameplay
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set fullscreen mode
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [],
  );

  // Initialize wallet service
  final walletService = WalletService();
  await walletService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: walletService),
      ],
      child: const DiggleApp(),
    ),
  );
}

/// Main application widget
class DiggleApp extends StatelessWidget {
  const DiggleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diggle',
      debugShowCheckedModeBanner: false,
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

/// Handles navigation between main menu and game
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  bool _showGame = false;

  void _startGame() {
    setState(() {
      _showGame = true;
    });
  }

  void _returnToMenu() {
    setState(() {
      _showGame = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showGame) {
      return GameScreen(onReturnToMenu: _returnToMenu);
    } else {
      return MainMenu(onStartGame: _startGame);
    }
  }
}

/// Main game screen that hosts the Flame game
class GameScreen extends StatefulWidget {
  final VoidCallback onReturnToMenu;

  const GameScreen({super.key, required this.onReturnToMenu});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  /// The game instance
  late final DiggleGame _game;

  @override
  void initState() {
    super.initState();

    // Create game with random seed (could use DateTime for daily challenges)
    _game = DiggleGame(
      seed: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,

        overlayBuilderMap: {
          // HUD overlay - always visible during gameplay
          'hud': (context, game) => HudOverlay(game: game as DiggleGame),

          // Shop overlay - shown when player accesses shop at surface
          'shop': (context, game) => ShopOverlay(game: game as DiggleGame),

          // Game Over overlay - shown when fuel depletes underground
          'gameOver': (context, game) => GameOverOverlay(
            game: game as DiggleGame,
            onReturnToMenu: widget.onReturnToMenu,
          ),

          // Pause overlay - for pause menu
          'pause': (context, game) => _buildPauseOverlay(game as DiggleGame),

          // Settings overlay - for wallet connection, etc.
          'settings': (context, game) => _buildSettingsOverlay(game as DiggleGame),
        },

        // Loading screen while game initializes
        loadingBuilder: (context) => Container(
          color: const Color(0xFF1a1a2e),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.amber),
                SizedBox(height: 20),
                Text(
                  'Loading Diggle...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),

        // Error screen if game fails to load
        errorBuilder: (context, error) => Container(
          color: const Color(0xFF1a1a2e),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to load game:\n$error',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: widget.onReturnToMenu,
                  child: const Text('Return to Menu'),
                ),
              ],
            ),
          ),
        ),

        // Background color while loading
        backgroundBuilder: (context) => Container(
          color: const Color(0xFF1a1a2e),
        ),
      ),
    );
  }

  /// Pause menu overlay
  Widget _buildPauseOverlay(DiggleGame game) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => game.resume(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(200, 50),
              ),
              child: const Text('RESUME'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                game.overlays.add('settings');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
              child: const Text('SETTINGS'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => game.restart(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                minimumSize: const Size(200, 50),
              ),
              child: const Text('RESTART'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                game.resume();
                widget.onReturnToMenu();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                minimumSize: const Size(200, 50),
              ),
              child: const Text('MAIN MENU'),
            ),
          ],
        ),
      ),
    );
  }

  /// Settings overlay (includes wallet connection)
  Widget _buildSettingsOverlay(DiggleGame game) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => game.overlays.remove('settings'),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white24),

            // Wallet section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _WalletSettingsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wallet settings section widget with cluster selector
class _WalletSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WalletService>(
      builder: (context, wallet, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.purple),
                  SizedBox(width: 8),
                  Text(
                    'Solana Wallet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Connect a wallet for future features like NFT cosmetics and on-chain leaderboards.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Cluster Selector
              _buildClusterSelector(context, wallet),

              const Divider(color: Colors.white24, height: 32),

              // Connection status
              if (!wallet.isAvailable)
                const Text(
                  'No Solana wallet app installed',
                  style: TextStyle(color: Colors.orange),
                )
              else if (wallet.isConnected)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Connected to ${wallet.cluster.displayName}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wallet.shortPublicKey ?? '',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => wallet.disconnect(),
                        child: const Text('Disconnect'),
                      ),
                    ),
                  ],
                )
              else if (wallet.isConnecting)
                  const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Connecting...',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (wallet.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            wallet.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => wallet.connect(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                          child: Text('Connect to ${wallet.cluster.displayName}'),
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClusterSelector(BuildContext context, WalletService wallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Network',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ClusterOption(
                cluster: SolanaCluster.devnet,
                isSelected: wallet.isDevnet,
                isEnabled: !wallet.isConnecting,
                onTap: () => wallet.setCluster(SolanaCluster.devnet),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ClusterOption(
                cluster: SolanaCluster.mainnet,
                isSelected: wallet.isMainnet,
                isEnabled: !wallet.isConnecting,
                onTap: () => wallet.setCluster(SolanaCluster.mainnet),
              ),
            ),
          ],
        ),
        if (wallet.isConnected)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Switching networks will disconnect your wallet',
              style: TextStyle(
                color: Colors.orange.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}

/// Cluster option button widget
class _ClusterOption extends StatelessWidget {
  final SolanaCluster cluster;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  const _ClusterOption({
    required this.cluster,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = cluster == SolanaCluster.devnet ? Colors.orange : Colors.green;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              cluster == SolanaCluster.devnet
                  ? Icons.bug_report
                  : Icons.public,
              color: isSelected ? color : Colors.white54,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              cluster.displayName,
              style: TextStyle(
                color: isSelected ? color : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              cluster == SolanaCluster.devnet ? 'Testing' : 'Production',
              style: TextStyle(
                color: (isSelected ? color : Colors.white54).withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Updated Game Over overlay with return to menu option
class GameOverOverlay extends StatelessWidget {
  final DiggleGame game;
  final VoidCallback onReturnToMenu;

  const GameOverOverlay({
    super.key,
    required this.game,
    required this.onReturnToMenu,
  });

  @override
  Widget build(BuildContext context) {
    final hull = game.hullSystem;
    final fuel = game.fuelSystem;

    String deathReason = 'You were destroyed!';
    if (hull.isDestroyed) {
      deathReason = 'Hull destroyed!';
    } else if (fuel.isEmpty) {
      deathReason = 'You ran out of fuel!';
    }

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            const Text(
              'GAME OVER',
              style: TextStyle(color: Colors.red, fontSize: 42, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              deathReason,
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 24),
            Text('Max Depth: ${game.economySystem.maxDepthReached}m',
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text('Ore Collected: ${game.economySystem.totalOreCollected}',
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text('Cash Earned: \$${game.economySystem.totalCashEarned}',
                style: const TextStyle(color: Colors.amber, fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => game.restart(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                minimumSize: const Size(200, 50),
              ),
              child: const Text('TRY AGAIN',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onReturnToMenu,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                minimumSize: const Size(200, 50),
              ),
              child: const Text('MAIN MENU',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

/*/// main.dart
/// Application entry point for Diggle.
///
/// This file:
/// - Initializes Flutter binding
/// - Creates the game instance
/// - Registers all overlays
/// - Sets up the GameWidget
/// - Initializes optional Solana wallet service
/// - Shows main menu first

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';

import 'game/diggle_game.dart';
import 'ui/hud_overlay.dart';
import 'ui/shop_overlay.dart';
import 'ui/main_menu.dart';
import 'solana/wallet_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode for consistent gameplay
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set fullscreen mode
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [],
  );

  // Initialize wallet service
  final walletService = WalletService();
  await walletService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: walletService),
      ],
      child: const DiggleApp(),
    ),
  );
}

/// Main application widget
class DiggleApp extends StatelessWidget {
  const DiggleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diggle',
      debugShowCheckedModeBanner: false,
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

/// Handles navigation between main menu and game
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  bool _showGame = false;

  void _startGame() {
    setState(() {
      _showGame = true;
    });
  }

  void _returnToMenu() {
    setState(() {
      _showGame = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showGame) {
      return GameScreen(onReturnToMenu: _returnToMenu);
    } else {
      return MainMenu(onStartGame: _startGame);
    }
  }
}

/// Main game screen that hosts the Flame game
class GameScreen extends StatefulWidget {
  final VoidCallback onReturnToMenu;

  const GameScreen({super.key, required this.onReturnToMenu});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  /// The game instance
  late final DiggleGame _game;

  @override
  void initState() {
    super.initState();

    // Create game with random seed (could use DateTime for daily challenges)
    _game = DiggleGame(
      seed: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,

        // ========================================
        // OVERLAY BUILDER
        // ========================================
        // Overlays are Flutter widgets that render on top of the game.
        // They're defined here and activated/deactivated by the game
        // using overlays.add('name') and overlays.remove('name').
        //
        // Each overlay receives the game instance so it can:
        // - Read game state
        // - Call game methods
        // - Listen to changes

        overlayBuilderMap: {
          // HUD overlay - always visible during gameplay
          'hud': (context, game) => HudOverlay(game: game as DiggleGame),

          // Shop overlay - shown when player accesses shop at surface
          'shop': (context, game) => ShopOverlay(game: game as DiggleGame),

          // Game Over overlay - shown when fuel depletes underground
          'gameOver': (context, game) => GameOverOverlay(
            game: game as DiggleGame,
            onReturnToMenu: widget.onReturnToMenu,
          ),

          // Pause overlay - for pause menu
          'pause': (context, game) => _buildPauseOverlay(game as DiggleGame),

          // Settings overlay - for wallet connection, etc.
          'settings': (context, game) => _buildSettingsOverlay(game as DiggleGame),
        },

        // Loading screen while game initializes
        loadingBuilder: (context) => Container(
          color: const Color(0xFF1a1a2e),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.amber),
                SizedBox(height: 20),
                Text(
                  'Loading Diggle...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),

        // Error screen if game fails to load
        errorBuilder: (context, error) => Container(
          color: const Color(0xFF1a1a2e),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to load game:\n$error',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: widget.onReturnToMenu,
                  child: const Text('Return to Menu'),
                ),
              ],
            ),
          ),
        ),

        // Background color while loading
        backgroundBuilder: (context) => Container(
          color: const Color(0xFF1a1a2e),
        ),
      ),
    );
  }

  /// Pause menu overlay
  Widget _buildPauseOverlay(DiggleGame game) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => game.resume(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(200, 50),
              ),
              child: const Text('RESUME'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                game.overlays.add('settings');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
              child: const Text('SETTINGS'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => game.restart(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                minimumSize: const Size(200, 50),
              ),
              child: const Text('RESTART'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                game.resume();
                widget.onReturnToMenu();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                minimumSize: const Size(200, 50),
              ),
              child: const Text('MAIN MENU'),
            ),
          ],
        ),
      ),
    );
  }

  /// Settings overlay (includes wallet connection)
  Widget _buildSettingsOverlay(DiggleGame game) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => game.overlays.remove('settings'),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white24),

            // Wallet section
            Padding(
              padding: const EdgeInsets.all(16),
              child: _WalletSettingsSection(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wallet settings section widget
class _WalletSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WalletService>(
      builder: (context, wallet, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.purple),
                  SizedBox(width: 8),
                  Text(
                    'Solana Wallet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Connect a wallet for future features like NFT cosmetics and on-chain leaderboards.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Connection status
              if (!wallet.isAvailable)
                const Text(
                  'No Solana wallet app installed',
                  style: TextStyle(color: Colors.orange),
                )
              else if (wallet.isConnected)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          wallet.walletName ?? 'Connected',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wallet.shortPublicKey ?? '',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => wallet.disconnect(),
                        child: const Text('Disconnect'),
                      ),
                    ),
                  ],
                )
              else if (wallet.isConnecting)
                  const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Connecting...',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (wallet.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            wallet.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => wallet.connect(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                          child: const Text('Connect Wallet'),
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        );
      },
    );
  }
}

/// Updated Game Over overlay with return to menu option
class GameOverOverlay extends StatelessWidget {
  final DiggleGame game;
  final VoidCallback onReturnToMenu;

  const GameOverOverlay({
    super.key,
    required this.game,
    required this.onReturnToMenu,
  });

  @override
  Widget build(BuildContext context) {
    final hull = game.hullSystem;
    final fuel = game.fuelSystem;

    String deathReason = 'You were destroyed!';
    if (hull.isDestroyed) {
      deathReason = 'Hull destroyed!';
    } else if (fuel.isEmpty) {
      deathReason = 'You ran out of fuel!';
    }

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            const Text(
              'GAME OVER',
              style: TextStyle(color: Colors.red, fontSize: 42, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              deathReason,
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 24),
            Text('Max Depth: ${game.economySystem.maxDepthReached}m',
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text('Ore Collected: ${game.economySystem.totalOreCollected}',
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text('Cash Earned: \$${game.economySystem.totalCashEarned}',
                style: const TextStyle(color: Colors.amber, fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => game.restart(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                minimumSize: const Size(200, 50),
              ),
              child: const Text('TRY AGAIN',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onReturnToMenu,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                minimumSize: const Size(200, 50),
              ),
              child: const Text('MAIN MENU',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}*/