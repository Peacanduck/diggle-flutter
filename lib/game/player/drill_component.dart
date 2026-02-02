/// drill_component.dart
/// Smooth movement drill with fall damage (no fuel loss while falling)

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;
import '../world/tile_map_component.dart';
import '../world/tile.dart';
import '../systems/fuel_system.dart';
import '../systems/economy_system.dart';
import '../systems/hull_system.dart';
import '../diggle_game.dart';

enum MoveDirection { left, right, down, up, none }

class DrillComponent extends PositionComponent with HasGameRef<DiggleGame> {
  final TileMapComponent tileMap;
  final FuelSystem fuelSystem;
  final EconomySystem economySystem;
  final HullSystem hullSystem;

  MoveDirection heldDirection = MoveDirection.none;

  // Target we're moving toward
  Vector2 _target = Vector2.zero();

  // Digging state
  bool _digging = false;
  int _digX = 0;
  int _digY = 0;

  // Fall tracking
  bool _isFalling = false;
  int _fallStartY = 0;
  int _currentFallY = 0;

  // Speeds
  static const double normalSpeed = 200.0;
  static const double flySpeed = 320.0;
  static const double fallSpeed = 280.0;
  static const double digSpeed = 4.0;

  // Fall damage settings
  static const int safeFallDistance = 3;
  static const double damagePerTile = 15.0;

  final void Function()? onGameOver;
  final void Function()? onReachSurface;

  DrillComponent({
    required this.tileMap,
    required this.fuelSystem,
    required this.economySystem,
    required this.hullSystem,
    this.onGameOver,
    this.onReachSurface,
  }) : super(
    size: Vector2.all(TileMapComponent.tileSize * 0.8),
    anchor: Anchor.center,
  );

  int get gridX => (position.x / TileMapComponent.tileSize).floor();
  int get gridY => (position.y / TileMapComponent.tileSize).floor();
  int get depth => (gridY - tileMap.config.surfaceRows).clamp(0, 999);
  bool get isAtSurface => gridY <= tileMap.config.surfaceRows;

  Vector2 _tileCenter(int x, int y) => Vector2(
    x * TileMapComponent.tileSize + TileMapComponent.tileSize / 2,
    y * TileMapComponent.tileSize + TileMapComponent.tileSize / 2,
  );

  @override
  Future<void> onLoad() async {
    position = tileMap.getSpawnPosition();
    _target = position.clone();
    tileMap.revealAround(gridX, gridY);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Check for game over conditions
    if (hullSystem.isDestroyed) {
      onGameOver?.call();
      return;
    }
    if (fuelSystem.isEmpty && !isAtSurface) {
      onGameOver?.call();
      return;
    }

    // If digging, handle that first
    if (_digging) {
      _handleDigging(dt);
      return;
    }

    final toTarget = _target - position;
    final dist = toTarget.length;

    if (dist > 1) {
      // Move toward target
      final speed = _getCurrentSpeed();
      final move = toTarget.normalized() * speed * dt;
      if (move.length > dist) {
        position = _target.clone();
      } else {
        position += move;
      }
      tileMap.revealAround(gridX, gridY);
    } else {
      // Reached target
      position = _target.clone();

      // Update fall tracking when reaching new tile
      if (_isFalling) {
        _currentFallY = gridY;
      }

      _decideNextMove(dt);
    }

    economySystem.updateMaxDepth(depth);

    if (isAtSurface) {
      onReachSurface?.call();
    }
  }

  double _getCurrentSpeed() {
    if (heldDirection == MoveDirection.up) return flySpeed;
    if (_isFalling) return fallSpeed;
    return normalSpeed;
  }

  void _decideNextMove(double dt) {
    final gx = gridX;
    final gy = gridY;

    // Check tile below for falling logic
    final below = tileMap.getTileAt(gx, gy + 1);
    final canFall = below != null && below.type == TileType.empty;

    // If holding a direction, try to go that way
    if (heldDirection != MoveDirection.none) {
      int nx = gx, ny = gy;
      switch (heldDirection) {
        case MoveDirection.left: nx--; break;
        case MoveDirection.right: nx++; break;
        case MoveDirection.down: ny++; break;
        case MoveDirection.up: ny--; break;
        case MoveDirection.none: break;
      }

      final tile = tileMap.getTileAt(nx, ny);
      if (tile == null) {
        // Can't move there, check for fall
        if (canFall) _continueFalling(gx, gy);
        return;
      }

      if (heldDirection == MoveDirection.up) {
        // Flying - only through empty space
        if (tile.type == TileType.empty) {
          // Flying cancels fall WITHOUT damage (you saved yourself!)
          _isFalling = false;
          _fallStartY = 0;
          _currentFallY = 0;
          _target = _tileCenter(nx, ny);
          fuelSystem.consume(0.4);
        } else {
          // Can't fly through solid - but pressing UP still cancels fall damage
          // (you're trying to save yourself, just blocked by ceiling)
          _isFalling = false;
          _fallStartY = 0;
          _currentFallY = 0;
          // Check if we should start falling again
          if (canFall) _continueFalling(gx, gy);
        }
      } else if (heldDirection == MoveDirection.left || heldDirection == MoveDirection.right) {
        // Horizontal movement
        if (tile.type == TileType.empty) {
          // Moving sideways cancels fall WITHOUT damage
          _isFalling = false;
          _fallStartY = 0;
          _currentFallY = 0;
          _target = _tileCenter(nx, ny);
          fuelSystem.consume(0.5);
        } else if (tile.type != TileType.bedrock) {
          // Digging sideways while falling - take damage first
          if (_isFalling) {
            _land();
          }
          _digging = true;
          _digX = nx;
          _digY = ny;
          tileMap.startDig(nx, ny);
        } else {
          // Bedrock - check for fall
          if (canFall) _continueFalling(gx, gy);
        }
      } else if (heldDirection == MoveDirection.down) {
        // Downward movement
        if (tile.type == TileType.empty) {
          // Continue or start falling (no fuel cost)
          if (!_isFalling) {
            _startFalling(gy);
          }
          _target = _tileCenter(nx, ny);
          // NO fuel consumption while falling!
        } else if (tile.type != TileType.bedrock) {
          // Digging down into solid - take fall damage!
          if (_isFalling) {
            _land();
          }
          _digging = true;
          _digX = nx;
          _digY = ny;
          tileMap.startDig(nx, ny);
        }
        // Bedrock below = can't move, already on ground
      }
    } else {
      // Not holding direction - check for falling
      if (canFall) {
        _continueFalling(gx, gy);
      } else if (_isFalling) {
        // We were falling but now there's ground - land!
        _land();
      }
    }
  }

  void _startFalling(int startY) {
    _isFalling = true;
    _fallStartY = startY;
    _currentFallY = startY;
  }

  void _continueFalling(int gx, int gy) {
    if (!_isFalling) {
      _startFalling(gy);
    }
    _target = _tileCenter(gx, gy + 1);
    // NO fuel consumption while falling!
  }

  void _land() {
    if (!_isFalling) return;

    final fallDistance = _currentFallY - _fallStartY;
    _isFalling = false;
    _fallStartY = 0;
    _currentFallY = 0;

    if (fallDistance > safeFallDistance) {
      final damageTiles = fallDistance - safeFallDistance;
      final damage = damageTiles * damagePerTile;
      hullSystem.takeDamage(damage);
    }
  }

  void _handleDigging(double dt) {
    final tile = tileMap.getTileAt(_digX, _digY);
    if (tile == null || tile.type == TileType.empty) {
      _digging = false;
      return;
    }

    final progress = (dt * digSpeed) / tile.type.digTime;
    final result = tileMap.updateDig(_digX, _digY, progress);

    if (result != null) {
      // Check for hazards BEFORE moving into the tile
      if (result.isLethal) {
        // Lava = instant death!
        hullSystem.takeDamage(9999);
        _digging = false;
        return;
      }

      if (result.isHazard && result.hazardDamage > 0) {
        // Gas = take damage but survive
        hullSystem.takeDamage(result.hazardDamage);
      }

      fuelSystem.consume(result.fuelCost);
      if (result.isOre) {
        economySystem.collectOre(result);
      }
      tileMap.revealAround(_digX, _digY);
      _target = _tileCenter(_digX, _digY);
      _digging = false;
    }
  }

  @override
  void render(Canvas canvas) {
    final bodyRect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 2),
      width: size.x,
      height: size.y,
    );

    // Color based on status
    Color color;
    if (hullSystem.isCritical) {
      color = Colors.red.shade900;
    } else if (hullSystem.isLow) {
      color = Colors.orange.shade700;
    } else if (fuelSystem.isCritical) {
      color = Colors.red.shade700;
    } else if (fuelSystem.isLow) {
      color = Colors.orange.shade700;
    } else {
      color = Colors.blue.shade700;
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)),
      Paint()..color = color,
    );

    // Cockpit
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x / 2, size.y / 3),
          width: size.x * 0.5,
          height: size.y * 0.3,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.lightBlue.shade300,
    );

    // Drill bit
    final drill = Path()
      ..moveTo(size.x / 2 - 6, size.y * 0.75)
      ..lineTo(size.x / 2, size.y)
      ..lineTo(size.x / 2 + 6, size.y * 0.75)
      ..close();
    canvas.drawPath(drill, Paint()..color = Colors.grey.shade400);

    // Treads
    final tread = Paint()..color = Colors.grey.shade800;
    canvas.drawRect(Rect.fromLTWH(-2, size.y * 0.4, 4, size.y * 0.5), tread);
    canvas.drawRect(Rect.fromLTWH(size.x - 2, size.y * 0.4, 4, size.y * 0.5), tread);
  }

  void reset() {
    position = tileMap.getSpawnPosition();
    _target = position.clone();
    _digging = false;
    _isFalling = false;
    _fallStartY = 0;
    _currentFallY = 0;
    heldDirection = MoveDirection.none;
    tileMap.revealAround(gridX, gridY);
  }
}