/// diggle_game.dart
/// Main Flame game class for Diggle.

import 'package:flame/components.dart';
import 'package:flame/events.dart';
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



    // Create tile map
    tileMap = TileMapComponent(config: worldConfig);

    // Create drill with all systems
    drill = DrillComponent(
      tileMap: tileMap,
      fuelSystem: fuelSystem,
      economySystem: economySystem,
      hullSystem: hullSystem,
      drillbitSystem: drillbitSystem,
      engineSystem: engineSystem,
      coolingSystem: coolingSystem,
      onGameOver: _handleGameOver,
      onReachSurface: _handleReachSurface,
    );

    // Add to world
    world.add(tileMap);
    world.add(drill);

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

    // ADD: Track play time (sync every 60s)
    _playTimeAccumulator += dt;
    if (_playTimeAccumulator >= 60.0) {
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
  }

  void _handleReachSurface() {}

  void openShop() {
    if (!drill.isAtSurface) return;
    _state = GameState.shopping;
    fuelSystem.pause();
    overlays.add('shop');
  }

  void openPremiumStore() {
    overlays.add('premiumStore');
  }

  void closeShop() {
    _state = GameState.playing;
    fuelSystem.resume();
    overlays.remove('shop');
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
    fuelSystem.resume();
    // Clear all overlays and restore HUD
    overlays.remove('gameOver');
    overlays.remove('shop');
    overlays.remove('pause');
    overlays.remove('settings');
    if (!overlays.isActive('hud')) {
      overlays.add('hud');
    }
  }

  void pause() {
    if (_state != GameState.playing) return;
    _state = GameState.paused;
    fuelSystem.pause();
    overlays.add('pause');
  }

  void resume() {
    if (_state != GameState.paused) return;
    _state = GameState.playing;
    fuelSystem.resume();
    overlays.remove('pause');
  }

  // Input
  void handleMove(MoveDirection direction) {
    if (_state != GameState.playing) return;
    drill.heldDirection = direction;
  }

  void handleMoveRelease() {
    drill.heldDirection = MoveDirection.none;
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
