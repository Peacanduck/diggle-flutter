/// surface_buildings.dart
/// Draws the surface buildings (Shop, Store, Quests, Museum) on their
/// bedrock floors, plus a bobbing "!" over Quests while a reward waits.
///
/// Rendering only. Where they stand is SurfaceLayout; what happens when the
/// drill parks in a doorway is DiggleGame.enterBuilding.
library;

import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../diggle_game.dart';
import '../systems/gear_sprites.dart';
import 'surface_layout.dart';
import 'tile_map_component.dart';

class SurfaceBuildings extends Component with HasGameReference<DiggleGame> {
  /// Above the tile map, below the drill — so the drill drives in FRONT of
  /// a doorway rather than behind the wall.
  SurfaceBuildings() : super(priority: 1);

  final List<(BuildingSite, Sprite)> _buildings = [];
  final Vector2 _position = Vector2.zero();
  final Vector2 _size = Vector2.all(BuildingSheet.cellSize);
  double _top = 0;
  double _time = 0;

  final Paint _markerPaint = Paint()..color = const Color(0xFFFFC107);
  final Paint _markerEdge = Paint()
    ..color = const Color(0xFF14161C)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  late final TextPainter _bang = TextPainter(
    text: const TextSpan(
      text: '!',
      style: TextStyle(
        color: Color(0xFF14161C),
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  Future<void> onLoad() async {
    final sheet = await game.images.load(BuildingSheet.asset);
    assert(
      sheet.width == BuildingSheet.sheetWidth &&
          sheet.height == BuildingSheet.sheetHeight,
      'DiggleBuildingsSheet.png is ${sheet.width}x${sheet.height} but '
      'gear_sprites.dart expects ${BuildingSheet.sheetWidth.toInt()}x'
      '${BuildingSheet.sheetHeight.toInt()}. Regenerate both together.',
    );
    const cell = BuildingSheet.cellSize;
    for (final site in SurfaceLayout.sites(game.worldConfig.width)) {
      _buildings.add((
        site,
        Sprite(
          sheet,
          srcPosition: Vector2(BuildingSheet.column(site.type) * cell, 0),
          srcSize: Vector2.all(cell),
        ),
      ));
    }
    _top = (game.worldConfig.surfaceRows - BuildingSheet.tilesHigh) *
        TileMapComponent.tileSize;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    const tile = TileMapComponent.tileSize;
    for (final (site, sprite) in _buildings) {
      sprite.render(
        canvas,
        position: _position..setValues(site.left * tile, _top),
        size: _size,
      );
      if (site.type == BuildingType.quests &&
          game.questSystem.hasUnclaimedRewards) {
        _renderMarker(canvas, (site.left + BuildingSite.width / 2) * tile);
      }
    }
  }

  /// Bobbing "!" badge centred over a building.
  void _renderMarker(Canvas canvas, double centreX) {
    final bob = math.sin(_time * 4) * 3;
    final centre = Offset(centreX, _top - 14 + bob);
    canvas.drawCircle(centre, 11, _markerPaint);
    canvas.drawCircle(centre, 11, _markerEdge);
    _bang.paint(
      canvas,
      centre - Offset(_bang.width / 2, _bang.height / 2),
    );
  }
}
