/// tile_map_component.dart
/// Flame component responsible for rendering the tile-based world.
///
/// Key optimizations:
/// - Uses 'compute' to generate the world in a background thread (fixes startup freeze).
/// - Caches Paint objects to prevent Garbage Collection stutter.
/// - Only renders tiles within camera viewport + buffer.
/// - Uses sprite sheet for rendering.

import 'dart:async';
//import 'dart:typed_data';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart'; // Required for compute
import 'package:flutter/material.dart' show Colors, Paint;
import 'biome.dart';
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
  final Paint _fallbackPaint = Paint()..color = const Color(0xFFFF00FF); // Hot pink for errors
  final Paint _digOverlayPaint = Paint(); // Color updated dynamically, object reused
  final Paint _digBarPaint = Paint()..color = Colors.yellow.withOpacity(0.8);

  // --- CACHED RENDER SCRATCH (Optimization) ---
  // Every tile is the same size, and Sprite.render copies out of the vectors
  // it is handed (into its own statics) before returning, so one shared pair
  // is safe and removes ~36k Vector2 allocations/sec at ~300 culled tiles.
  static final Vector2 _tileSizeVector = Vector2.all(tileSize);
  final Vector2 _tilePosition = Vector2.zero();

  // Procedural tile shapes, built once at the origin and positioned with a
  // canvas translate. A fresh Path per tile per frame was the hot spot in
  // crystal biomes.
  static final Path _crystalPath = Path()
    ..moveTo(8, tileSize - 4)
    ..lineTo(12, 6)
    ..lineTo(16, tileSize - 4)
    ..close()
    ..moveTo(17, tileSize - 4)
    ..lineTo(22, 12)
    ..lineTo(26, tileSize - 4)
    ..close();

  static final Path _artifactPath = Path()
    ..moveTo(tileSize / 2, tileSize / 2 - 9)
    ..lineTo(tileSize / 2 + 7, tileSize / 2)
    ..lineTo(tileSize / 2, tileSize / 2 + 9)
    ..lineTo(tileSize / 2 - 7, tileSize / 2)
    ..close();

  // Per-biome cached paints (empty/cave background + band tint overlay)
  final Map<String, Paint> _caveColorPaints = {};
  final Map<String, Paint> _biomeTintPaints = {};
  // Procedural paints for tiles without sprites (new v2 tile types)
  final Map<TileType, Paint> _baseColorPaints = {};
  final Map<TileType, Paint> _highlightColorPaints = {};

  TileMapComponent({required this.config});

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  Future<void> onLoad() async {
    // 1. Initialize worldSize immediately (Synchronous)
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

  /// Builds _tileSprites from TileType.spriteRow / spriteCol (single source of truth in tile.dart).
  Future<void> _loadSprites() async {
    _tileSprites = {};

    // Generate the world in a background isolate to prevent UI freeze.
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

    // --- AUTO-MAP from TileType extension getters ---
    for (final type in TileType.values) {
      final row = type.spriteRow;
      final col = type.spriteCol;
      if (row != null && col != null) {
        _tileSprites[type] = getSprite(row, col);
      }
    }

    // Cache procedural paints for sprite-less tiles and biome overlays.
    // strokeWidth is per-TileType and never changes, and these Paints are
    // keyed per type, so it belongs here rather than in the render loop.
    for (final type in TileType.values) {
      if (type == TileType.empty || _tileSprites.containsKey(type)) continue;
      _baseColorPaints[type] = Paint()..color = type.color;
      _highlightColorPaints[type] = Paint()
        ..color = type.highlightColor
        ..strokeWidth = type == TileType.lootCrate ? 3.0 : 2.0;
    }
    for (final biome in Biome.strata) {
      _caveColorPaints[biome.name] = Paint()..color = biome.caveColor;
      if (biome.tint.alpha > 0) {
        _biomeTintPaints[biome.name] = Paint()..color = biome.tint;
      }
    }
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
    final px = tile.x * tileSize;
    final py = tile.y * tileSize;

    // 1. Fog of war
    if (!tile.isRevealed) {
      canvas.drawRect(
        Rect.fromLTWH(px, py, tileSize, tileSize),
        _fogPaint,
      );
      return;
    }

    final depth = tile.y - config.surfaceRows;
    final biome = Biome.atDepth(depth < 0 ? 0 : depth);
    final rect = Rect.fromLTWH(px, py, tileSize, tileSize);

    // 2. Render Tile Sprite
    if (tile.type == TileType.empty) {
      final cavePaint = _caveColorPaints[biome.name];
      canvas.drawRect(rect, cavePaint ?? _fogPaint);
    } else {
      final sprite = _tileSprites[tile.type];
      if (sprite != null) {
        sprite.render(
          canvas,
          position: _tilePosition..setValues(px, py),
          size: _tileSizeVector,
        );
      } else if (_baseColorPaints.containsKey(tile.type)) {
        // Procedural rendering for v2 tiles without sprite art
        _renderProceduralTile(canvas, tile, rect);
      } else {
        // Fallback for missing sprites
        canvas.drawRect(rect, _fallbackPaint);
      }
      // Biome band tint so each stratum reads visually distinct
      final tintPaint = _biomeTintPaints[biome.name];
      if (tintPaint != null) {
        canvas.drawRect(rect, tintPaint);
      }
    }

    // 3. Render Dig Progress
    if (tile.isBeingDug && tile.digProgress > 0) {
      _renderDigProgress(canvas, tile, px, py);
    }
  }

  /// Draws v2 tile types (crystal, crate, artifact, etc.) with simple
  /// canvas shapes until dedicated sprite art is added to the sheet.
  void _renderProceduralTile(Canvas canvas, Tile tile, Rect rect) {
    final base = _baseColorPaints[tile.type]!;
    final highlight = _highlightColorPaints[tile.type]!;
    canvas.drawRect(rect, base);

    switch (tile.type) {
      case TileType.crystalOre:
        // Two crystal shards
        canvas.save();
        canvas.translate(rect.left, rect.top);
        canvas.drawPath(_crystalPath, highlight);
        canvas.restore();
        break;
      case TileType.lootCrate:
        // Crate: border + diagonal band
        canvas.drawRect(rect.deflate(3), highlight);
        canvas.drawRect(rect.deflate(6), base);
        canvas.drawLine(
          Offset(rect.left + 4, rect.top + 4),
          Offset(rect.right - 4, rect.bottom - 4),
          highlight,
        );
        break;
      case TileType.artifact:
        // Golden diamond shape on dark base
        canvas.save();
        canvas.translate(rect.left, rect.top);
        canvas.drawPath(_artifactPath, highlight);
        canvas.restore();
        break;
      case TileType.unstableRock:
        // Cracked look: jagged lines
        canvas.drawLine(
          Offset(rect.left + 6, rect.top + 4),
          Offset(rect.left + 14, rect.bottom - 10),
          highlight,
        );
        canvas.drawLine(
          Offset(rect.left + 14, rect.bottom - 10),
          Offset(rect.right - 6, rect.bottom - 4),
          highlight,
        );
        break;
      default:
        // frozenDirt / magmaRock: speckled texture
        final hash = (tile.x * 31 + tile.y * 17) & 0x7fffffff;
        for (int i = 0; i < 3; i++) {
          final px = rect.left + 4 + ((hash >> (i * 4)) % 22);
          final py = rect.top + 4 + ((hash >> (i * 4 + 2)) % 22);
          canvas.drawRect(Rect.fromLTWH(px.toDouble(), py.toDouble(), 3, 3),
              highlight);
        }
        break;
    }
  }

  /// Render dig progress overlay
  void _renderDigProgress(Canvas canvas, Tile tile, double px, double py) {
    // Update color opacity without creating new Paint object
    // Note: 0.6 opacity (153 alpha)
    _digOverlayPaint.color = const Color(0xFF000000).withOpacity(tile.digProgress * 0.6);

    canvas.drawRect(
      Rect.fromLTWH(px, py, tileSize, tileSize),
      _digOverlayPaint,
    );

    final barHeight = 4.0;
    final barRect = Rect.fromLTWH(
      px + 2,
      py + tileSize - barHeight - 2,
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

  /// Detonate an explosion. Gas pockets caught in the blast chain-react
  /// with their own radius-1 explosion. Returns all destroyed ore types
  /// (the caller decides how much of the yield survives the blast).
  List<TileType> explode(int centerX, int centerY, int radius) {
    final destroyedOres = <TileType>[];
    // Queue of (x, y, radius) blasts; gas chain reactions append to it.
    final pending = <List<int>>[
      [centerX, centerY, radius]
    ];
    // Cap total chained blasts to keep pathological gas fields bounded.
    int blastsLeft = 16;

    while (pending.isNotEmpty && blastsLeft > 0) {
      blastsLeft--;
      final blast = pending.removeAt(0);
      final bx = blast[0], by = blast[1], br = blast[2];

      for (int dx = -br; dx <= br; dx++) {
        for (int dy = -br; dy <= br; dy++) {
          final x = bx + dx;
          final y = by + dy;
          if (!_isInBounds(x, y)) continue;
          final tile = _grid[x][y];
          if (tile.type == TileType.bedrock || tile.type == TileType.empty) {
            continue;
          }
          if (tile.type == TileType.gas && !(dx == 0 && dy == 0)) {
            // Chain reaction: gas pocket detonates
            pending.add([x, y, 1]);
          }
          if (tile.type.isOre) {
            destroyedOres.add(tile.type);
          }
          tile.type = TileType.empty;
          tile.isRevealed = true;
          tile.resetDig();
        }
      }
      revealAround(bx, by, radius: br + 1);
    }
    return destroyedOres;
  }

  /// Cascade-collapse unstable rock adjacent to (x, y).
  /// Returns the tiles that crumbled so the caller can apply falling-rock
  /// damage. Cascade is capped to avoid runaway chains.
  List<Tile> collapseUnstableAround(int x, int y) {
    final collapsed = <Tile>[];
    final toCheck = <List<int>>[
      [x, y]
    ];
    const maxCollapse = 12;

    while (toCheck.isNotEmpty && collapsed.length < maxCollapse) {
      final pos = toCheck.removeAt(0);
      const neighbors = [
        [0, -1],
        [0, 1],
        [-1, 0],
        [1, 0],
      ];
      for (final d in neighbors) {
        final nx = pos[0] + d[0];
        final ny = pos[1] + d[1];
        if (!_isInBounds(nx, ny)) continue;
        final tile = _grid[nx][ny];
        if (tile.type != TileType.unstableRock) continue;
        tile.type = TileType.empty;
        tile.isRevealed = true;
        tile.resetDig();
        collapsed.add(tile);
        toCheck.add([nx, ny]);
      }
    }
    if (collapsed.isNotEmpty) {
      revealAround(x, y, radius: 2);
    }
    return collapsed;
  }

  void reset() async {
    // Also use compute for reset!
    // Clear grid first to prevent rendering old data or race conditions
    _grid = [];
    _grid = await compute(_generateWorldInBackground, config);
    // Force redraw or state update if necessary
  }

  // ============================================================
  // SERIALIZATION
  // ============================================================
  // Format v1: [version byte = 1][width*height tile type indexes].
  // Legacy (pre-versioning) saves are exactly width*height bytes with
  // no header and are still importable.
  //
  // TileType enum values MUST be append-only or old saves corrupt.

  static const int _serializationVersion = 1;

  /// Encode a tile grid to bytes (static for unit testing).
  static Uint8List encodeTileGrid(List<List<Tile>> grid, WorldConfig config) {
    final bytes = Uint8List(1 + config.width * config.height);
    bytes[0] = _serializationVersion;
    int i = 1;
    for (int x = 0; x < config.width; x++) {
      for (int y = 0; y < config.height; y++) {
        bytes[i++] = grid[x][y].type.index;
      }
    }
    return bytes;
  }

  /// Decode bytes into an existing grid (static for unit testing).
  /// Accepts both versioned (v1) and legacy headerless payloads.
  static void decodeTileGrid(
      Uint8List bytes, List<List<Tile>> grid, WorldConfig config) {
    final tileCount = config.width * config.height;
    int offset;
    if (bytes.length == tileCount + 1 && bytes[0] == _serializationVersion) {
      offset = 1;
    } else if (bytes.length == tileCount) {
      offset = 0; // legacy save without version byte
    } else {
      throw ArgumentError(
        'decodeTileGrid: expected $tileCount or ${tileCount + 1} bytes, '
        'got ${bytes.length}',
      );
    }

    int i = offset;
    for (int x = 0; x < config.width; x++) {
      for (int y = 0; y < config.height; y++) {
        final typeIndex = bytes[i++];
        if (typeIndex < TileType.values.length) {
          grid[x][y].type = TileType.values[typeIndex];
        }
        grid[x][y].isRevealed = y < config.surfaceRows;
        grid[x][y].resetDig();
      }
    }
  }

  Uint8List exportBytes() {
    return encodeTileGrid(_grid, config);
  }

  void importBytes(Uint8List bytes) {
    // If importing, we likely need to ensure _grid is initialized
    if (_grid.isEmpty) {
      // We can't import into an empty grid structure.
      // We must wait for generation or force basic generation locally.
      // For now, let's assume importBytes is called after load.
      return;
    }

    decodeTileGrid(bytes, _grid, config);
    revealAround(config.width ~/ 2, config.surfaceRows, radius: 2);
  }
}