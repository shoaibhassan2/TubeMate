import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class StatusErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const StatusErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 60),
            const SizedBox(height: 12),
            Text(message, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: openAppSettings,
              icon: const Icon(Icons.settings),
              label: const Text('Open App Settings'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
