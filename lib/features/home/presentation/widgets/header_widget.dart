import 'package:flutter/material.dart';
import 'package:tubemate/features/settings/presentation/screens/settings_screen.dart'; // Corrected import path

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access current theme

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'TubeMate',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: Icon(Icons.settings_outlined, color: theme.iconTheme.color), // Use theme icon color
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()), // Navigate to settings screen
          ),
        ),
      ],
    );
  }
}