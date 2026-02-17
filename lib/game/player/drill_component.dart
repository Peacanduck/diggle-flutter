/// drill_component.dart
/// Smooth movement drill with fall damage
/// Uses sprite sheet for player visual (Front, Left, Right)
import 'dart:math' as math; // Added for PI
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' show Colors, Paint, BlendMode, ColorFilter;
import '../world/tile_map_component.dart';
import '../world/tile.dart';
import '../systems/fuel_system.dart';
import '../systems/economy_system.dart';
import '../systems/hull_system.dart';
import '../systems/drillbit_system.dart';
import '../systems/engine_system.dart';
import '../systems/cooling_system.dart';
import '../diggle_game.dart';

enum MoveDirection { left, right, down, up, none }

class DrillComponent extends PositionComponent with HasGameRef<DiggleGame> {
  final TileMapComponent tileMap;
  final FuelSystem fuelSystem;
  final EconomySystem economySystem;
  final HullSystem hullSystem;
  final DrillbitSystem drillbitSystem;
  final EngineSystem engineSystem;
  final CoolingSystem coolingSystem;
  // Optional Joystick Reference
  //JoystickComponent? joystick;

  MoveDirection heldDirection = MoveDirection.none;

  // Track visual facing direction
  MoveDirection _facing = MoveDirection.down;

  // Sprites
  late Sprite _spriteFront;
  late Sprite _spriteLeft;
  late Sprite _spriteRight;

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

  // Base speeds (modified by engine system)
  static const double baseNormalSpeed = 200.0;
  static const double baseFlySpeed = 320.0;
  static const double baseFallSpeed = 280.0;
  static const double baseDigSpeed = 4.0;

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
    required this.drillbitSystem,
    required this.engineSystem,
    required this.coolingSystem,
   // this.joystick, // Add joystick to constructor
    this.onGameOver,
    this.onReachSurface,
  }) : super(
    // Keeping the slight padding (0.8) so the drill fits nicely in the tunnel
    size: Vector2.all(TileMapComponent.tileSize * 0.8),
    anchor: Anchor.center,
  );

  int get gridX => (position.x / TileMapComponent.tileSize).floor();
  int get gridY => (position.y / TileMapComponent.tileSize).floor();
  int get depth => (gridY - tileMap.config.surfaceRows).clamp(0, 9999);
  bool get isAtSurface => gridY <= tileMap.config.surfaceRows;

  // Get effective speeds from engine system
  double get normalSpeed => engineSystem.getEffectiveSpeed(baseNormalSpeed);
  double get flySpeed => engineSystem.getEffectiveFlySpeed(baseFlySpeed);
  double get fallSpeed => baseFallSpeed;

  // Get effective dig speed from drillbit system
  double get digSpeed => baseDigSpeed * drillbitSystem.digSpeedMultiplier;

  Vector2 _tileCenter(int x, int y) => Vector2(
    x * TileMapComponent.tileSize + TileMapComponent.tileSize / 2,
    y * TileMapComponent.tileSize + TileMapComponent.tileSize / 2,
  );

  @override
  Future<void> onLoad() async {
    // Initialize Position
    position = tileMap.getSpawnPosition();
    _target = position.clone();
    tileMap.revealAround(gridX, gridY);

    // --- LOAD SPRITES ---
    final image = await gameRef.images.load('TerrainSpriteSheet.png');
    const double tx = 32.0;

    // Helper to grab sprite (1-based index to match user description)
    Sprite getSprite(int row, int col) {
      return Sprite(
        image,
        srcPosition: Vector2((col - 1) * tx, (row - 1) * tx),
        srcSize: Vector2(tx, tx),
      );
    }

    // Load Player Sprites (Row 7)
    _spriteFront = getSprite(7, 4); // Front/Down/up
    _spriteLeft = getSprite(7, 6);  // Left
    _spriteRight = getSprite(7, 8); // Right
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

    /* --- JOYSTICK LOGIC ---
    if (joystick != null) {
      if (joystick!.direction == JoystickDirection.idle) {
        heldDirection = MoveDirection.none;
      } else {
        // Convert continuous joystick vector to 4-way grid input
        // We check which axis (X or Y) has the stronger pull
        final delta = joystick!.relativeDelta;

        // Add a small threshold to prevent accidental inputs
        if (delta.length > 0.15) {
          if (delta.x.abs() > delta.y.abs()) {
            // Horizontal is dominant
            heldDirection = delta.x < 0 ? MoveDirection.left : MoveDirection.right;
          } else {
            // Vertical is dominant
            heldDirection = delta.y < 0 ? MoveDirection.up : MoveDirection.down;
          }
        }
      }
    }*/

    // --- UPDATE FACING DIRECTION ---
    if (heldDirection == MoveDirection.left) {
      _facing = MoveDirection.left;
    } else if (heldDirection == MoveDirection.right) {
      _facing = MoveDirection.right;
    } else if (heldDirection == MoveDirection.up) {
      _facing = MoveDirection.up;
    } else if (heldDirection == MoveDirection.down) {
      _facing = MoveDirection.down;
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
        if (canFall) _continueFalling(gx, gy);
        return;
      }

      if (heldDirection == MoveDirection.up) {
        // Flying
        if (tile.type == TileType.empty) {
          _isFalling = false;
          _fallStartY = 0;
          _currentFallY = 0;
          _target = _tileCenter(nx, ny);
          _consumeFuel(0.4);
        } else {
          _isFalling = false;
          _fallStartY = 0;
          _currentFallY = 0;
          if (canFall) _continueFalling(gx, gy);
        }
      } else if (heldDirection == MoveDirection.left || heldDirection == MoveDirection.right) {
        // Horizontal
        if (tile.type == TileType.empty) {
          _isFalling = false;
          _fallStartY = 0;
          _currentFallY = 0;
          _target = _tileCenter(nx, ny);
          _consumeFuel(0.5);
        } else if (_canMineTile(tile)) {
          if (_isFalling) _land();
          _digging = true;
          _digX = nx;
          _digY = ny;
          tileMap.startDig(nx, ny);
        } else if (tile.type == TileType.bedrock) {
          if (canFall) _continueFalling(gx, gy);
        } else {
          if (canFall) _continueFalling(gx, gy);
        }
      } else if (heldDirection == MoveDirection.down) {
        // Downward
        if (tile.type == TileType.empty) {
          if (!_isFalling) _startFalling(gy);
          _target = _tileCenter(nx, ny);
        } else if (_canMineTile(tile)) {
          if (_isFalling) _land();
          _digging = true;
          _digX = nx;
          _digY = ny;
          tileMap.startDig(nx, ny);
        }
      }
    } else {
      if (canFall) {
        _continueFalling(gx, gy);
      } else if (_isFalling) {
        _land();
      }
    }
  }

  bool _canMineTile(Tile tile) {
    if (tile.type == TileType.bedrock) return false;
    if (tile.type == TileType.empty) return false;
    return drillbitSystem.canMine(tile.type.hardness);
  }

  void _consumeFuel(double baseCost) {
    final effectiveCost = coolingSystem.getEffectiveFuelCost(baseCost);
    fuelSystem.consume(effectiveCost);
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

    if (!_canMineTile(tile)) {
      _digging = false;
      return;
    }

    final effectiveDigTime = drillbitSystem.getEffectiveDigTime(tile.type.digTime);
    final progress = dt / effectiveDigTime;
    final result = tileMap.updateDig(_digX, _digY, progress);

    if (result != null) {
      if (result.isLethal) {
        hullSystem.takeDamage(9999);
        _digging = false;
        return;
      }

      if (result.isHazard && result.hazardDamage > 0) {
        hullSystem.takeDamage(result.hazardDamage);
      }

      _consumeFuel(result.fuelCost);

      if (result.isOre) {
        economySystem.collectOre(result);
       /* if (gameRef.statsBridge != null) {
          gameRef.statsBridge!.awardForMining(result, depth);
        } else {
          gameRef.xpPointsSystem.awardForMining(result, depth);
        }*/
        // Always go through the bridge — keeps XPPointsSystem and StatsService in sync
        gameRef.statsBridge?.awardForMining(result, depth);

      }
      tileMap.revealAround(_digX, _digY);
      _target = _tileCenter(_digX, _digY);
      _digging = false;
    }
  }

  // ============================================================
  // RENDERING
  // ============================================================

  @override
  void render(Canvas canvas) {
    // 1. Select the correct sprite based on facing
    Sprite spriteToRender = _spriteFront;
    bool rotate180 = false;

    if (_facing == MoveDirection.left) {
      spriteToRender = _spriteLeft;
    } else if (_facing == MoveDirection.right) {
      spriteToRender = _spriteRight;
    } else if (_facing == MoveDirection.up) {
      spriteToRender = _spriteFront;
      rotate180 = true;
    } else {
      spriteToRender = _spriteFront;
    }

    // 2. Prepare paint for visual feedback (Damage/Fuel)
    // We can use a color filter to tint the sprite red if damaged
    final paint = Paint()..color = Colors.white;

    if (hullSystem.isCritical) {
      // Red flash/tint if critical hull
      paint.colorFilter = const ColorFilter.mode(Colors.red, BlendMode.modulate);
    } else if (fuelSystem.isEmpty) {
      // Darken if out of fuel
      paint.colorFilter = const ColorFilter.mode(Colors.grey, BlendMode.modulate);
    }

    // 3. Render the sprite
    // We render into the component's size
    if (rotate180) {
      canvas.save();
      // Rotate around the center of the component
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(math.pi);
      canvas.translate(-size.x / 2, -size.y / 2);
      spriteToRender.render(
        canvas,
        size: size,
        overridePaint: paint,
      );
      canvas.restore();
    } else {
      spriteToRender.render(
        canvas,
        size: size,
        overridePaint: paint,
      );
    }
  }

  void reset() {
    position = tileMap.getSpawnPosition();
    _target = position.clone();
    _digging = false;
    _isFalling = false;
    _fallStartY = 0;
    _currentFallY = 0;
    heldDirection = MoveDirection.none;
    _facing = MoveDirection.down;
    tileMap.revealAround(gridX, gridY);
  }

  void teleportToSurface() {
    position = tileMap.getSpawnPosition();
    _target = position.clone();
    _digging = false;
    _isFalling = false;
    _fallStartY = 0;
    _currentFallY = 0;
    tileMap.revealAround(gridX, gridY);
  }

  void restorePosition(double x , y) {
    position = Vector2(x, y);
    _target = position.clone();
    _digging = false;
    _isFalling = false;
    _fallStartY = 0;
    _currentFallY = 0;
    tileMap.revealAround(gridX, gridY);
  }
}