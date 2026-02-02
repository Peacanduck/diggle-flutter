/// diggle_game.dart
/// Main Flame game class for Diggle.

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'world/tile_map_component.dart';
import 'world/world_generator.dart';
import 'player/drill_component.dart';
import 'systems/fuel_system.dart';
import 'systems/economy_system.dart';
import 'systems/hull_system.dart';

enum GameState { playing, shopping, gameOver, paused }

class DiggleGame extends FlameGame with HasCollisionDetection {
  late TileMapComponent tileMap;
  late DrillComponent drill;
  late FuelSystem fuelSystem;
  late EconomySystem economySystem;
  late HullSystem hullSystem;

  GameState _state = GameState.playing;
  final WorldConfig worldConfig;
  final int seed;

  DiggleGame({
    this.seed = 42,
    WorldConfig? config,
  }) : worldConfig = config ?? WorldConfig(
    width: 64,
    height: 128,
    surfaceRows: 3,
    seed: seed,
  );

  @override
  Future<void> onLoad() async {
    // Initialize systems
    fuelSystem = FuelSystem();
    economySystem = EconomySystem();
    hullSystem = HullSystem();

    // Create tile map
    tileMap = TileMapComponent(config: worldConfig);

    // Create drill with all systems
    drill = DrillComponent(
      tileMap: tileMap,
      fuelSystem: fuelSystem,
      economySystem: economySystem,
      hullSystem: hullSystem,
      onGameOver: _handleGameOver,
      onReachSurface: _handleReachSurface,
    );

    // Add to world
    world.add(tileMap);
    world.add(drill);

    // Camera setup - FAST follow for responsive feel
    camera.viewfinder.anchor = Anchor.center;
    camera.follow(
      drill,
      maxSpeed: 500, // Much faster camera to keep up with flying
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

  void closeShop() {
    _state = GameState.playing;
    fuelSystem.resume();
    overlays.remove('shop');
  }

  void restart() {
    fuelSystem.reset();
    economySystem.reset();
    hullSystem.reset();
    tileMap.reset();
    drill.reset();
    _state = GameState.playing;
    fuelSystem.resume();
    overlays.remove('gameOver');
    overlays.remove('shop');
    overlays.add('hud');
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

  // Shop transactions
  int sellOre() => economySystem.sellAllOre();

  bool refuel() {
    final cost = fuelSystem.getRefillCost();
    if (economySystem.spend(cost)) {
      fuelSystem.refill();
      return true;
    }
    return false;
  }

  bool upgradeFuelTank() {
    final cost = fuelSystem.getUpgradeCost();
    if (cost > 0 && economySystem.spend(cost)) {
      fuelSystem.upgrade();
      return true;
    }
    return false;
  }

  bool upgradeCargo() => economySystem.upgradeCargo();

  bool repairHull() {
    final cost = hullSystem.getRepairCost();
    if (cost > 0 && economySystem.spend(cost)) {
      hullSystem.fullRepair();
      return true;
    }
    return false;
  }

  bool upgradeHull() {
    final cost = hullSystem.getUpgradeCost();
    if (cost > 0 && economySystem.spend(cost)) {
      hullSystem.upgrade();
      return true;
    }
    return false;
  }
}