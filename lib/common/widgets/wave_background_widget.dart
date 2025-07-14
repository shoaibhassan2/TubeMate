// Path: lib/common/widgets/wave_background_widget.dart
// Previously: lib/core/presentation/widgets/wave_background_widget.dart

import 'package:flutter/material.dart';
import 'package:tubemate/common/widgets/wave_painter.dart'; // <--- UPDATED IMPORT

class WaveBackgroundWidget extends StatelessWidget {
  const WaveBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: WavePainter()),
    );
  }
}