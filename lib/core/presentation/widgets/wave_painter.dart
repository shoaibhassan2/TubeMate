import 'package:flutter/material.dart';
import 'package:tubemate/config/theme/theme_constants.dart'; // Corrected import path

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // First wave layer (lighter opacity)
    final paint1 = Paint()
      ..color = kAccentColor.withOpacity(0.15) // Use kAccentColor from constants
      ..style = PaintingStyle.fill;
    final path1 = Path()
      ..moveTo(0, size.height * 0.7) // Start at 70% height on the left
      // Quadratic Bezier curve to define the wave shape
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.6, size.width * 0.5, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height * 0.7)
      ..lineTo(size.width, size.height) // Close path to bottom right
      ..lineTo(0, size.height) // Close path to bottom left
      ..close();
    canvas.drawPath(path1, paint1);

    // Second wave layer (even lighter opacity)
    final paint2 = Paint()
      ..color = kSecondaryAccentColor.withOpacity(0.1) // Use kSecondaryAccentColor from constants
      ..style = PaintingStyle.fill;
    final path2 = Path()
      ..moveTo(0, size.height * 0.8) // Start at 80% height on the left (lower than first wave)
      // Quadratic Bezier curve for the second wave
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.85, size.width * 0.6, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.65, size.width, size.height * 0.7)
      ..lineTo(size.width, size.height) // Close path to bottom right
      ..lineTo(0, size.height) // Close path to bottom left
      ..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false; // Waves are static, no need to repaint
}