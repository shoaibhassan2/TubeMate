// Path: lib/common/widgets/wave_painter.dart

import 'package:flutter/material.dart';
import 'package:tubemate/core/theme/theme_constants.dart';

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = kAccentColor.withOpacity(0.15)..style = PaintingStyle.fill;
    final path1 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.6, size.width * 0.5, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height * 0.7)
      ..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()..color = kSecondaryAccentColor.withOpacity(0.1)..style = PaintingStyle.fill;
    final path2 = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.85, size.width * 0.6, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.65, size.width, size.height * 0.7) // <--- THIS LINE IS THE FIX
      ..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}