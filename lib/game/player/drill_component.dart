/// drill_component.dart
/// The player-controlled drill component.
/// 
/// Handles:
/// - Movement (left, right, down)
/// - Digging mechanics
/// - Fuel consumption
/// - Collision with world
/// - Gravity when over empty space

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;
import '../world/tile_map_component.dart';
import '../world/tile.dart';
import '../systems/fuel_system.dart';
import '../systems/economy_system.dart';
import '../diggle_game.dart';

/// Movement direction for the drill
enum MoveDirection { left, right, down, none }

/// The player's drill vehicle
class DrillComponent extends PositionComponent with HasGameRef<DiggleGame> {
  /// Reference to the tile map
  final TileMapComponent tileMap;

  /// Reference to fuel system
  final FuelSystem fuelSystem;

  /// Reference to economy system
  final EconomySystem economySystem;

  /// Current movement direction
  MoveDirection _currentDirection = MoveDirection.none;

  /// Current grid position
  int _gridX = 0;
  int _gridY = 0;

  /// Target position for smooth movement
  Vector2 _targetPosition = Vector2.zero();

  /// Whether currently moving/digging
  bool _isMoving = false;
  bool _isDigging = false;

  /// Movement speed (pixels per second)
  static const double moveSpeed = 128.0;

  /// Digging speed multiplier
  static const double digSpeedMultiplier = 1.5;

  /// Gravity speed when falling
  static const double fallSpeed = 200.0;

  /// Whether drill is falling
  bool _isFalling = false;

  /// Callback when game over (fuel depleted underground)
  final void Function()? onGameOver;

  /// Callback when player reaches surface
  final void Function()? onReachSurface;

  DrillComponent({
    required this.tileMap,
    required this.fuelSystem,
    required this.economySystem,
    this.onGameOver,
    this.onReachSurface,
  }) : super(
          size: Vector2.all(TileMapComponent.tileSize * 0.8),
          anchor: Anchor.center,
        );

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  Future<void> onLoad() async {
    // Spawn at surface
    position = tileMap.getSpawnPosition();
    _updateGridPosition();
    _targetPosition = position.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Check for game over (fuel depleted underground)
    if (fuelSystem.isEmpty && !_isAtSurface()) {
      onGameOver?.call();
      return;
    }

    // Handle falling
    if (_isFalling) {
      _handleFalling(dt);
      return;
    }

    // Handle movement
    if (_isMoving || _isDigging) {
      _handleMovement(dt);
    }

    // Check if should fall
    _checkForFall();

    // Update statistics
    economySystem.updateMaxDepth(_gridY - tileMap.config.surfaceRows);
  }

  @override
  void render(Canvas canvas) {
    // Draw drill body
    final bodyRect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 2),
      width: size.x,
      height: size.y,
    );

    // Main body color
    final bodyPaint = Paint()
      ..color = fuelSystem.isCritical
          ? Colors.red.shade700
          : fuelSystem.isLow
              ? Colors.orange.shade700
              : Colors.blue.shade700;

    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)),
      bodyPaint,
    );

    // Cockpit (lighter area)
    final cockpitRect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 3),
      width: size.x * 0.5,
      height: size.y * 0.3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cockpitRect, const Radius.circular(2)),
      Paint()..color = Colors.lightBlue.shade300,
    );

    // Drill bit at bottom
    final drillPath = Path()
      ..moveTo(size.x / 2 - 6, size.y * 0.75)
      ..lineTo(size.x / 2, size.y)
      ..lineTo(size.x / 2 + 6, size.y * 0.75)
      ..close();

    canvas.drawPath(
      drillPath,
      Paint()..color = Colors.grey.shade400,
    );

    // Treads/tracks
    final leftTread = Rect.fromLTWH(-2, size.y * 0.4, 4, size.y * 0.5);
    final rightTread = Rect.fromLTWH(size.x - 2, size.y * 0.4, 4, size.y * 0.5);
    final treadPaint = Paint()..color = Colors.grey.shade800;
    
    canvas.drawRect(leftTread, treadPaint);
    canvas.drawRect(rightTread, treadPaint);
  }

  // ============================================================
  // MOVEMENT CONTROL
  // ============================================================

  /// Start moving in a direction
  void startMove(MoveDirection direction) {
    if (_isMoving || _isDigging || _isFalling || fuelSystem.isEmpty) return;
    
    _currentDirection = direction;
    
    // Calculate target tile
    int targetX = _gridX;
    int targetY = _gridY;

    switch (direction) {
      case MoveDirection.left:
        targetX--;
        break;
      case MoveDirection.right:
        targetX++;
        break;
      case MoveDirection.down:
        targetY++;
        break;
      case MoveDirection.none:
        return;
    }

    // Check bounds
    final targetTile = tileMap.getTileAt(targetX, targetY);
    if (targetTile == null) return;

    // Check if diggable or empty
    if (targetTile.type == TileType.bedrock) return;

    // Set target position
    _targetPosition = Vector2(
      targetX * TileMapComponent.tileSize + TileMapComponent.tileSize / 2,
      targetY * TileMapComponent.tileSize + TileMapComponent.tileSize / 2,
    );

    if (targetTile.type == TileType.empty) {
      // Just move
      _isMoving = true;
      fuelSystem.consume(TileType.empty.fuelCost);
    } else {
      // Need to dig first
      _isDigging = true;
      tileMap.startDig(targetX, targetY);
    }
  }

  /// Stop current movement
  void stopMove() {
    if (_isDigging) {
      // Cancel dig in progress
      final targetX = _getTargetGridX();
      final targetY = _getTargetGridY();
      tileMap.cancelDig(targetX, targetY);
    }
    _currentDirection = MoveDirection.none;
    _isMoving = false;
    _isDigging = false;
  }

  // ============================================================
  // MOVEMENT HANDLING
  // ============================================================

  void _handleMovement(double dt) {
    if (_isDigging) {
      _handleDigging(dt);
    } else if (_isMoving) {
      _moveTowardsTarget(dt);
    }
  }

  void _handleDigging(double dt) {
    final targetX = _getTargetGridX();
    final targetY = _getTargetGridY();
    final targetTile = tileMap.getTileAt(targetX, targetY);
    
    if (targetTile == null || !targetTile.type.isDiggable) {
      stopMove();
      return;
    }

    // Calculate dig progress
    final digTime = targetTile.type.digTime;
    final progressDelta = (dt * digSpeedMultiplier) / digTime;

    // Update dig and check completion
    final dugType = tileMap.updateDig(targetX, targetY, progressDelta);
    
    if (dugType != null) {
      // Dig completed - consume fuel
      fuelSystem.consume(dugType.fuelCost);
      
      // Collect ore if applicable
      if (dugType.isOre) {
        economySystem.collectOre(dugType);
      }

      // Reveal surrounding tiles
      tileMap.revealAround(targetX, targetY);

      // Start moving into the space
      _isDigging = false;
      _isMoving = true;
    }
  }

  void _moveTowardsTarget(double dt) {
    final distance = position.distanceTo(_targetPosition);
    
    if (distance < 1) {
      // Reached target
      position = _targetPosition.clone();
      _updateGridPosition();
      _isMoving = false;
      
      // Check if at surface
      if (_isAtSurface()) {
        onReachSurface?.call();
      }
    } else {
      // Move towards target
      final direction = (_targetPosition - position).normalized();
      position += direction * moveSpeed * dt;
    }
  }

  void _handleFalling(double dt) {
    // Check tile below
    final belowTile = tileMap.getTileAt(_gridX, _gridY + 1);
    
    if (belowTile == null || belowTile.type != TileType.empty) {
      // Stop falling
      _isFalling = false;
      _snapToGrid();
      return;
    }

    // Update target to next empty tile below
    _targetPosition = Vector2(
      _gridX * TileMapComponent.tileSize + TileMapComponent.tileSize / 2,
      (_gridY + 1) * TileMapComponent.tileSize + TileMapComponent.tileSize / 2,
    );

    // Move down
    position.y += fallSpeed * dt;

    // Check if passed target
    if (position.y >= _targetPosition.y) {
      position = _targetPosition.clone();
      _updateGridPosition();
      // Consume fuel for falling
      fuelSystem.consume(TileType.empty.fuelCost * 0.5);
    }
  }

  void _checkForFall() {
    if (_isMoving || _isDigging || _isFalling) return;

    final belowTile = tileMap.getTileAt(_gridX, _gridY + 1);
    if (belowTile != null && belowTile.type == TileType.empty) {
      _isFalling = true;
    }
  }

  // ============================================================
  // UTILITY
  // ============================================================

  void _updateGridPosition() {
    _gridX = (position.x / TileMapComponent.tileSize).floor();
    _gridY = (position.y / TileMapComponent.tileSize).floor();
    
    // Reveal surrounding tiles
    tileMap.revealAround(_gridX, _gridY);
  }

  void _snapToGrid() {
    position = Vector2(
      _gridX * TileMapComponent.tileSize + TileMapComponent.tileSize / 2,
      _gridY * TileMapComponent.tileSize + TileMapComponent.tileSize / 2,
    );
    _targetPosition = position.clone();
  }

  int _getTargetGridX() {
    return (_targetPosition.x / TileMapComponent.tileSize).floor();
  }

  int _getTargetGridY() {
    return (_targetPosition.y / TileMapComponent.tileSize).floor();
  }

  bool _isAtSurface() {
    return tileMap.isAtSurface(_gridY);
  }

  // ============================================================
  // PUBLIC API
  // ============================================================

  /// Current grid X position
  int get gridX => _gridX;

  /// Current grid Y position
  int get gridY => _gridY;

  /// Current depth (tiles below surface)
  int get depth => (_gridY - tileMap.config.surfaceRows).clamp(0, 999);

  /// Whether currently at surface
  bool get isAtSurface => _isAtSurface();

  /// Whether currently busy (moving/digging/falling)
  bool get isBusy => _isMoving || _isDigging || _isFalling;

  /// Reset to spawn position
  void reset() {
    position = tileMap.getSpawnPosition();
    _updateGridPosition();
    _targetPosition = position.clone();
    _isMoving = false;
    _isDigging = false;
    _isFalling = false;
    _currentDirection = MoveDirection.none;
  }
}