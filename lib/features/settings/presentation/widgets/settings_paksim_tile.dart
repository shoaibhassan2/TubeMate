import 'package:flutter/material.dart';
import 'package:tubemate/features/paksim/presentation/screens/paksim_screen.dart'; // Corrected import path

class SettingsPakSimTile extends StatelessWidget {
  const SettingsPakSimTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access current theme

    return ListTile(
      leading: Icon(Icons.sim_card, color: theme.iconTheme.color), // Icon color from theme
      title: Text('Pak SIM Data', style: theme.textTheme.bodyLarge), // Text style from theme
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PakSimScreen()), // Navigate to Pak SIM Data screen
        );
      },
    );
  }
}