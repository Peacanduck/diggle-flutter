/// diggle_game.dart
/// Main Flame game class for Diggle.

import 'dart:typed_data';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/stats_service.dart';
import '../services/supabase_service.dart';
import '../services/xp_stats_bridge.dart';
import '../services/game_lifecycle_manager.dart';
import '../services/quest_sync_service.dart';

import 'world/tile.dart';
import 'world/tile_map_component.dart';
import 'world/world_generator.dart';
import 'player/drill_component.dart';
import 'effects/heat_shield_aura.dart';
import 'effects/screen_vfx.dart';
import 'effects/shake_world.dart';
import 'effects/vfx_layer.dart';
import 'systems/vfx_queue.dart';
import 'systems/fuel_system.dart';
import 'systems/economy_system.dart';
import 'systems/hull_system.dart';
import 'systems/item_system.dart';
import 'systems/drillbit_system.dart';
import 'systems/engine_system.dart';
import 'systems/cooling_system.dart';
import 'systems/xp_points_system.dart';
import 'systems/boost_manager.dart';
import 'systems/light_system.dart';
import 'systems/quest_system.dart';
import 'systems/collection_system.dart';
import 'systems/achievement_system.dart';
import 'systems/streak_system.dart';
import 'systems/level_rewards.dart';
import 'systems/prestige_system.dart';
import 'systems/gear_system.dart';

enum GameState { playing, shopping, gameOver, paused }

class DiggleGame extends FlameGame<ShakeWorld> with HasCollisionDetection {
  late TileMapComponent tileMap;
  late DrillComponent drill;

  /// Cosmetic effect requests. Game logic emits, [vfxLayer] drains once per
  /// frame. Deliberately not a ChangeNotifier and deliberately Flame-free —
  /// see vfx_queue.dart.
  final VfxQueue vfx = VfxQueue();

  /// World-space particles (priority 10, above tile map and drill).
  late VfxLayer vfxLayer;

  /// Screen-space tints. Lives in `camera.viewport`, so it neither moves
  /// with the camera nor picks up the world's shake transform.
  late ScreenVfx screenVfx;

  // Joystick Control
  //late final JoystickComponent joystick;

  // Core systems
  late FuelSystem fuelSystem;
  late EconomySystem economySystem;
  late HullSystem hullSystem;
  late ItemSystem itemSystem;

  late DrillbitSystem drillbitSystem;
  late EngineSystem engineSystem;
  late CoolingSystem coolingSystem;
  late LightSystem lightSystem;
  late QuestSystem questSystem;
  late CollectionSystem collectionSystem;
  late AchievementSystem achievementSystem;
  late StreakSystem streakSystem;

  /// Builds the localized "Title unlocked" announcement for a
  /// [LevelTitles] id. Set by the UI layer, which owns the context.
  String Function(String titleId)? formatTitleUnlocked;
  late GearSystem gearSystem;

  late XPPointsSystem xpPointsSystem;

  // BoostManager is initialized in main.dart since it needs WalletService
  BoostManager? boostManager;

  GameState _state = GameState.playing;
  final WorldConfig worldConfig;
  final int seed;

  /// Prestige meta-progression (global). Null = no prestige attached.
  final PrestigeSystem? prestigeSystem;

  /// Whether this run gets the prestige starter kit (new games only).
  final bool isNewGame;

  /// Weekly challenge mode: standardized loadout — no prestige perks,
  /// no hardcore seams; everyone digs the same world on equal terms.
  final bool challengeMode;

  //Stats bridge for Supabase persistence
  XPStatsBridge? statsBridge;

  //Play time tracking
  double _playTimeAccumulator = 0;
  int _totalPlaytimeSeconds = 0;

  /// Total accumulated play time in seconds for this session
  int get playtimeSeconds => _totalPlaytimeSeconds;

  DiggleGame({
    this.seed = 42,
    WorldConfig? config,
    this.prestigeSystem,
    GearSystem? gearSystem,
    StreakSystem? streakSystem,
    this.isNewGame = true,
    this.challengeMode = false,
  }) : worldConfig = config ?? WorldConfig(
    width: 64,
    height: 524,
    surfaceRows: 30,
    seed: seed,
    // Hardcore seams scale with prestige — but never in challenge mode
    // (identical world for every player).
    oreRichness: challengeMode ? 1.0 : (prestigeSystem?.oreRichness ?? 1.0),
    hazardIntensity:
        challengeMode ? 1.0 : (prestigeSystem?.hazardIntensity ?? 1.0),
  ), super(world: ShakeWorld()){
    xpPointsSystem = XPPointsSystem();
    lightSystem = LightSystem();
    questSystem = QuestSystem();
    collectionSystem = CollectionSystem();
    achievementSystem = AchievementSystem();
    // Gear and streak are global meta-state (shared with the Hangar and
    // Account screens); fall back to a local instance for tests/standalone.
    this.gearSystem = gearSystem ?? GearSystem();
    this.streakSystem = streakSystem ?? StreakSystem();
  }


  /// Call this from GameScreen.initState after game is created
  /// and BuildContext is available.
  void attachServices(BuildContext context) {
    final statsService = context.read<StatsService>();

    // Create the bridge
    statsBridge = XPStatsBridge(
      xpSystem: xpPointsSystem,
      statsService: statsService,
    );

    // Attach bridge to boost manager if it exists
    boostManager?.attachStatsBridge(statsBridge!);

    // Restore server state to local XP system
    final stats = statsService.stats;
    if (stats.xp > 0 || stats.points > 0) {
      xpPointsSystem.restoreFromServer(
        xp: stats.xp,
        points: stats.points,
        level: stats.level,
      );
    }

    // ── NEW: Attach quest sync if player is authenticated ──
    final playerId = SupabaseService.instance.playerId;  // adjust getter name to match your StatsService
    if (playerId != null && SupabaseService.instance.isAuthenticated) {
      final syncService = QuestSyncService(
        client: SupabaseService.instance.client,
        playerId: playerId,
      );
      questSystem.attachSyncService(syncService, playerId: playerId);
      questSystem.syncFromServer();
    }

    debugPrint('DiggleGame: services attached');
  }

  @override
  Future<void> onLoad() async {
    // Initialize core systems
    fuelSystem = FuelSystem();
    economySystem = EconomySystem();
    hullSystem = HullSystem();
    itemSystem = ItemSystem();

    // Initialize new systems
    drillbitSystem = DrillbitSystem();
    engineSystem = EngineSystem();
    coolingSystem = CoolingSystem();

    // NFT gear bonuses (never in challenge mode — standardized loadout)
    gearSystem.onGearChanged = _applyGearBonuses;
    await gearSystem.initialize();
    _applyGearBonuses();

    // Prestige perks (never in challenge mode — standardized loadout)
    final prestige = prestigeSystem;
    if (prestige != null && !challengeMode && prestige.level > 0) {
      economySystem.setSellMultiplier(prestige.sellMultiplier);
      if (isNewGame) {
        // Starter kit for a fresh contract (base cash is already 50)
        economySystem.addCash(prestige.starterCash - 50);
        itemSystem.addItem(ItemType.dynamite);
        itemSystem.addItem(ItemType.repairBot);
      }
    }

// Initialize quests (loads from prefs, assigns dailies)
    questSystem.initialize();
// Wire quest reward callback
    questSystem.onAwardReward = (xp, points, source) {
      if (statsBridge != null) {
        // Bridge updates the local XP system AND the server ledger.
        statsBridge!.awardQuestReward(xp, points, source);
      } else {
        // Offline fallback: local-only award.
        xpPointsSystem.addXP(xp);
        xpPointsSystem.addPoints(points);
      }
    };

    // Initialize artifact collection log
    collectionSystem.initialize();
    collectionSystem.onAwardReward = (xp, points, description) {
      if (statsBridge != null) {
        statsBridge!.awardBonus(xp, points, 'achievement', description,
            metadata: {'bonus_type': 'collection'});
      } else {
        xpPointsSystem.awardBonus(xp, points, description);
      }
    };

    // Achievements + login streak share the same award path.
    void awardBonusReward(int xp, int points, String description,
        String bonusType) {
      if (statsBridge != null) {
        statsBridge!.awardBonus(xp, points, 'achievement', description,
            metadata: {'bonus_type': bonusType});
      } else {
        xpPointsSystem.awardBonus(xp, points, description);
      }
    }

    achievementSystem.onAwardReward =
        (xp, points, desc) => awardBonusReward(xp, points, desc, 'achievement');
    await achievementSystem.initialize();
    achievementSystem.recordLevel(xpPointsSystem.level);

    streakSystem.onAwardReward =
        (xp, points, desc) => awardBonusReward(xp, points, desc, 'streak');
    // Server owns the streak day when we have a backend; without one
    // (offline, guest-before-auth, tests) the system claims locally.
    final bridge = statsBridge;
    if (bridge != null) {
      streakSystem.serverClaim = ({
        required int localStreak,
        required String? localLastClaimDay,
      }) =>
          bridge.statsService.claimDailyStreak(
            localStreak: localStreak,
            localLastClaimDay: localLastClaimDay,
          );
    }
    streakSystem.initializeAndClaim();

    // Level rewards: items + titles at key levels (LevelRewardTable)
    xpPointsSystem.onLevelUp = (newLevel) {
      achievementSystem.recordLevel(newLevel);
      final reward = LevelRewardTable.forLevel(newLevel);
      if (reward == null || reward.isEmpty) return;
      reward.items.forEach((type, count) {
        for (int i = 0; i < count; i++) {
          itemSystem.addItem(type);
        }
      });
      final titleId = reward.title;
      if (titleId != null) {
        // The game layer has no BuildContext; the UI supplies the
        // localized sentence. Falls back to the raw id.
        xpPointsSystem.awardBonus(
            0, 0, formatTitleUnlocked?.call(titleId) ?? titleId);
      }
    };

    /* --- 1. Initialize Joystick ---
    joystick = JoystickComponent(
      knob: CircleComponent(
          radius: 20,
          paint: Paint()..color = Colors.white.withOpacity(0.8)
      ),
      background: CircleComponent(
          radius: 50,
          paint: Paint()..color = Colors.black.withOpacity(0.5)
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );*/

    // Create tile map
    tileMap = TileMapComponent(config: worldConfig);

    // Create drill with all systems AND Joystick reference
    drill = DrillComponent(
      tileMap: tileMap,
      fuelSystem: fuelSystem,
      economySystem: economySystem,
      hullSystem: hullSystem,
      drillbitSystem: drillbitSystem,
      engineSystem: engineSystem,
      coolingSystem: coolingSystem,
      // --- 2. Pass Joystick to Drill ---
      //joystick: joystick,
      onGameOver: _handleGameOver,
      onReachSurface: _handleReachSurface,
    );

    // The Heat Shield had no on-screen presence at all: no aura, and no
    // event when it expired. This polls the flag and renders both.
    drill.add(HeatShieldAura());

    // Explicit priorities — both were 0, which left the paint order between
    // the world and the drill up to insertion order.
    tileMap.priority = 0;
    drill.priority = 1;
    vfxLayer = VfxLayer();

    // Add to world
    world.add(tileMap);
    world.add(drill);
    world.add(vfxLayer);

    // --- 3. Add Joystick to Camera Viewport (HUD) ---
    // This ensures it stays fixed on screen while the camera moves
    // camera.viewport.add(joystick);
    screenVfx = ScreenVfx();
    camera.viewport.add(screenVfx);

    // Camera setup
    camera.viewfinder.anchor = Anchor.center;
    camera.follow(
      drill,
      maxSpeed: 500,
      horizontalOnly: false,
    );
    camera.viewfinder.zoom = 1.5;

    // Camera bounds
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, tileMap.worldSize.x, tileMap.worldSize.y),
    );

    overlays.add('hud');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_state != GameState.playing) return;
    // Re-arm the surface edge as soon as the drill leaves the surface.
    if (!drill.isAtSurface) _atSurface = false;
    if (_heatShieldRemaining > 0) {
      _heatShieldRemaining = (_heatShieldRemaining - dt).clamp(0.0, 60.0);
    }
    economySystem.updateMaxDepth(drill.depth);
    //xpPointsSystem.updateDepth(drill.depth);
    //xpPointsSystem.checkDepthMilestone(drill.depth);
    // CHANGED: Use bridge instead of xpPointsSystem directly
    statsBridge?.checkDepthMilestone(drill.depth) ??
        xpPointsSystem.checkDepthMilestone(drill.depth);
    questSystem.onDepthReached(drill.depth);

    // Track play time (sync every 60s)
    _playTimeAccumulator += dt;
    if (_playTimeAccumulator >= 60.0) {
      _totalPlaytimeSeconds += 60;
      statsBridge?.recordPlayTime(60);
      _playTimeAccumulator -= 60.0;
    }
  }

  @override
  Color backgroundColor() => const Color(0xFF1a1a2e);

  // State management
  GameState get state => _state;
  bool get isPlaying => _state == GameState.playing;

  /// DrillComponent.update() calls onGameOver every frame while the hull is
  /// destroyed (its children keep ticking because super.update runs before
  /// this game's `_state` early return), so this MUST be idempotent.
  /// Without the guard, `recordDeath()` — a plain counter — races to 25 in
  /// under a second, and `_scheduleSave()`'s 5s debounce is re-cancelled
  /// every frame so achievement progress never persists.
  void _handleGameOver() {
    if (_state == GameState.gameOver) return;
    // Emitted here rather than at each cause, so every death gets it and the
    // re-entry guard above keeps it to exactly one. VfxLayer deliberately
    // does NOT gate on gameOver — this fires on the frame the state flips.
    vfx.emitAt(VfxKind.death, drill.position.x, drill.position.y);
    _state = GameState.gameOver;
    achievementSystem.recordDeath();
    fuelSystem.pause();
    overlays.add('gameOver');
    overlays.remove('hud');
    // Hide joystick on game over
    // joystick.removeFromParent();
  }

  /// True once the drill has arrived at the surface, cleared in [update] the
  /// moment it leaves. The drill fires `onReachSurface` every frame while
  /// parked up top, so arrival has to be detected as an edge, not a state.
  bool _atSurface = false;

  void _handleReachSurface() {
    if (_atSurface) return;
    _atSurface = true;
    // Edge-triggered surface arrival. Effect hook goes here.
  }

  void openShop() {
    if (!drill.isAtSurface) return;
    _state = GameState.shopping;
    fuelSystem.pause();
    overlays.add('shop');
    // Hide joystick in shop
    // if (joystick.parent != null) joystick.removeFromParent();
  }

  void openPremiumStore() {
    overlays.add('premiumStore');
    // Hide joystick
    //if (joystick.parent != null) joystick.removeFromParent();
  }

  void closeShop() {
    _state = GameState.playing;
    fuelSystem.resume();
    overlays.remove('shop');
    // Restore joystick
    // if (joystick.parent == null) camera.viewport.add(joystick);
  }

  void openQuests() {
    overlays.add('quests');
  }

  void closeQuests() {
    overlays.remove('quests');
  }

  void restart() {
    // Reset all systems
    fuelSystem.reset();
    economySystem.reset();
    hullSystem.reset();
    itemSystem.reset();
    drillbitSystem.reset();
    engineSystem.reset();
    coolingSystem.reset();
    xpPointsSystem.resetSession();
    lightSystem.reset();
    questSystem.reset();

    // tileMap.reset() is `async void` and leaves a blank grid for a few
    // hundred ms — live particles would be drawing over nothing.
    vfx.clear();
    vfxLayer.clearAll();
    world.clearShake();
    screenVfx.clear();

    tileMap.reset();
    drill.reset();
    _state = GameState.playing;
    _atSurface = false;
    _totalPlaytimeSeconds = 0;
    _playTimeAccumulator = 0;
    fuelSystem.resume();
    // Clear all overlays and restore HUD
    overlays.remove('gameOver');
    overlays.remove('shop');
    overlays.remove('pause');
    overlays.remove('settings');
    if (!overlays.isActive('hud')) {
      overlays.add('hud');
    }

    // Ensure joystick is visible
    // if (joystick.parent == null) camera.viewport.add(joystick);
  }

  void pause() {
    if (_state != GameState.playing) return;
    _state = GameState.paused;
    fuelSystem.pause();
    overlays.add('pause');
    // Hide joystick
    //if (joystick.parent != null) joystick.removeFromParent();
  }

  void resume() {
    if (_state != GameState.paused) return;
    _state = GameState.playing;
    fuelSystem.resume();
    overlays.remove('pause');
    // Restore joystick
    // if (joystick.parent == null) camera.viewport.add(joystick);
  }

  /* Input (Legacy - kept for compatibility if you have buttons, but Joystick takes priority)*/
  void handleMove(MoveDirection direction) {
    if (_state != GameState.playing) return;
    drill.heldDirection = direction;
  }

  void handleMoveRelease() {
    drill.heldDirection = MoveDirection.none;
  }

  // ============================================================
  // SAVE / LOAD — Serialization helpers
  // ============================================================

  /// Export the tile map as a compressed byte array for persistence.
  ///
  /// Delegates to [TileMapComponent.exportBytes] which should return
  /// a Uint8List of the raw tile IDs (or a compressed variant).
  /// If the tile map doesn't support export yet, returns an empty list.
  Uint8List exportTileMapBytes() {
    try {
      return tileMap.exportBytes();
    } catch (e) {
      debugPrint('DiggleGame.exportTileMapBytes: $e');
      return Uint8List(0);
    }
  }

  /// Export all game system states into a serializable map.
  ///
  /// Used by [GameLifecycleManager.saveWorld] to persist the full
  /// game state alongside the tile map bytes.
  Map<String, dynamic> exportGameSystems() {
    return {
      'fuel': {
        'current': fuelSystem.fuel,
        'maxFuel': fuelSystem.maxFuel,
        'level': fuelSystem.tankLevel.index,
      },
      'economy': {
        'money': economySystem.money,
        'totalEarned': economySystem.totalEarned,
        'maxDepth': economySystem.maxDepth,
        'cargoLevel': economySystem.cargoLevel.index,
        'ore': economySystem.oreInventory,
      },
      'hull': {
        'current': hullSystem.hull,
        'maxHull': hullSystem.maxHull,
        'level': hullSystem.hullLevel.index,
      },
      'drillbit': {
        'level': drillbitSystem.level.index,
      },
      'engine': {
        'level': engineSystem.level.index,
      },
      'cooling': {
        'level': coolingSystem.level.index,
      },
      'light': {
        'level': lightSystem.level.index,
      },
      'xp': {
        'xp': xpPointsSystem.xp,
        'points': xpPointsSystem.points,
        'level': xpPointsSystem.level,
      },
      'items': {
        'inventory': itemSystem.exportInventory(),
      },
      'playtime': _totalPlaytimeSeconds,
    };
  }

  /// Import game system states from a previously saved map.
  ///
  /// Call this after [onLoad] completes to restore a saved game
  /// session. The tile map should be restored separately via
  /// [TileMapComponent.importBytes].
  void importGameSystems(Map<String, dynamic> data) {
    try {
      // Fuel
      if (data.containsKey('fuel')) {
        final f = data['fuel'] as Map<String, dynamic>;
        fuelSystem.restore(
          fuel: (f['current'] as num).toDouble(),
          maxFuel: (f['maxFuel'] as num).toDouble(),
          level: (f['level'] as num).toInt(),
        );
      }

      // Economy
      if (data.containsKey('economy')) {
        final e = data['economy'] as Map<String, dynamic>;
        economySystem.restore(
          money: (e['money'] as num).toInt(),
          totalEarned: (e['totalEarned'] as num).toInt(),
          maxDepth: (e['maxDepth'] as num).toInt(),
          cargoLevel: (e['cargoLevel'] as num).toInt(),
          ore: e['ore'] as Map<String, dynamic>?,
        );
      }

      // Hull
      if (data.containsKey('hull')) {
        final h = data['hull'] as Map<String, dynamic>;
        hullSystem.restore(
          hull: (h['current'] as num).toDouble(),
          maxHull: (h['maxHull'] as num).toDouble(),
          level: (h['level'] as num).toInt(),
        );
      }

      // Drillbit
      if (data.containsKey('drillbit')) {
        final d = data['drillbit'] as Map<String, dynamic>;
        drillbitSystem.restore(level: (d['level'] as num).toInt());
      }

      // Engine
      if (data.containsKey('engine')) {
        final en = data['engine'] as Map<String, dynamic>;
        engineSystem.restore(level: (en['level'] as num).toInt());
      }

      // Cooling
      if (data.containsKey('cooling')) {
        final c = data['cooling'] as Map<String, dynamic>;
        coolingSystem.restore(level: (c['level'] as num).toInt());
      }

      // Light
      if (data.containsKey('light')) {
        final li = data['light'] as Map<String, dynamic>;
        lightSystem.restore(level: (li['level'] as num).toInt());
      }

      // XP / Points
      if (data.containsKey('xp')) {
        final x = data['xp'] as Map<String, dynamic>;
        xpPointsSystem.restoreFromServer(
          xp: (x['xp'] as num).toInt(),
          points: (x['points'] as num).toInt(),
          level: (x['level'] as num).toInt(),
        );
      }

      // Items
      if (data.containsKey('items')) {
        final i = data['items'] as Map<String, dynamic>;
        if (i.containsKey('inventory')) {
          itemSystem.importInventory(i['inventory']);
        }
      }

      // Playtime
      if (data.containsKey('playtime')) {
        _totalPlaytimeSeconds = (data['playtime'] as num).toInt();
      }

      debugPrint('DiggleGame: game systems imported');
    } catch (e) {
      debugPrint('DiggleGame.importGameSystems error: $e');
    }
  }

  /// Import tile map bytes from a saved state.
  ///
  /// Call after [onLoad] to restore the saved world terrain.
  void importTileMapBytes(Uint8List bytes) {
    if (bytes.isEmpty) return;
    try {
      tileMap.importBytes(bytes);
      debugPrint('DiggleGame: tile map imported (${bytes.length} bytes)');
    } catch (e) {
      debugPrint('DiggleGame.importTileMapBytes error: $e');
    }
  }

  // ============================================================
  // SHOP TRANSACTIONS
  // ============================================================

  int sellOre() {
    final earned = economySystem.sellAllOre();
    if (earned > 0) {
      // xpPointsSystem.awardForSale(earned, economySystem.totalOreCollected);
      statsBridge?.awardForSale(earned, economySystem.totalOreCollected) ??
          xpPointsSystem.awardForSale(earned, economySystem.totalOreCollected);
      questSystem.onOreSold(earned);
      achievementSystem.recordCashEarned(earned);
      achievementSystem.recordOreSale();
    }
    return earned;
  }
//  int sellOre() => economySystem.sellAllOre();

  bool refuel() {
    final cost = fuelSystem.getRefillCost();
    if (economySystem.spend(cost)) {
      fuelSystem.refill();
      return true;
    }
    return false;
  }

  // Fuel tank upgrade
  bool upgradeFuelTank() {
    final cost = fuelSystem.getUpgradeCost();
    if (cost > 0 && economySystem.spend(cost)) {
      fuelSystem.upgrade();
      return true;
    }
    return false;
  }

  // Cargo upgrade
  bool upgradeCargo() => economySystem.upgradeCargo();

  // Hull repair
  bool repairHull() {
    final cost = hullSystem.getRepairCost();
    if (cost > 0 && economySystem.spend(cost)) {
      final damageBefore = hullSystem.maxHull - hullSystem.hull;
      hullSystem.fullRepair();
      questSystem.onHullRepaired(damageBefore.toInt());
      return true;
    }
    return false;
  }

  // Hull upgrade
  bool upgradeHull() {
    final cost = hullSystem.getUpgradeCost();
    if (cost > 0 && economySystem.spend(cost)) {
      hullSystem.upgrade();
      return true;
    }
    return false;
  }

  // Drillbit upgrade
  bool upgradeDrillbit() {
    final cost = drillbitSystem.getUpgradeCost();
    if (cost > 0 && economySystem.spend(cost)) {
      drillbitSystem.upgrade();
      return true;
    }
    return false;
  }

  // Engine upgrade
  bool upgradeEngine() {
    final cost = engineSystem.getUpgradeCost();
    if (cost > 0 && economySystem.spend(cost)) {
      engineSystem.upgrade();
      return true;
    }
    return false;
  }

  // Cooling upgrade
  bool upgradeCooling() {
    final cost = coolingSystem.getUpgradeCost();
    if (cost > 0 && economySystem.spend(cost)) {
      coolingSystem.upgrade();
      return true;
    }
    return false;
  }

  bool upgradeLight() {
    final cost = lightSystem.getUpgradeCost();
    if (cost > 0 && economySystem.spend(cost)) {
      lightSystem.upgrade();
      return true;
    }
    return false;
  }


  // ============================================================
  // ITEM SHOP
  // ============================================================

  bool buyItem(ItemType type) {
    if (!itemSystem.canAddItem(type)) return false;
    if (!economySystem.spend(type.price)) return false;
    itemSystem.addItem(type);
    return true;
  }

  // Item usage
  bool useItem(ItemType type) {
    if (!itemSystem.hasItem(type)) return false;
    if (_state != GameState.playing) return false;

    switch (type) {
      case ItemType.backupFuel:
        fuelSystem.add(type.fuelAmount);
        break;

      case ItemType.repairBot:
        hullSystem.repair(type.repairAmount);
        break;

      case ItemType.dynamite:
        _collectBlastYield(
            tileMap.explode(drill.gridX, drill.gridY, type.explosionRadius));
        achievementSystem.recordBlast();
        questSystem.onExplosiveUsed();
        break;

      case ItemType.c4:
        _collectBlastYield(
            tileMap.explode(drill.gridX, drill.gridY, type.explosionRadius));
        achievementSystem.recordBlast();
        questSystem.onExplosiveUsed();
        break;

      case ItemType.spaceRift:
        drill.teleportToSurface();
        break;

      case ItemType.oreScanner:
        // Reveal a wide radius around the drill (fog of war)
        tileMap.revealAround(drill.gridX, drill.gridY, radius: 6);
        break;

      case ItemType.heatShield:
        _heatShieldRemaining = 60.0;
        break;
    }

    itemSystem.useItem(type);
    questSystem.onItemUsed();
    return true;
  }

  // ── Heat shield (points-exclusive consumable) ──────────────────

  double _heatShieldRemaining = 0;
  bool get heatShieldActive => _heatShieldRemaining > 0;
  double get heatShieldRemaining => _heatShieldRemaining;

  /// Buy a consumable with points instead of cash.
  bool buyItemWithPoints(ItemType type) {
    if (!itemSystem.canAddItem(type)) return false;
    final cost = type.pointsPrice;
    final ok = statsBridge?.spendPoints(cost,
            itemName: 'item_${type.name}') ??
        xpPointsSystem.spendPoints(cost);
    if (!ok) return false;
    itemSystem.addItem(type);
    return true;
  }

  // ── Emergency Recovery (death sink) ────────────────────────────

  /// Points cost to recover after death: base fee + 5% of cargo value.
  /// The more you were carrying, the more the rescue costs — and the
  /// more it's worth paying.
  int get emergencyRecoveryCost =>
      50 + (economySystem.cargoValue * 0.05).round();

  /// Rescue the drill after game over: keeps cargo, returns to surface
  /// with half hull and half fuel. Costs points.
  bool emergencyRecover() {
    if (_state != GameState.gameOver) return false;
    final cost = emergencyRecoveryCost;
    final ok = statsBridge?.spendPoints(cost,
            itemName: 'emergency_recovery') ??
        xpPointsSystem.spendPoints(cost);
    if (!ok) return false;

    hullSystem.repair(hullSystem.maxHull * 0.5);
    fuelSystem.add(fuelSystem.maxFuel * 0.5);
    drill.teleportToSurface();
    _state = GameState.playing;
    fuelSystem.resume();
    overlays.remove('gameOver');
    if (!overlays.isActive('hud')) overlays.add('hud');
    return true;
  }

  // ── Miner's Pass (weekly premium quest track) ──────────────────

  static const int minersPassCost = 300;

  /// Activate the Weekly Miner's Pass: 2x weekly quest rewards for the
  /// current ISO week. The recurring points sink that makes points
  /// packs worth buying.
  bool activateMinersPass() {
    if (questSystem.minersPassActive) return false;
    final ok = statsBridge?.spendPoints(minersPassCost,
            itemName: 'miners_pass') ??
        xpPointsSystem.spendPoints(minersPassCost);
    if (!ok) return false;
    questSystem.activateMinersPass();
    return true;
  }

  /// Blasted ore is partially recoverable: every other ore survives the
  /// explosion and goes to cargo (until full). No mining XP/points — the
  /// value comes from selling what survived.
  void _collectBlastYield(List<TileType> destroyedOres) {
    for (int i = 0; i < destroyedOres.length; i++) {
      if (i.isOdd) continue; // 50% yield
      economySystem.collectOre(destroyedOres[i]);
    }
  }

  // ============================================================
  // WORLD DISCOVERY REWARDS
  // ============================================================

  /// Supply crate dug up: cash + points scaled by depth.
  /// [x], [y] are the grid coordinates of the crate — the effect layer needs
  /// a position, and only the dig site knows it.
  void onLootCrateOpened(int x, int y, int depth) {
    final cash = 150 + depth * 2;
    economySystem.addCash(cash);
    questSystem.onCrateOpened();
    final points = 10 + depth ~/ 10;
    // 'achievement' is a server-whitelisted ledger source; the metadata
    // records the true origin for analytics.
    if (statsBridge != null) {
      statsBridge!.awardBonus(25, points, 'achievement',
          'Supply crate: +\$$cash!',
          metadata: {'bonus_type': 'loot_crate', 'depth': depth});
    } else {
      xpPointsSystem.awardBonus(25, points, 'Supply crate: +\$$cash!');
    }
  }

  /// Artifact dug up: resolve which relic this site holds and log it.
  /// Duplicates and set-completion bonuses are handled inside
  /// CollectionSystem via its award callback.
  void onArtifactFound(int x, int y, int depth) {
    final result = collectionSystem.collect(x, y, depth, seed);
    if (result.isNew) {
      achievementSystem.recordArtifactFound();
      questSystem.onArtifactFound();
      final desc = 'Found ${result.artifact.icon} ${result.artifact.name}!';
      if (statsBridge != null) {
        statsBridge!.awardBonus(60, 25, 'achievement', desc, metadata: {
          'bonus_type': 'artifact',
          'artifact_id': result.artifact.id,
          'depth': depth,
        });
      } else {
        xpPointsSystem.awardBonus(60, 25, desc);
      }
    }
  }

  /// Apply (or clear) equipped NFT gear bonuses on all ship systems.
  void _applyGearBonuses() {
    if (challengeMode) return; // standardized loadout
    drillbitSystem.setGearBonus(
      speedBonus: gearSystem.drillSpeedBonus,
      hardnessOverride: gearSystem.drillHardnessOverride,
    );
    engineSystem.setGearBonus(speedBonus: gearSystem.thrusterSpeedBonus);
    fuelSystem.setGearBonus(
      capacityBonus: gearSystem.fuelCapacityBonus,
      refuelDiscount: gearSystem.refuelDiscount,
    );
    hullSystem.setGearBonus(hpBonus: gearSystem.hullHPBonus);
    economySystem.setGearBonus(
      slotBonus: gearSystem.cargoSlotBonus,
      sellBonus: gearSystem.sellBonus,
    );
  }

  /// Whether the current run qualifies for signing the next contract.
  bool get canPrestige =>
      !challengeMode &&
      (prestigeSystem?.canPrestige(
            maxDepth: economySystem.maxDepthReached,
            lifetimeCash: economySystem.totalCashEarned,
          ) ??
          false);

  void openCollection() {
    overlays.add('collection');
  }

  void closeCollection() {
    overlays.remove('collection');
  }
}