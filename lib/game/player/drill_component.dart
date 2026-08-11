/// drill_component.dart
/// Smooth movement drill with fall damage
/// Uses sprite sheet for player visual (Front, Left, Right)
import 'dart:math' as math; // Added for PI
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, Paint, BlendMode, ColorFilter;
import '../world/tile_map_component.dart';
import '../world/tile.dart';
import '../systems/fuel_system.dart';
import '../systems/economy_system.dart';
import '../systems/hull_system.dart' show HullSystem, HullLevel;
import '../systems/drillbit_system.dart';
import '../systems/engine_system.dart';
import '../systems/cooling_system.dart';
import '../systems/gear_system.dart'
    show DiggleNFTTraits, GearRarity, GearSlot;
import '../systems/drill_anim.dart';
import '../systems/gear_sprites.dart';
import '../systems/light_system.dart';
import '../systems/vfx_queue.dart';
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

  // NFT gear sprite sheet (layered per-slot rendering when gear is equipped)
  Image? _gearSheet;
  final Map<int, Sprite> _gearSpriteCache = {};

  /// Accumulated animation ticks (seconds x the current band's fps), and
  /// the frame it resolves to. Both are advanced in [update] so [render]
  /// stays free of work — see drill_anim.dart for the band table.
  double _animPhase = 0;
  int _animFrame = 0;

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
  static const double baseNormalSpeed = 120.0;
  static const double baseFlySpeed = 250.0;
  static const double baseFallSpeed = 250.0;
  static const double baseDigSpeed = 2.0;

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

  // Scalar forms for VFX emission, which wants doubles rather than a
  // throwaway Vector2.
  static double _centerOf(int tile) =>
      tile * TileMapComponent.tileSize + TileMapComponent.tileSize / 2;

  /// Ore burst size on a log curve over sell value, so the effect tracks
  /// what the ore is actually worth: coal reads as a puff, diamond as an
  /// event. Linear would make everything below sapphire indistinguishable.
  static double _oreIntensity(TileType ore) {
    final value = ore.value;
    if (value <= 0) return 0.3;
    // log10(5) ~= 0.7 (coal) .. log10(10000) = 4 (diamond).
    return ((math.log(value) / math.ln10 - 0.7) / 3.3).clamp(0.25, 1.0);
  }

  @override
  Future<void> onLoad() async {
    // Initialize Position
    position = tileMap.getSpawnPosition();
    _target = position.clone();
    tileMap.revealAround(gridX, gridY, radius: gameRef.lightSystem.revealRadius);

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

    // NFT gear sheet (layered per-slot sprites, DiggleAssets pixel art)
    _gearSheet = await gameRef.images.load(GearSpriteSheet.asset);
    // gear_sprites.dart is generated but copied by hand, so it can fall out
    // of step with the PNG beside it. That failure is otherwise silent — an
    // invisible or wrongly-framed drill, never an exception.
    assert(
      _gearSheet!.width == GearSpriteSheet.sheetWidth &&
          _gearSheet!.height == GearSpriteSheet.sheetHeight,
      'Gear sheet is ${_gearSheet!.width}x${_gearSheet!.height} but '
      'gear_sprites.dart expects ${GearSpriteSheet.sheetWidth.toInt()}x'
      '${GearSpriteSheet.sheetHeight.toInt()} — re-copy both files from '
      'DiggleAssets/svgart/sprites_out/.',
    );
  }

  Sprite _gearSprite(
    GearSlot slot,
    GearRarity rarity, {
    required bool down,
    required int frame,
  }) {
    final (col, row) =
        GearSpriteSheet.cell(slot, rarity, down: down, frame: frame);
    // Stride must be the sheet's real column count: a hardcoded stride
    // silently collides (wrong slot, no crash) the moment a column index
    // reaches it. GearSpriteSheet.columns is generated alongside the sheet,
    // so it cannot drift.
    final key = row * GearSpriteSheet.columns + col;
    return _gearSpriteCache.putIfAbsent(key, () {
      const cell = GearSpriteSheet.cellSize;
      return Sprite(
        _gearSheet!,
        srcPosition: Vector2(col * cell, row * cell),
        srcSize: Vector2.all(cell),
      );
    });
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

    // --- GEAR ANIMATION PHASE ---
    // Position matters. It is AFTER the game-over returns, so death
    // correctly freezes the machine mid-pose; and BEFORE the `if (_digging)
    // ... return` below, because that early return would otherwise freeze
    // the animation during digs — exactly when the fastest spin belongs.
    final action = drillActionFor(
      digging: _digging,
      flying: heldDirection == MoveDirection.up,
      driving: heldDirection != MoveDirection.none,
      falling: _isFalling,
    );
    _animPhase += dt * kDrillAnimBands[action]!.fps;
    _animFrame = drillFrame(action, _animPhase);

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
      tileMap.revealAround(gridX, gridY, radius: gameRef.lightSystem.revealRadius);
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
    gameRef.achievementSystem.recordDepth(depth);

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

    // Dust on every landing, damaging or not. It is the most frequent
    // movement event in the game and the cheapest way to make it feel
    // physical rather than like a teleport onto the floor.
    gameRef.vfx
        .emitAt(VfxKind.landImpact, position.x, position.y + size.y / 2);

    // Legendary thruster (Quantum Glitch) extends the safe fall distance
    final safeDistance =
        safeFallDistance + gameRef.gearSystem.bonusSafeFallTiles;
    if (fallDistance > safeDistance) {
      final damageTiles = fallDistance - safeDistance;
      final damage = damageTiles * damagePerTile;
      gameRef.vfx.emitAt(VfxKind.hullHit, position.x, position.y,
          intensity: (damage / 60).clamp(0.2, 1.0));
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
      final vfx = gameRef.vfx;
      final tx = _centerOf(_digX);
      final ty = _centerOf(_digY);

      if (result.isLethal) {
        // Lava always scalds visibly. Whether it kills is the Heat Shield's
        // job — and that item had no confirmation it fired at all.
        vfx.emitAt(VfxKind.lavaScald, tx, ty);
        if (!gameRef.heatShieldActive) {
          // The death effect itself is emitted once from _handleGameOver, so
          // it covers running out of fuel too rather than only lava.
          hullSystem.takeDamage(9999);
          _digging = false;
          return;
        }
        vfx.emitAt(VfxKind.shieldAbsorb, tx, ty);
      }

      if (result.isHazard && result.hazardDamage > 0) {
        // Legendary hull (Ghost Stealth) halves gas damage
        final resist =
            result == TileType.gas && gameRef.gearSystem.gasResist ? 0.5 : 1.0;
        // Half-strength burst when the damage is halved, so the legendary
        // hull bonus is visible rather than buried in the hull number.
        vfx.emitAt(VfxKind.gasBurst, tx, ty, intensity: resist);
        vfx.emitAt(VfxKind.hullHit, position.x, position.y,
            intensity: 0.35 * resist);
        hullSystem.takeDamage(result.hazardDamage * resist);
      }

      // Crystal shards pierce weaker hulls; Titanium Hull is immune.
      if (result == TileType.crystalOre) {
        final shardArgb = TileType.crystalOre.color.toARGB32();
        if (hullSystem.hullLevel != HullLevel.level3) {
          vfx.emitAt(VfxKind.crystalShard, tx, ty, argb: shardArgb);
          vfx.emitAt(VfxKind.hullHit, position.x, position.y, intensity: 0.2);
          hullSystem.takeDamage(result.hazardDamage);
        } else {
          // Immune. A different effect entirely, so Titanium Hull reads as
          // protection rather than as nothing having happened.
          vfx.emitAt(VfxKind.shieldAbsorb, tx, ty, argb: shardArgb);
        }
      }

      _consumeFuel(result.fuelCost);

      if (result.isOre) {
        vfx.emitAt(VfxKind.oreBurst, tx, ty,
            argb: result.color.toARGB32(), intensity: _oreIntensity(result));
        economySystem.collectOre(result);
        if (gameRef.statsBridge != null) {
          gameRef.statsBridge!.awardForMining(result, depth);
        } else {
          gameRef.xpPointsSystem.awardForMining(result, depth);
        }
        gameRef.questSystem.onOreMined();
        gameRef.achievementSystem.recordOreMined();
      } else if (result == TileType.lootCrate) {
        gameRef.onLootCrateOpened(_digX, _digY, depth);
      } else if (result == TileType.artifact) {
        gameRef.onArtifactFound(_digX, _digY, depth);
      } else {
        // Plain rock. Ore gets the richer oreBurst instead of this — one
        // effect per dig rather than two muddying each other at the same
        // point (the plan listed both; they overlap badly in practice).
        vfx.emitAt(VfxKind.tileBreak, tx, ty, argb: result.color.toARGB32());
      }

      // Digging can destabilize adjacent unstable rock.
      final collapsed = tileMap.collapseUnstableAround(_digX, _digY);
      if (collapsed.isNotEmpty) {
        // Rubble falling from directly above the dig column hits the drill.
        int hits = 0;
        // Show every collapsed tile, not just the ones that connect — the
        // point is that the ceiling visibly comes down. Capped, because past
        // six the extra bursts are indistinguishable and just eat budget.
        int shown = 0;
        for (final tile in collapsed) {
          if (shown < 6) {
            gameRef.vfx.emitAt(
                VfxKind.rubbleFall, _centerOf(tile.x), _centerOf(tile.y));
            shown++;
          }
          if (tile.x == _digX && tile.y < _digY && _digY - tile.y <= 3) {
            hits++;
          }
        }
        if (hits > 0) {
          // Up to 45 hull damage used to arrive with nothing on screen at
          // all. Trauma scales with the hit count.
          gameRef.vfx.emitAt(VfxKind.hullHit, position.x, position.y,
              intensity: (0.25 * hits).clamp(0.0, 1.0));
          hullSystem.takeDamage((hits * 15.0).clamp(0, 45.0));
        }
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
    // Layered NFT gear rendering when a fully-revealed machine is equipped
    final gear = gameRef.gearSystem.equipped;
    if (gear != null && gear.isComplete && _gearSheet != null) {
      _renderGear(canvas, gear);
      return;
    }

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
    } else {
      // NFT gear rarity tint (until dedicated gear sprites are exported)
      final tint = gameRef.gearSystem.equippedTint;
      if (tint != null) {
        paint.colorFilter = ColorFilter.mode(tint, BlendMode.modulate);
      }
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

  /// Draw the equipped machine as stacked per-slot sprites, in the same
  /// painter's order the NFT reveal art uses. Side cells face right, so
  /// facing left mirrors; up rotates the down view 180° (same convention
  /// as the base sprite).
  void _renderGear(Canvas canvas, DiggleNFTTraits gear) {
    final paint = Paint()..color = Colors.white;
    if (hullSystem.isCritical) {
      paint.colorFilter =
          const ColorFilter.mode(Colors.red, BlendMode.modulate);
    } else if (fuelSystem.isEmpty) {
      paint.colorFilter =
          const ColorFilter.mode(Colors.grey, BlendMode.modulate);
    }

    final side =
        _facing == MoveDirection.left || _facing == MoveDirection.right;
    final mirror = _facing == MoveDirection.left;
    final rotate180 = _facing == MoveDirection.up;

    canvas.save();
    if (mirror) {
      canvas.translate(size.x, 0);
      canvas.scale(-1, 1);
    } else if (rotate180) {
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(math.pi);
      canvas.translate(-size.x / 2, -size.y / 2);
    }
    for (final slot in GearSpriteSheet.drawOrder) {
      final trait = gear.traits[slot];
      if (trait == null) continue;
      // Zero new draw calls: this was already five sprite renders, and a
      // frame only moves srcPosition. The whole cost of Phase B is 40
      // cached Sprites (5 slots x 2 views x 4 frames) and one modulo a tick.
      _gearSprite(slot, trait.rarity, down: !side, frame: _animFrame)
          .render(canvas, size: size, overridePaint: paint);
    }
    canvas.restore();
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
    // Reset the animation HERE only. teleportToSurface and restorePosition
    // deliberately leave the phase running, so the plume does not pop
    // mid-flight; a fresh run is the one place a hard reset is right.
    _animPhase = 0;
    _animFrame = 0;
    tileMap.revealAround(gridX, gridY, radius: gameRef.lightSystem.revealRadius);
  }

  void teleportToSurface() {
    position = tileMap.getSpawnPosition();
    _target = position.clone();
    _digging = false;
    _isFalling = false;
    _fallStartY = 0;
    _currentFallY = 0;
    tileMap.revealAround(gridX, gridY, radius: gameRef.lightSystem.revealRadius);
  }

  void restorePosition(double x , y) {
    position = Vector2(x, y);
    _target = position.clone();
    _digging = false;
    _isFalling = false;
    _fallStartY = 0;
    _currentFallY = 0;
    tileMap.revealAround(gridX, gridY, radius: gameRef.lightSystem.revealRadius);
  }
}