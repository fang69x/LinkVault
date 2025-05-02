import 'dart:math' as math;
import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final Color color;
  final double amplitude;
  final double phase;

  WavePainter({
    required this.color,
    this.amplitude = 10,
    this.phase = 0,
  });

  Path _buildPath(Size size) {
    final segments = 40;
    final dx = size.width / segments;
    final path = Path()..moveTo(0, size.height);

    for (var i = 0; i < segments; i++) {
      final x0 = dx * i;
      final x1 = dx * (i + 1);
      final y0 = size.height -
          amplitude * math.sin((x0 / size.width) * 4 * math.pi + phase);
      final y1 = size.height -
          amplitude * math.sin((x1 / size.width) * 4 * math.pi + phase);
      final midX = (x0 + x1) / 2;
      final midY = (y0 + y1) / 2;
      path.quadraticBezierTo(x0, y0, midX, midY);
    }

    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter old) {
    return old.color != color ||
        old.phase != phase ||
        old.amplitude != amplitude;
  }
}
