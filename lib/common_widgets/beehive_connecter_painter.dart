import 'package:flutter/material.dart';

class BeeHiveConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade800
      ..strokeWidth = 3
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start at bee (approximate position)
    final beeOffset = Offset(60 + 25, 400 + 25);

    // End at hive (approximate position)
    final hiveOffset = Offset(size.width - 60 - 50, 320 + 50);

    // Create a curved path
    path.moveTo(beeOffset.dx, beeOffset.dy);
    path.quadraticBezierTo(
      (beeOffset.dx + hiveOffset.dx) / 2,
      beeOffset.dy - 100,
      hiveOffset.dx,
      hiveOffset.dy,
    );

    // Draw dots along the path
    _drawDottedPath(canvas, path, paint, dotSpacing: 10, dotRadius: 2.5);
  }

  void _drawDottedPath(Canvas canvas, Path path, Paint paint,
      {required double dotSpacing, required double dotRadius}) {
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final pos = metric.getTangentForOffset(distance);
        if (pos != null) {
          canvas.drawCircle(pos.position, dotRadius, paint);
        }
        distance += dotSpacing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
