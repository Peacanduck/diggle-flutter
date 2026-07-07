/// biome.dart
/// Depth-band biome definitions for world generation and rendering.
///
/// The world is split into 4 strata. Each biome controls:
/// - Base tile substitutions (e.g. dirt → frozenDirt in Permafrost)
/// - Ore/hazard spawn weight multipliers
/// - Cave, shaft, and ruin density for the generator passes
/// - A background tint used by the renderer so each band reads visually
///
/// All tuning for "how does depth X feel" lives in this one file.

import 'dart:ui';
import 'tile.dart';

class Biome {
  final String name;

  /// Depth range in tiles below the surface: [minDepth, maxDepth).
  final int minDepth;
  final int maxDepth;

  /// Translucent overlay tint applied over tiles in this band.
  final Color tint;

  /// Background color for empty (dug-out / cave) tiles.
  final Color caveColor;

  /// Base tile substitutions applied after terrain generation.
  final Map<TileType, TileType> substitutions;

  /// Spawn-weight multipliers for ores/hazards. Types not listed use 1.0.
  /// A multiplier of 0 disables the type in this band.
  final Map<TileType, double> weightMultipliers;

  /// Cave pockets carved per 1000 tiles of band area.
  final double caveDensity;

  /// Number of abandoned vertical shafts in this band.
  final int shaftCount;

  /// Number of buried ruin rooms (with artifacts/crates) in this band.
  final int ruinCount;

  const Biome({
    required this.name,
    required this.minDepth,
    required this.maxDepth,
    required this.tint,
    required this.caveColor,
    this.substitutions = const {},
    this.weightMultipliers = const {},
    this.caveDensity = 0.5,
    this.shaftCount = 0,
    this.ruinCount = 0,
  });

  bool contains(int depth) => depth >= minDepth && depth < maxDepth;

  /// The four world strata, ordered by depth.
  static const List<Biome> strata = [
    Biome(
      name: 'Topsoil',
      minDepth: 0,
      maxDepth: 120,
      tint: Color(0x00000000), // no tint — baseline look
      caveColor: Color(0xFF1a1a2e),
      weightMultipliers: {
        TileType.crystalOre: 0.0,
        TileType.unstableRock: 0.0,
      },
      caveDensity: 0.4,
      shaftCount: 3,
      ruinCount: 0,
    ),
    Biome(
      name: 'Permafrost',
      minDepth: 120,
      maxDepth: 240,
      tint: Color(0x1E7FB8E8), // icy blue wash
      caveColor: Color(0xFF16222e),
      substitutions: {TileType.dirt: TileType.frozenDirt},
      weightMultipliers: {
        TileType.silver: 1.5,
        TileType.gold: 1.4,
        TileType.gas: 1.5,
        TileType.crystalOre: 0.0,
        TileType.unstableRock: 0.5,
      },
      caveDensity: 0.9,
      shaftCount: 3,
      ruinCount: 1,
    ),
    Biome(
      name: 'Crystal Caverns',
      minDepth: 240,
      maxDepth: 360,
      tint: Color(0x209D4EDD), // violet wash
      caveColor: Color(0xFF1e162e),
      weightMultipliers: {
        TileType.sapphire: 1.5,
        TileType.emerald: 1.5,
        TileType.crystalOre: 1.0,
        TileType.unstableRock: 1.0,
      },
      caveDensity: 1.5,
      shaftCount: 2,
      ruinCount: 3,
    ),
    Biome(
      name: 'Magma Core',
      minDepth: 360,
      maxDepth: 1 << 30,
      tint: Color(0x24FF4500), // heat glow
      caveColor: Color(0xFF2e1616),
      substitutions: {TileType.rock: TileType.magmaRock},
      weightMultipliers: {
        TileType.lava: 1.8,
        TileType.ruby: 1.3,
        TileType.diamond: 1.2,
        TileType.crystalOre: 0.3,
        TileType.unstableRock: 1.5,
      },
      caveDensity: 0.8,
      shaftCount: 0,
      ruinCount: 1,
    ),
  ];

  /// Biome at a given depth (tiles below surface). Depth < 0 → Topsoil.
  static Biome atDepth(int depth) {
    for (final biome in strata) {
      if (biome.contains(depth)) return biome;
    }
    return strata.last;
  }
}
