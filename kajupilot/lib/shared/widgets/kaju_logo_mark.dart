import 'package:flutter/material.dart';

import '../../core/theme/kaju_colors.dart';

class KajuLogoMark extends StatelessWidget {
  const KajuLogoMark({
    super.key,
    this.size = 56,
    this.showTile = false,
  });

  final double size;
  final bool showTile;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _KajuLogoPainter(
          bg: colors.bgCard,
          border: colors.borderSubtle,
          cashew: colors.accent,
          showTile: showTile,
        ),
      ),
    );
  }
}

class _KajuLogoPainter extends CustomPainter {
  const _KajuLogoPainter({
    required this.bg,
    required this.border,
    required this.cashew,
    required this.showTile,
  });

  final Color bg;
  final Color border;
  final Color cashew;
  final bool showTile;

  @override
  void paint(Canvas canvas, Size size) {
    if (showTile) {
      final tile = RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(size.width * 0.26),
      );
      canvas
        ..drawRRect(tile, Paint()..color = bg)
        ..drawRRect(
          tile.deflate(0.7),
          Paint()
            ..color = border
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
    }

    canvas.save();
    canvas.scale(size.width / 108, size.height / 108);
    canvas.translate(54, 54);
    canvas.scale(0.76);
    canvas.translate(-54, -54);

    final cashewPath = Path()
      ..moveTo(72, 16)
      ..cubicTo(54, 12, 38, 20, 28, 35)
      ..cubicTo(17, 51, 15, 72, 25, 86)
      ..cubicTo(35, 101, 57, 106, 76, 97)
      ..cubicTo(91, 90, 101, 76, 98, 64)
      ..cubicTo(95, 53, 86, 50, 76, 50)
      ..cubicTo(65, 50, 59, 43, 62, 34)
      ..cubicTo(64, 27, 73, 22, 79, 18)
      ..cubicTo(77, 17, 75, 16, 72, 16)
      ..close();

    canvas.drawPath(
      cashewPath.shift(const Offset(0, 2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.4),
    );

    canvas.drawPath(
      cashewPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(cashew, Colors.white, 0.28)!,
            cashew,
            Color.lerp(cashew, Colors.black, 0.16)!,
          ],
        ).createShader(const Rect.fromLTWH(0, 0, 108, 108)),
    );

    final groovePath = Path()
      ..moveTo(47, 47)
      ..cubicTo(35, 61, 36, 84, 59, 97);
    canvas.drawPath(
      groovePath,
      Paint()
        ..color = const Color(0xFF07080D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final highlightPath = Path()
      ..moveTo(37, 35)
      ..cubicTo(49, 23, 64, 20, 76, 24);
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _KajuLogoPainter oldDelegate) {
    return oldDelegate.bg != bg ||
        oldDelegate.border != border ||
        oldDelegate.cashew != cashew ||
        oldDelegate.showTile != showTile;
  }
}
