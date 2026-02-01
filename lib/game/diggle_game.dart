/// diggle_game.dart
/// Main Flame game class for Diggle.
/// 
/// This is the root of the game hierarchy. It:
/// - Initializes the game world
/// - Sets up camera following
/// - Manages game state (playing, paused, game over)
/// - Coordinates overlays (HUD, shop, game over)
/// - Handles player input routing
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/experimental.dart';

import 'world/tile_map_component.dart';
import 'world/world_generator.dart';
import 'player/drill_component.dart';
import 'systems/fuel_system.dart';
import 'systems/economy_system.dart';

/// Game states
enum GameState {
  /// Normal gameplay
  playing,
  
  /// Shop menu open
  shopping,
  
  /// Game over screen
  gameOver,
  
  /// Paused
  paused,
}

/// Main game class
class DiggleGame extends FlameGame with HasCollisionDetection {
  // ============================================================
  // GAME COMPONENTS
  // ============================================================

  /// The tile-based world
  late TileMapComponent tileMap;

  /// The player's drill
  late DrillComponent drill;

  /// Fuel management system
  late FuelSystem fuelSystem;

  /// Economy/inventory system
  late EconomySystem economySystem;

  // ============================================================
  // GAME STATE
  // ============================================================

  /// Current game state
  GameState _state = GameState.playing;

  /// World configuration
  final WorldConfig worldConfig;

  /// Random seed for this run
  final int seed;

  DiggleGame({
    this.seed = 42,
    WorldConfig? config,
  }) : worldConfig = config ??
            WorldConfig(
              width: 64,
              height: 128,
              surfaceRows: 3,
              seed: seed,
            );

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  Future<void> onLoad() async {
    // Initialize systems first
    fuelSystem = FuelSystem();
    economySystem = EconomySystem();

    // Create tile map
    tileMap = TileMapComponent(config: worldConfig);
    
    // Create drill (player)
    drill = DrillComponent(
      tileMap: tileMap,
      fuelSystem: fuelSystem,
      economySystem: economySystem,
      onGameOver: _handleGameOver,
      onReachSurface: _handleReachSurface,
    );

    // ========================================
    // CAMERA SETUP
    // ========================================
    // 
    // Flame's camera system works as follows:
    // 1. CameraComponent has a viewport (what we see on screen)
    // 2. CameraComponent has a viewfinder (what part of world to show)
    // 3. We add game objects to camera.world
    // 4. We configure camera.viewfinder to follow the player
    //
    // The world component is separate from the camera's world.
    // We add our tileMap and drill to camera.world so they render
    // through the camera's transformation.

    // Add components to the camera's world (not directly to game)
    world.add(tileMap);
    world.add(drill);

    // Configure camera to follow player with some bounds
    camera.viewfinder.anchor = Anchor.center;
    
    // Follow the drill with smooth interpolation
    camera.follow(
      drill,
      maxSpeed: 200, // Smooth follow speed
      horizontalOnly: false,
    );

    // Set initial zoom (1.0 = no zoom)
    camera.viewfinder.zoom = 1.5;

    // Clamp camera to world bounds
    camera.setBounds(
      Rectangle.fromLTWH(
        0,
        0,
        tileMap.worldSize.x,
        tileMap.worldSize.y,
      ),
    );

    // ========================================
    // OVERLAYS
    // ========================================
    // Overlays are Flutter widgets that render on top of the game.
    // They're registered in main.dart and toggled here.
    
    // Show HUD by default
    overlays.add('hud');
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Only update game logic when playing
    if (_state != GameState.playing) return;

    // Update depth tracking
    economySystem.updateMaxDepth(drill.depth);
  }

  @override
  Color backgroundColor() => const Color(0xFF1a1a2e);

  // ============================================================
  // GAME STATE MANAGEMENT
  // ============================================================

  /// Current game state
  GameState get state => _state;

  /// Check if game is actively playing
  bool get isPlaying => _state == GameState.playing;

  void _handleGameOver() {
    _state = GameState.gameOver;
    fuelSystem.pause();
    overlays.add('gameOver');
    overlays.remove('hud');
  }

  void _handleReachSurface() {
    // Could trigger events when reaching surface
    // For now, just ensure shop is accessible
  }

  /// Open the shop overlay
  void openShop() {
    if (!drill.isAtSurface) return;
    
    _state = GameState.shopping;
    fuelSystem.pause();
    overlays.add('shop');
  }

  /// Close the shop overlay
  void closeShop() {
    _state = GameState.playing;
    fuelSystem.resume();
    overlays.remove('shop');
  }

  /// Restart the game
  void restart() {
    // Reset systems
    fuelSystem.reset();
    economySystem.reset();
    
    // Reset world
    tileMap.reset();
    
    // Reset player
    drill.reset();
    
    // Reset state
    _state = GameState.playing;
    fuelSystem.resume();
    
    // Update overlays
    overlays.remove('gameOver');
    overlays.remove('shop');
    overlays.add('hud');
  }

  /// Pause the game
  void pause() {
    if (_state != GameState.playing) return;
    _state = GameState.paused;
    fuelSystem.pause();
    overlays.add('pause');
  }

  /// Resume the game
  void resume() {
    if (_state != GameState.paused) return;
    _state = GameState.playing;
    fuelSystem.resume();
    overlays.remove('pause');
  }

  // ============================================================
  // INPUT HANDLING
  // ============================================================

  /// Handle movement input from controls
  void handleMove(MoveDirection direction) {
    if (_state != GameState.playing) return;
    drill.startMove(direction);
  }

  /// Handle movement release
  void handleMoveRelease() {
    drill.stopMove();
  }

  // ============================================================
  // SHOP TRANSACTIONS
  // ============================================================

  /// Sell all ore
  int sellOre() {
    return economySystem.sellAllOre();
  }

  /// Refuel the drill
  bool refuel() {
    final cost = fuelSystem.getRefillCost();
    if (economySystem.spend(cost)) {
      fuelSystem.refill();
      return true;
    }
    return false;
  }

  /// Upgrade fuel tank
  bool upgradeFuelTank() {
    final cost = fuelSystem.getUpgradeCost();
    if (cost > 0 && economySystem.spend(cost)) {
      fuelSystem.upgrade();
      return true;
    }
    return false;
  }

  /// Upgrade cargo capacity
  bool upgradeCargo() {
    return economySystem.upgradeCargo();
  }
}