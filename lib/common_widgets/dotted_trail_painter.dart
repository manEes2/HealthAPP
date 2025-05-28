import 'package:flutter/material.dart';

class DottedTrailPainter extends CustomPainter {
  final List<Offset> points;

  DottedTrailPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      final p1 = points[i - 1];
      final p2 = points[i];

      // Control points for smoothness
      final controlPoint1 = Offset((p1.dx + p2.dx) / 2, p1.dy);
      final controlPoint2 = Offset((p1.dx + p2.dx) / 2, p2.dy);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
    }

    // Dotted effect
    final dashWidth = 8.0;
    final dashSpace = 4.0;
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          nextDistance.clamp(0.0, metric.length),
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
