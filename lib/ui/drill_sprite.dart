/// drill_sprite.dart
/// The free base drill (the machine every player starts with) as a Flutter
/// widget, for menus and branding. Same sheet and idle animation the game
/// uses for a parked drill, so the logo and the game never disagree.
library;

import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../game/systems/drill_anim.dart';
import '../game/systems/gear_sprites.dart';

class DrillSprite extends StatefulWidget {
  /// Width and height of the square the 32px cell is scaled into.
  final double size;

  /// Loop the idle frames; false shows the rest pose (frame 0).
  final bool animate;

  const DrillSprite({super.key, this.size = 64, this.animate = true});

  static Future<ui.Image>? _sheet;

  /// Decoded once per app run and shared by every DrillSprite.
  static Future<ui.Image> _loadSheet() => _sheet ??= () async {
        final data =
            await rootBundle.load('assets/images/${BaseDrillSheet.asset}');
        final codec =
            await ui.instantiateImageCodec(data.buffer.asUint8List());
        return (await codec.getNextFrame()).image;
      }();

  @override
  State<DrillSprite> createState() => _DrillSpriteState();
}

class _DrillSpriteState extends State<DrillSprite>
    with SingleTickerProviderStateMixin {
  ui.Image? _image;
  Ticker? _ticker;
  int _frame = 0;

  @override
  void initState() {
    super.initState();
    DrillSprite._loadSheet().then((image) {
      if (mounted) setState(() => _image = image);
    }).catchError((Object e) {
      debugPrint('DrillSprite: failed to load sheet: $e');
    });
    if (widget.animate) {
      final fps = kDrillAnimBands[DrillAction.idle]!.fps;
      _ticker = createTicker((elapsed) {
        final phase = elapsed.inMicroseconds / 1e6 * fps;
        final frame = drillFrame(DrillAction.idle, phase);
        if (frame != _frame) setState(() => _frame = frame);
      })
        ..start();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return SizedBox.square(
      dimension: widget.size,
      child: image == null
          ? null
          : CustomPaint(painter: _DrillCellPainter(image, _frame)),
    );
  }
}

class _DrillCellPainter extends CustomPainter {
  final ui.Image sheet;
  final int frame;

  _DrillCellPainter(this.sheet, this.frame);

  @override
  void paint(Canvas canvas, Size size) {
    const cell = BaseDrillSheet.cellSize;
    final (col, row) = BaseDrillSheet.cell(frame: frame);
    canvas.drawImageRect(
      sheet,
      Rect.fromLTWH(col * cell, row * cell, cell, cell),
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.none,
    );
  }

  @override
  bool shouldRepaint(_DrillCellPainter old) =>
      old.frame != frame || old.sheet != sheet;
}
