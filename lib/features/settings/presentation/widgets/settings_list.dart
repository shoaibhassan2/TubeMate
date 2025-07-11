import 'package:flutter/material.dart';
import 'package:tubemate/features/settings/presentation/widgets/settings_about_tile.dart';
import 'package:tubemate/features/settings/presentation/widgets/settings_theme_tile.dart';
import 'package:tubemate/features/settings/presentation/widgets/settings_paksim_tile.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: const [
        SettingsThemeTile(), // Theme selection tile
        Divider(), // Separator
        SettingsPakSimTile(), // Pak SIM data tile
        Divider(), // Separator
        SettingsAboutTile(), // About section tile
      ],
    );
  }
}