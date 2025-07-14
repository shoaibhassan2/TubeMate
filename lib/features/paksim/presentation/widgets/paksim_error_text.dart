import 'package:flutter/material.dart';

class PakSimErrorText extends StatelessWidget {
  final String message;

  const PakSimErrorText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      message,
      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
      textAlign: TextAlign.center,
    );
  }
}
