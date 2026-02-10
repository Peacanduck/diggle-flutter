/// tile_map_component.dart
/// Flame component responsible for rendering the tile-based world.
///
/// Key optimizations:
/// - Uses 'compute' to generate the world in a background thread (fixes startup freeze).
/// - Caches Paint objects to prevent Garbage Collection stutter.
/// - Only renders tiles within camera viewport + buffer.
/// - Uses sprite sheet for rendering.

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart'; // Required for compute
import 'package:flutter/material.dart' show Colors, Paint, PaintingStyle;
import 'tile.dart';
import 'world_generator.dart';

/// Top-level function for compute().
/// Must be outside the class to be run in an isolate.
List<List<Tile>> _generateWorldInBackground(WorldConfig config) {
  final generator = WorldGenerator(config: config);
  return generator.generate();
}

class TileMapComponent extends PositionComponent with HasGameRef {
  /// Size of each tile in pixels (Game World Size)
  static const double tileSize = 32.0;

  /// Size of tile on the sprite sheet texture
  static const double textureSize = 32.0;

  /// Extra tiles to render outside viewport (buffer)
  static const int renderBuffer = 2;

  /// The world configuration
  final WorldConfig config;

  /// Initialized to empty to allow safe checks before background gen finishes.
  List<List<Tile>> _grid = [];

  /// Cached world size in pixels
  late Vector2 worldSize;

  /// Map of TileType to their corresponding Sprite
  late Map<TileType, Sprite> _tileSprites;

  /// The raw sprite sheet image
  late Image _spriteSheetImage;

  // --- CACHED PAINTS (Optimization) ---
  // Reusing these prevents creating garbage every frame
  final Paint _fogPaint = Paint()..color = const Color(0xFF0a0a0f);
  final Paint _emptyPaint = Paint()..color = const Color(0xFF1a1a2e);
  final Paint _fallbackPaint = Paint()..color = const Color(0xFFFF00FF); // Hot pink for errors
  final Paint _digOverlayPaint = Paint(); // Color updated dynamically, object reused
  final Paint _digBarPaint = Paint()..color = Colors.yellow.withOpacity(0.8);

  TileMapComponent({required this.config});

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  Future<void> onLoad() async {
    // 1. Generate the world in a background isolate to prevent UI freeze (old)
    // This fixes the "Skipped 129 frames" log at startup
    //_grid = await compute(_generateWorldInBackground, config);

    // 1. Initialize worldSize immediately (Synchronous) (new)
    // This MUST happen before any await calls to prevent LateInitializationError

    // 2. Calculate world size
    worldSize = Vector2(
      config.width * tileSize,
      config.height * tileSize,
    );

    // 3. Set component size
    size = worldSize;

    // 4. Load Sprite Sheet
    _spriteSheetImage = await gameRef.images.load('TerrainSpriteSheet.png');
    _loadSprites();
  }

  /// Maps specific grid locations to TileTypes based on your 13x13 sheet.
  Future<void> _loadSprites() async {
    _tileSprites = {};


    // 3. Generate the world in a background isolate to prevent UI freeze
    // The render loop will simply skip drawing (because _grid is empty) until this finishes.
    _grid = await compute(_generateWorldInBackground, config);

    Sprite getSprite(int row, int col) {
      return Sprite(
        _spriteSheetImage,
        srcPosition: Vector2(
          (col - 1) * textureSize,
          (row - 1) * textureSize,
        ),
        srcSize: Vector2(textureSize, textureSize),
      );
    }

    // --- MAPPING CONFIGURATION ---
    // Row 3 (Index 2): Cols 2, 4, 6, 8, 10, 12
    _tileSprites[TileType.dirt]     = getSprite(3, 2);
    _tileSprites[TileType.rock]     = getSprite(3, 4);
    _tileSprites[TileType.coal]     = getSprite(3, 8);
    _tileSprites[TileType.copper]   = getSprite(3, 10);
    _tileSprites[TileType.silver]   = getSprite(3, 12);
    _tileSprites[TileType.gold]     = getSprite(5, 2);

    // Row 5 (Index 4): Cols 2, 4, 6, 8, 10, 12
    _tileSprites[TileType.sapphire] = getSprite(5, 4);
    _tileSprites[TileType.emerald]  = getSprite(5, 6);
    _tileSprites[TileType.ruby]     = getSprite(5, 8);
    _tileSprites[TileType.diamond]  = getSprite(5, 10);
    _tileSprites[TileType.bedrock]  = getSprite(3, 6);
    _tileSprites[TileType.lava]     = getSprite(5, 12);

    // Row 7 (Index 6): Col 2
    _tileSprites[TileType.gas]      = getSprite(7, 2);
  }

  // ============================================================
  // RENDERING
  // ============================================================

  @override
  void render(Canvas canvas) {
    // Safety check if grid isn't loaded yet (due to async compute)
    if (_grid.isEmpty) return;

    // Get camera viewport bounds to optimize rendering
    final camera = gameRef.camera;
    final visibleRect = camera.visibleWorldRect;

    // Calculate visible tile range with clamping
    final startX = ((visibleRect.left / tileSize).floor() - renderBuffer)
        .clamp(0, config.width - 1);
    final endX = ((visibleRect.right / tileSize).ceil() + renderBuffer)
        .clamp(0, config.width - 1);
    final startY = ((visibleRect.top / tileSize).floor() - renderBuffer)
        .clamp(0, config.height - 1);
    final endY = ((visibleRect.bottom / tileSize).ceil() + renderBuffer)
        .clamp(0, config.height - 1);

    // Render loop
    for (int x = startX; x <= endX; x++) {
      for (int y = startY; y <= endY; y++) {
        _renderTile(canvas, _grid[x][y]);
      }
    }
  }

  /// Render a single tile
  void _renderTile(Canvas canvas, Tile tile) {
    final position = Vector2(tile.x * tileSize, tile.y * tileSize);
    final size = Vector2.all(tileSize);

    // 1. Fog of war
    if (!tile.isRevealed) {
      canvas.drawRect(
        Rect.fromLTWH(position.x, position.y, tileSize, tileSize),
        _fogPaint,
      );
      return;
    }

    // 2. Render Tile Sprite
    if (tile.type == TileType.empty) {
      canvas.drawRect(
        Rect.fromLTWH(position.x, position.y, tileSize, tileSize),
        _emptyPaint,
      );
    } else {
      final sprite = _tileSprites[tile.type];
      if (sprite != null) {
        sprite.render(
          canvas,
          position: position,
          size: size,
        );
      } else {
        // Fallback for missing sprites
        canvas.drawRect(
          Rect.fromLTWH(position.x, position.y, tileSize, tileSize),
          _fallbackPaint,
        );
      }
    }

    // 3. Render Dig Progress
    if (tile.isBeingDug && tile.digProgress > 0) {
      _renderDigProgress(canvas, tile, position);
    }
  }

  /// Render dig progress overlay
  void _renderDigProgress(Canvas canvas, Tile tile, Vector2 position) {
    // Update color opacity without creating new Paint object
    // Note: 0.6 opacity (153 alpha)
    _digOverlayPaint.color = const Color(0xFF000000).withOpacity(tile.digProgress * 0.6);

    canvas.drawRect(
      Rect.fromLTWH(position.x, position.y, tileSize, tileSize),
      _digOverlayPaint,
    );

    final barHeight = 4.0;
    final barRect = Rect.fromLTWH(
      position.x + 2,
      position.y + tileSize - barHeight - 2,
      (tileSize - 4) * tile.digProgress,
      barHeight,
    );
    canvas.drawRect(barRect, _digBarPaint);
  }

  // ============================================================
  // TILE QUERIES & LOGIC
  // ============================================================

  Tile? getTileAt(int x, int y) {
    if (!_isInBounds(x, y)) return null;
    return _grid[x][y];
  }

  Tile? getTileAtPosition(Vector2 worldPos) {
    final gridX = (worldPos.x / tileSize).floor();
    final gridY = (worldPos.y / tileSize).floor();
    return getTileAt(gridX, gridY);
  }

  bool _isInBounds(int x, int y) {
    // Check if grid is initialized
    try {
      if (_grid.isEmpty) return false;
      return x >= 0 && x < config.width && y >= 0 && y < config.height;
    } catch (e) {
      return false;
    }
  }

  Vector2 getSpawnPosition() {
    return Vector2(
      (config.width / 2) * tileSize + (tileSize / 2),
      (config.surfaceRows - 1) * tileSize + (tileSize / 2),
    );
  }

  void revealAround(int centerX, int centerY, {int radius = 1}) {
    for (int dx = -radius; dx <= radius; dx++) {
      for (int dy = -radius; dy <= radius; dy++) {
        final x = centerX + dx;
        final y = centerY + dy;
        if (_isInBounds(x, y)) {
          _grid[x][y].isRevealed = true;
        }
      }
    }
  }

  void startDig(int x, int y) {
    if (!_isInBounds(x, y)) return;
    final tile = _grid[x][y];
    if (tile.type.isDiggable) {
      tile.isBeingDug = true;
    }
  }

  TileType? updateDig(int x, int y, double deltaProgress) {
    if (!_isInBounds(x, y)) return null;
    final tile = _grid[x][y];
    if (!tile.isBeingDug) return null;

    tile.digProgress += deltaProgress;

    if (tile.digProgress >= 1.0) {
      final dugType = tile.type;
      tile.completeDig();
      return dugType;
    }
    return null;
  }

  void cancelDig(int x, int y) {
    if (!_isInBounds(x, y)) return;
    _grid[x][y].resetDig();
  }

  bool isAtSurface(int gridY) {
    return gridY <= config.surfaceRows;
  }

  List<TileType> explode(int centerX, int centerY, int radius) {
    final destroyedOres = <TileType>[];
    for (int dx = -radius; dx <= radius; dx++) {
      for (int dy = -radius; dy <= radius; dy++) {
        final x = centerX + dx;
        final y = centerY + dy;
        if (!_isInBounds(x, y)) continue;
        final tile = _grid[x][y];
        if (tile.type == TileType.bedrock || tile.type == TileType.empty) continue;
        if (tile.type.isOre) {
          destroyedOres.add(tile.type);
        }
        tile.type = TileType.empty;
        tile.isRevealed = true;
        tile.resetDig();
      }
    }
    revealAround(centerX, centerY, radius: radius + 1);
    return destroyedOres;
  }

  void reset() async {
    // Also use compute for reset!
    // Clear grid first to prevent rendering old data or race conditions
    _grid = [];
    _grid = await compute(_generateWorldInBackground, config);
    // Force redraw or state update if necessary
  }

  Uint8List exportBytes() {
    final bytes = Uint8List(config.width * config.height);
    int i = 0;
    for (int x = 0; x < config.width; x++) {
      for (int y = 0; y < config.height; y++) {
        bytes[i++] = _grid[x][y].type.index;
      }
    }
    return bytes;
  }

  void importBytes(Uint8List bytes) {
    if (bytes.length != config.width * config.height) {
      throw ArgumentError(
        'importBytes: expected ${config.width * config.height} bytes, '
            'got ${bytes.length}',
      );
    }
    // If importing, we likely need to ensure _grid is initialized
    if (_grid.isEmpty) {
      // We can't import into an empty grid structure.
      // We must wait for generation or force basic generation locally.
      // For now, let's assume importBytes is called after load.
      return;
    }

    int i = 0;
    for (int x = 0; x < config.width; x++) {
      for (int y = 0; y < config.height; y++) {
        final typeIndex = bytes[i++];
        if (typeIndex < TileType.values.length) {
          _grid[x][y].type = TileType.values[typeIndex];
        }
        _grid[x][y].isRevealed = y < config.surfaceRows;
        _grid[x][y].resetDig();
      }
    }
    revealAround(config.width ~/ 2, config.surfaceRows, radius: 2);
  }
}