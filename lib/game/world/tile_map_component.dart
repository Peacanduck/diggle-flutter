/// tile_map_component.dart
/// Flame component responsible for rendering the tile-based world.
///
/// Key optimizations:
/// - Only renders tiles within camera viewport + buffer
/// - Culls tiles outside visible area
/// - Uses simple colored rectangles (can be upgraded to sprites)
///
/// The TileMapComponent owns the world grid and provides methods
/// for tile queries and modifications.

import 'dart:typed_data';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;
import 'tile.dart';
import 'world_generator.dart';

/// Renders and manages the tile-based world
class TileMapComponent extends PositionComponent with HasGameRef {
  /// Size of each tile in pixels
  static const double tileSize = 32.0;

  /// Extra tiles to render outside viewport (buffer)
  static const int renderBuffer = 2;

  /// The world configuration
  final WorldConfig config;

  /// 2D grid of tiles [x][y]
  late List<List<Tile>> _grid;

  /// Cached world size in pixels
  late Vector2 worldSize;

  TileMapComponent({required this.config});

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  Future<void> onLoad() async {
    // Generate the world
    final generator = WorldGenerator(config: config);
    _grid = generator.generate();

    // Calculate world size
    worldSize = Vector2(
      config.width * tileSize,
      config.height * tileSize,
    );

    // Set component size
    size = worldSize;
  }

  // ============================================================
  // RENDERING
  // ============================================================

  @override
  void render(Canvas canvas) {
    // Get camera viewport bounds
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

    // Render only visible tiles
    for (int x = startX; x <= endX; x++) {
      for (int y = startY; y <= endY; y++) {
        _renderTile(canvas, _grid[x][y]);
      }
    }
  }

  /// Render a single tile
  void _renderTile(Canvas canvas, Tile tile) {
    final rect = Rect.fromLTWH(
      tile.x * tileSize,
      tile.y * tileSize,
      tileSize,
      tileSize,
    );

    // Fog of war - hidden tiles
    if (!tile.isRevealed) {
      canvas.drawRect(
        rect,
        Paint()..color = const Color(0xFF0a0a0f),
      );
      return;
    }

    // Main tile color
    canvas.drawRect(
      rect,
      Paint()..color = tile.type.color,
    );

    // Add visual detail for non-empty tiles
    if (tile.type != TileType.empty) {
      _renderTileDetail(canvas, tile, rect);
    }

    // Dig progress indicator
    if (tile.isBeingDug && tile.digProgress > 0) {
      _renderDigProgress(canvas, tile, rect);
    }
  }

  /// Add visual detail/texture to tiles
  void _renderTileDetail(Canvas canvas, Tile tile, Rect rect) {
    final highlightPaint = Paint()
      ..color = tile.type.highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Inner highlight for depth effect
    final innerRect = Rect.fromLTWH(
      rect.left + 2,
      rect.top + 2,
      rect.width - 4,
      rect.height - 4,
    );
    canvas.drawRect(innerRect, highlightPaint);

    // Ore sparkle effect
    if (tile.type.isOre) {
      _renderOreSparkle(canvas, tile, rect);
    }
  }

  /// Render sparkle effect on ore tiles
  void _renderOreSparkle(Canvas canvas, Tile tile, Rect rect) {
    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Small sparkle dot
    final sparkleSize = 3.0;
    canvas.drawCircle(
      Offset(rect.left + 8, rect.top + 8),
      sparkleSize,
      sparklePaint,
    );
  }

  /// Render dig progress overlay
  void _renderDigProgress(Canvas canvas, Tile tile, Rect rect) {
    // Darken tile based on progress
    final progressPaint = Paint()
      ..color = Colors.black.withOpacity(tile.digProgress * 0.5);
    canvas.drawRect(rect, progressPaint);

    // Progress bar at bottom of tile
    final barHeight = 4.0;
    final barRect = Rect.fromLTWH(
      rect.left,
      rect.bottom - barHeight,
      rect.width * tile.digProgress,
      barHeight,
    );
    canvas.drawRect(
      barRect,
      Paint()..color = Colors.yellow.withOpacity(0.8),
    );
  }

  // ============================================================
  // TILE QUERIES
  // ============================================================

  /// Get tile at grid coordinates (null if out of bounds)
  Tile? getTileAt(int x, int y) {
    if (!_isInBounds(x, y)) return null;
    return _grid[x][y];
  }

  /// Get tile at world position (null if out of bounds)
  Tile? getTileAtPosition(Vector2 worldPos) {
    final gridX = (worldPos.x / tileSize).floor();
    final gridY = (worldPos.y / tileSize).floor();
    return getTileAt(gridX, gridY);
  }

  /// Check if coordinates are within world bounds
  bool _isInBounds(int x, int y) {
    return x >= 0 && x < config.width && y >= 0 && y < config.height;
  }

  /// Get the player spawn position (center of surface, above ground)
  Vector2 getSpawnPosition() {
    // Spawn in the last empty row (surfaceRows - 1), not in the dirt
    return Vector2(
      (config.width / 2) * tileSize + (tileSize / 2),
      (config.surfaceRows - 1) * tileSize + (tileSize / 2),
    );
  }

  // ============================================================
  // TILE MODIFICATIONS
  // ============================================================

  /// Reveal tiles around a position
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

  /// Start digging a tile
  void startDig(int x, int y) {
    if (!_isInBounds(x, y)) return;
    final tile = _grid[x][y];
    if (tile.type.isDiggable) {
      tile.isBeingDug = true;
    }
  }

  /// Update dig progress on a tile
  /// Returns the tile type if dig completed, null otherwise
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

  /// Cancel digging a tile
  void cancelDig(int x, int y) {
    if (!_isInBounds(x, y)) return;
    _grid[x][y].resetDig();
  }

  /// Check if a position is at the surface (shop area)
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

  /// Reset the world (for game restart)
  void reset() {
    final generator = WorldGenerator(config: config);
    _grid = generator.generate();
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