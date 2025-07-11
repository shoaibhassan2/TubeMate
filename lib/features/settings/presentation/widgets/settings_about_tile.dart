import 'package:flutter/material.dart';

class SettingsAboutTile extends StatelessWidget {
  const SettingsAboutTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.dialogBackgroundColor.withOpacity(0.95); // Dialog background color from theme
    final accentColor = theme.colorScheme.primary; // Accent color from theme

    return ListTile(
      leading: Icon(Icons.info_outline, color: accentColor), // Icon with accent color
      title: Text('About', style: TextStyle(color: accentColor)), // Title with accent color
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              backgroundColor: bgColor, // Use theme's dialog background with opacity
              title: Text('About', style: TextStyle(color: accentColor)), // Dialog title
              content: Text(
                'Developed By Shoaib Hassan\nThanks to SHKA team',
                style: theme.textTheme.bodyMedium, // Text style from theme
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text('OK', style: TextStyle(color: accentColor)), // Button with accent color
                ),
              ],
            );
          },
        );
      },
    );
  }
}