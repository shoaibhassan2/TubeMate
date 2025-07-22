import 'package:flutter/material.dart';
import 'package:tubemate/features/downloader/domain/enums/download_status.dart';
import 'package:tubemate/features/downloader/domain/services/download_manager_service.dart';

class DownloadControls extends StatelessWidget {
  final DownloadStatus status;
  final String downloadId;
  final bool isSelectionMode;

  const DownloadControls({
    super.key,
    required this.status,
    required this.downloadId,
    required this.isSelectionMode,
  });

  @override
  Widget build(BuildContext context) {
    final DownloadManagerService downloadManager = DownloadManagerService.instance;
    final theme = Theme.of(context);

    if (isSelectionMode) return const SizedBox.shrink();

    switch (status) {
      case DownloadStatus.downloading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.pause, color: theme.colorScheme.primary),
              onPressed: () => downloadManager.pauseDownload(downloadId),
            ),
            IconButton(
              icon: Icon(Icons.cancel, color: theme.colorScheme.error),
              onPressed: () => downloadManager.cancelDownload(downloadId),
            ),
          ],
        );
      case DownloadStatus.paused:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow, color: theme.colorScheme.primary),
              onPressed: () => downloadManager.resumeDownload(downloadId),
            ),
            IconButton(
              icon: Icon(Icons.cancel, color: theme.colorScheme.error),
              onPressed: () => downloadManager.cancelDownload(downloadId),
            ),
          ],
        );
      case DownloadStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
              onPressed: () => downloadManager.resumeDownload(downloadId),
            ),
            IconButton(
              icon: Icon(Icons.delete_forever, color: theme.colorScheme.error),
              onPressed: () => downloadManager.deleteDownload(downloadId),
            ),
          ],
        );
      case DownloadStatus.cancelled:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.delete_forever, color: theme.colorScheme.error),
              onPressed: () => downloadManager.deleteDownload(downloadId),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
