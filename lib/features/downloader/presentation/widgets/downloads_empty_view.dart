import 'package:flutter/material.dart';

class DownloadsEmptyView extends StatelessWidget {
  const DownloadsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download_for_offline, size: 80, color: theme.iconTheme.color),
          const SizedBox(height: 16),
          Text('No active or completed downloads.', style: theme.textTheme.titleLarge),
          Text('Start downloading from the Home tab!', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
