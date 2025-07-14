import 'package:flutter/material.dart';
import 'package:tubemate/core/theme/theme_controller.dart';// Corrected import path

class SettingsThemeTile extends StatelessWidget {
  const SettingsThemeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access current theme

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController, // Listen to theme mode changes
      builder: (_, mode, __) {
        return ListTile(
          leading: Icon(Icons.brightness_6, color: theme.iconTheme.color), // Icon with theme color
          title: Text(
            'App Theme',
            style: theme.textTheme.bodyLarge, // Text style from theme
          ),
          trailing: DropdownButton<ThemeMode>(
            value: mode, // Current theme mode
            dropdownColor: theme.scaffoldBackgroundColor, // Dropdown background color from theme
            iconEnabledColor: theme.iconTheme.color, // Dropdown icon color from theme
            underline: const SizedBox(), // Remove default underline
            onChanged: (ThemeMode? newMode) {
              if (newMode != null) {
                themeController.setTheme(newMode); // Update theme mode via controller
              }
            },
            items: [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('System Default', style: theme.textTheme.bodyMedium), // Text style from theme
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('Light', style: theme.textTheme.bodyMedium), // Text style from theme
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark', style: theme.textTheme.bodyMedium), // Text style from theme
              ),
            ],
          ),
        );
      },
    );
  }
}