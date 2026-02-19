/// diggle_game.dart
/// Main Flame game class for Diggle.

import 'dart:typed_data';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/stats_service.dart';
import '../services/xp_stats_bridge.dart';
import '../services/game_lifecycle_manager.dart';

import 'world/tile_map_component.dart';
import 'world/world_generator.dart';
import 'player/drill_component.dart';
import 'systems/fuel_system.dart';
import 'systems/economy_system.dart';
import 'systems/hull_system.dart';
import 'systems/item_system.dart';
import 'systems/drillbit_system.dart';
import 'systems/engine_system.dart';
import 'systems/cooling_system.dart';
import 'systems/xp_points_system.dart';
import 'systems/boost_manager.dart';

enum GameState { playing, shopping, gameOver, paused }

class DiggleGame extends FlameGame with HasCollisionDetection {
  late TileMapComponent tileMap;
  late DrillComponent drill;

  // Joystick Control
  //late final JoystickComponent joystick;

  // Core systems
  late FuelSystem fuelSystem;
  late EconomySystem economySystem;
  late HullSystem hullSystem;
  late ItemSystem itemSystem;

  // New upgrade systems
  late DrillbitSystem drillbitSystem;
  late EngineSystem engineSystem;
  late CoolingSystem coolingSystem;

  // NEW: XP and Points system
  late XPPointsSystem xpPointsSystem;

  // NOTE: BoostManager is initialized in main.dart since it needs WalletService
  BoostManager? boostManager;

  GameState _state = GameState.playing;
  final WorldConfig worldConfig;
  final int seed;

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
  }) : worldConfig = config ?? WorldConfig(
    width: 64,
    height: 524,
    surfaceRows: 30,
    seed: seed,
  ){
    xpPointsSystem = XPPointsSystem();
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

    // Add to world
    world.add(tileMap);
    world.add(drill);

    // --- 3. Add Joystick to Camera Viewport (HUD) ---
    // This ensures it stays fixed on screen while the camera moves
    // camera.viewport.add(joystick);

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
    economySystem.updateMaxDepth(drill.depth);
    //xpPointsSystem.updateDepth(drill.depth);
    //xpPointsSystem.checkDepthMilestone(drill.depth);
    // CHANGED: Use bridge instead of xpPointsSystem directly
    statsBridge?.checkDepthMilestone(drill.depth) ??
        xpPointsSystem.checkDepthMilestone(drill.depth);

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

  void _handleGameOver() {
    _state = GameState.gameOver;
    fuelSystem.pause();
    overlays.add('gameOver');
    overlays.remove('hud');
    // Hide joystick on game over
    // joystick.removeFromParent();
  }

  void _handleReachSurface() {}

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

    tileMap.reset();
    drill.reset();
    _state = GameState.playing;
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
      hullSystem.fullRepair();
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
        tileMap.explode(drill.gridX, drill.gridY, type.explosionRadius);
        break;

      case ItemType.c4:
        tileMap.explode(drill.gridX, drill.gridY, type.explosionRadius);
        break;

      case ItemType.spaceRift:
        drill.teleportToSurface();
        break;
    }

    itemSystem.useItem(type);
    return true;
  }
}