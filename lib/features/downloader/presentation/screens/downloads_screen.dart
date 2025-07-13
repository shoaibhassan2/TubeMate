// Path: lib/features/downloader/presentation/screens/downloads_screen.dart

import 'package:flutter/material.dart';
import 'dart:collection'; // <--- ADD THIS IMPORT
import 'package:tubemate/features/downloader/data/models/download_item_model.dart';
import 'package:tubemate/features/downloader/domain/services/download_manager_service.dart';
import 'package:tubemate/features/downloader/presentation/widgets/download_progress_tile.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final DownloadManagerService _downloadManager = DownloadManagerService.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Downloads', style: theme.textTheme.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_finished') {
                _downloadManager.clearFinishedDownloads();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cleared finished/failed downloads.')),
                );
              } else if (value == 'clear_all') {
                _downloadManager.clearAllDownloads();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cleared all downloads.')),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'clear_finished',
                child: Text('Clear Finished/Failed'),
              ),
              const PopupMenuItem<String>(
                value: 'clear_all',
                child: Text('Clear All'),
              ),
            ],
            icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
          ),
        ],
      ),
      body: ValueListenableBuilder<UnmodifiableListView<DownloadItemModel>>( // Use UnmodifiableListView type
        valueListenable: _downloadManager,
        builder: (context, currentDownloads, child) {
          if (currentDownloads.isEmpty) { // <--- Now correctly typed, so isEmpty works
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_for_offline, size: 80, color: theme.iconTheme.color),
                  const SizedBox(height: 16),
                  Text(
                    'No active or completed downloads.',
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    'Start downloading from the Home tab!',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              itemCount: currentDownloads.length, // <--- Now correctly typed, so length works
              itemBuilder: (context, index) {
                final item = currentDownloads[index]; // <--- Now correctly typed, so [] operator works
                return DownloadProgressTile(downloadItem: item);
              },
            );
          }
        },
      ),
    );
  }
}