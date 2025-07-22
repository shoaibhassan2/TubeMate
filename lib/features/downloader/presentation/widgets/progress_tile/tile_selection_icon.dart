import 'package:flutter/material.dart';

class TileSelectionIcon extends StatelessWidget {
  final bool isSelected;
  final ThemeData theme;

  const TileSelectionIcon({
    super.key,
    required this.isSelected,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Icon(
        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isSelected ? theme.colorScheme.primary : Colors.grey,
      ),
    );
  }
}
