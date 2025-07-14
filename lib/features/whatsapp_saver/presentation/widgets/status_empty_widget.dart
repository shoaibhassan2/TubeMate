import 'package:flutter/material.dart';

class StatusEmptyWidget extends StatelessWidget {
  const StatusEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off, size: 60, color: theme.iconTheme.color),
            const SizedBox(height: 12),
            Text('No statuses found', style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Please view statuses in WhatsApp or WhatsApp Business, then refresh.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
