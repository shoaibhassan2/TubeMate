import 'package:flutter/material.dart';
import 'package:tubemate/features/settings/presentation/widgets/settings_list.dart'; // Corrected import path

class SettingsScreen extends StatelessWidget { // Renamed for clarity
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Use theme's scaffold background
      appBar: AppBar(
        title: Text('Settings', style: theme.textTheme.headlineSmall), // Use theme text style
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.appBarTheme.foregroundColor, // Set app bar icon/text color from theme
      ),
      body: const SettingsList(), // Display the list of settings options
    );
  }
}