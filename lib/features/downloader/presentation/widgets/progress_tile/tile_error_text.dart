import 'package:flutter/material.dart';

class TileErrorText extends StatelessWidget {
  final String errorMessage;

  const TileErrorText({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      'Error: $errorMessage',
      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
