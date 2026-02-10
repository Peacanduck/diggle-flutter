/// tile_map_component.dart
/// Flame component responsible for rendering the tile-based world.
///
/// Key optimizations:
/// - Only renders tiles within camera viewport + buffer
/// - Culls tiles outside visible area
/// - Uses specific sprites from a 13x13 grid sheet
///
/// The TileMapComponent owns the world grid and provides methods
/// for tile queries and modifications.

import 'dart:typed_data';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/flame.dart'; // Needed for image loading
import 'package:flutter/material.dart' show Colors, Paint, PaintingStyle;
import 'tile.dart';
import 'world_generator.dart';

/// Renders and manages the tile-based world
class TileMapComponent extends PositionComponent with HasGameRef {
  /// Size of each tile in pixels (Game World Size)
  static const double tileSize = 32.0;

  /// Size of tile on the sprite sheet texture
  static const double textureSize = 32.0;

  /// Extra tiles to render outside viewport (buffer)
  static const int renderBuffer = 2;

  /// The world configuration
  final WorldConfig config;

  /// 2D grid of tiles [x][y]
  late List<List<Tile>> _grid;

  /// Cached world size in pixels
  late Vector2 worldSize;

  /// Map of TileType to their corresponding Sprite
  late Map<TileType, Sprite> _tileSprites;

  /// The raw sprite sheet image
  late Image _spriteSheetImage;

  TileMapComponent({required this.config});

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  Future<void> onLoad() async {
    // 1. Generate the world
    final generator = WorldGenerator(config: config);
    _grid = generator.generate();

    // 2. Calculate world size
    worldSize = Vector2(
      config.width * tileSize,
      config.height * tileSize,
    );

    // 3. Set component size
    size = worldSize;

    // 4. Load Sprite Sheet and Create Sprites
    // Ensure you have 'tiles.png' in assets/images/
    _spriteSheetImage = await gameRef.images.load('TerrainSpriteSheet.png');
    _loadSprites();
  }

  /// Maps specific grid locations to TileTypes based on your 13x13 sheet.
  /// Note: Input is 1-based (User description), converted to 0-based for code.
  void _loadSprites() {
    _tileSprites = {};

    // Helper to cut a sprite from the sheet
    // row and col are 1-based integers as described in your prompt
    Sprite getSprite(int row, int col) {
      return Sprite(
        _spriteSheetImage,
        srcPosition: Vector2(
          (col - 1) * textureSize, // Convert 1-based Col to 0-based X index
          (row - 1) * textureSize, // Convert 1-based Row to 0-based Y index
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
    if (_grid.isEmpty) return;

    // Get camera viewport bounds to optimize rendering
    final camera = gameRef.camera;
    final visibleRect = camera.visibleWorldRect;

    // Calculate visible tile range
    final startX = ((visibleRect.left / tileSize).floor() - renderBuffer)
        .clamp(0, config.width - 1);
    final endX = ((visibleRect.right / tileSize).ceil() + renderBuffer)
        .clamp(0, config.width - 1);
    final startY = ((visibleRect.top / tileSize).floor() - renderBuffer)
        .clamp(0, config.height - 1);
    final endY = ((visibleRect.bottom / tileSize).ceil() + renderBuffer)
        .clamp(0, config.height - 1);

    // Pre-calculate paint for fog to avoid recreating it every loop
    final fogPaint = Paint()..color = const Color(0xFF0a0a0f);
    final emptyPaint = Paint()..color = const Color(0xFF1a1a2e);

    // Render loop
    for (int x = startX; x <= endX; x++) {
      for (int y = startY; y <= endY; y++) {
        _renderTile(canvas, _grid[x][y], fogPaint, emptyPaint);
      }
    }
  }

  /// Render a single tile
  void _renderTile(Canvas canvas, Tile tile, Paint fogPaint, Paint emptyPaint) {
    // Calculate render position
    // We use drawImage or sprite.render which is more efficient than creating Rects manually if using SpriteBatch,
    // but for simple sprite rendering, a position or rect is fine.
    final position = Vector2(tile.x * tileSize, tile.y * tileSize);
    final size = Vector2.all(tileSize);

    // 1. Fog of war - Render black box if hidden
    if (!tile.isRevealed) {
      canvas.drawRect(
        Rect.fromLTWH(position.x, position.y, tileSize, tileSize),
        fogPaint,
      );
      return;
    }

    // 2. Render Tile Sprite
    if (tile.type == TileType.empty) {
      // Draw background color for empty space
      canvas.drawRect(
        Rect.fromLTWH(position.x, position.y, tileSize, tileSize),
        emptyPaint,
      );
    } else {
      // Draw the sprite
      final sprite = _tileSprites[tile.type];
      if (sprite != null) {
        sprite.render(
          canvas,
          position: position,
          size: size,
        );
      } else {
        // Fallback if sprite missing (debug pink)
        canvas.drawRect(
          Rect.fromLTWH(position.x, position.y, tileSize, tileSize),
          Paint()..color = Colors.pink,
        );
      }
    }

    // 3. Render Cracks (Dig Progress)
    if (tile.isBeingDug && tile.digProgress > 0) {
      _renderDigProgress(canvas, tile, position);
    }
  }

  /// Render dig progress overlay (cracks or darkening)
  void _renderDigProgress(Canvas canvas, Tile tile, Vector2 position) {
    // Darken tile based on progress
    final progressPaint = Paint()
      ..color = Colors.black.withOpacity(tile.digProgress * 0.6);

    canvas.drawRect(
      Rect.fromLTWH(position.x, position.y, tileSize, tileSize),
      progressPaint,
    );

    // Optional: Render a small progress bar at the bottom
    final barHeight = 4.0;
    final barRect = Rect.fromLTWH(
      position.x + 2,
      position.y + tileSize - barHeight - 2,
      (tileSize - 4) * tile.digProgress,
      barHeight,
    );
    canvas.drawRect(
      barRect,
      Paint()..color = Colors.yellow.withOpacity(0.8),
    );
  }

  // ============================================================
  // TILE QUERIES & LOGIC (Unchanged)
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
    return x >= 0 && x < config.width && y >= 0 && y < config.height;
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

  /// Explode tiles in a radius around a point (except bedrock)
  /// Returns list of ore types that were destroyed
  List<TileType> explode(int centerX, int centerY, int radius) {
    final destroyedOres = <TileType>[];
    for (int dx = -radius; dx <= radius; dx++) {
      for (int dy = -radius; dy <= radius; dy++) {
        final x = centerX + dx;
        final y = centerY + dy;
        if (!_isInBounds(x, y)) continue;
        final tile = _grid[x][y];
        // Skip bedrock and empty tiles
        if (tile.type == TileType.bedrock || tile.type == TileType.empty) continue;
        // Track ores that get destroyed (no collection)
        if (tile.type.isOre) {
          destroyedOres.add(tile.type);
        }

        // Destroy the tile
        tile.type = TileType.empty;
        tile.isRevealed = true;
        tile.resetDig();
      }
    }

    // Reveal area around explosion
    revealAround(centerX, centerY, radius: radius + 1);
    return destroyedOres;
  }

  void reset() {
    final generator = WorldGenerator(config: config);
    _grid = generator.generate();
    // We don't need to reload sprites on reset, they remain cached
  }

  // ============================================================
  // PERSISTENCE
  // ============================================================

  /// Export the tile grid as a flat byte array.
  /// Each byte is the TileType index for that cell.
  /// Layout: row-major order — for x in 0..width, for y in 0..height.

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

  /// Import a previously exported byte array, restoring tile types.
  /// Revealed/dig state is reset — only terrain is restored.
  void importBytes(Uint8List bytes) {
    if (bytes.length != config.width * config.height) {
      throw ArgumentError(
        'importBytes: expected ${config.width * config.height} bytes, '
            'got ${bytes.length}',
      );
    }
    int i = 0;
    for (int x = 0; x < config.width; x++) {
      for (int y = 0; y < config.height; y++) {
        final typeIndex = bytes[i++];
        if (typeIndex < TileType.values.length) {
          _grid[x][y].type = TileType.values[typeIndex];
        }
        // Re-reveal surface rows
        _grid[x][y].isRevealed = y < config.surfaceRows;
        _grid[x][y].resetDig();
      }
    }

    // Re-reveal around spawn
    revealAround(config.width ~/ 2, config.surfaceRows, radius: 2);
  }
}