import 'package:flutter/material.dart';
import 'package:tubemate/core/presentation/widgets/wave_painter.dart'; // Corrected import path

class WaveBackgroundWidget extends StatelessWidget { // Renamed for clarity
  const WaveBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: WavePainter()),
    );
  }
}