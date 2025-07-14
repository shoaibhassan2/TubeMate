// Path: lib/features/downloader/presentation/widgets/download_progress_tile.dart

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:tubemate/features/downloader/data/models/download_item_model.dart';
import 'package:tubemate/features/downloader/domain/enums/download_status.dart';
import 'package:tubemate/features/downloader/domain/services/download_manager_service.dart';
import 'package:tubemate/common/utils/extensions.dart'; // <--- Keep this import for StringExtension

class DownloadProgressTile extends StatelessWidget {
  final DownloadItemModel downloadItem;
  final bool isSelected;
  final bool isSelectionMode;
  final ValueChanged<String> onLongPress;
  final ValueChanged<String> onTapWhenSelecting;

  const DownloadProgressTile({
    super.key,
    required this.downloadItem,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onLongPress,
    required this.onTapWhenSelecting,
  });

  IconData _getStatusIcon(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.pending:
        return Icons.hourglass_empty;
      case DownloadStatus.downloading:
        return Icons.downloading;
      case DownloadStatus.paused:
        return Icons.pause_circle_filled;
      case DownloadStatus.completed:
        return Icons.check_circle;
      case DownloadStatus.failed:
        return Icons.error;
      case DownloadStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  Color _getStatusColor(BuildContext context, DownloadStatus status) {
    final theme = Theme.of(context);
    switch (status) {
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return theme.colorScheme.error;
      case DownloadStatus.downloading:
        return theme.colorScheme.primary;
      case DownloadStatus.pending:
        return Colors.blueGrey;
      case DownloadStatus.paused:
        return Colors.amber;
      case DownloadStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String mediaType = downloadItem.isVideo ? 'Video' : 'Audio';
    // StringExtension is now correctly imported and only defined once.
    String statusText = 'Status: ${downloadItem.status.name.capitalizeFirst()} ($mediaType)';

    String? displayErrorMessage = downloadItem.errorMessage;
    if (displayErrorMessage != null && displayErrorMessage.isNotEmpty) {
      if (displayErrorMessage.startsWith('PlatformException(error, ')) {
        displayErrorMessage = displayErrorMessage.substring('PlatformException(error, '.length);
        if (displayErrorMessage.endsWith(')')) {
          displayErrorMessage = displayErrorMessage.substring(0, displayErrorMessage.length - 1);
        }
      }
      if (displayErrorMessage.contains('Closure: () => String') || displayErrorMessage.contains('Function: ')) {
         displayErrorMessage = 'An internal error occurred.';
      }
    }

    return Card(
      color: isSelected
          ? theme.colorScheme.secondary.withOpacity(isDark ? 0.4 : 0.2)
          : theme.cardColor.withOpacity(isDark ? 0.2 : 0.8),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onLongPress: () => onLongPress(downloadItem.id),
        onTap: isSelectionMode
            ? () => onTapWhenSelecting(downloadItem.id)
            : () async {
                if (downloadItem.status == DownloadStatus.completed && downloadItem.publicGalleryPath != null) {
                  debugPrint('Attempting to open file: ${downloadItem.publicGalleryPath}');
                  final result = await OpenFile.open(downloadItem.publicGalleryPath!);
                  if (result.type != ResultType.done) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not open file: ${result.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else if (downloadItem.status == DownloadStatus.failed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Download failed: ${downloadItem.errorMessage}')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('File not yet available for opening.')),
                  );
                }
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              if (isSelectionMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? theme.colorScheme.primary : Colors.grey,
                  ),
                ),
              Expanded(
                child: ListTile(
                  leading: downloadItem.thumbnailUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            downloadItem.thumbnailUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.image_not_supported, size: 40, color: theme.iconTheme.color),
                          ),
                        )
                      : Icon(downloadItem.isVideo ? Icons.movie : Icons.audiotrack, size: 40, color: theme.iconTheme.color),
                  title: Text(
                    downloadItem.fileName,
                    style: theme.textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _getStatusColor(context, downloadItem.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (downloadItem.status == DownloadStatus.downloading)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: LinearProgressIndicator(
                            value: downloadItem.progress,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          ),
                        ),
                      if (downloadItem.status == DownloadStatus.downloading)
                        Text(
                          '${(downloadItem.progress * 100).toStringAsFixed(1)}%',
                          style: theme.textTheme.bodySmall,
                        ),
                      if (displayErrorMessage != null && displayErrorMessage.isNotEmpty)
                        Text(
                          'Error: $displayErrorMessage',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      _buildDownloadControls(context, theme),
                    ],
                  ),
                  trailing: Icon(
                    _getStatusIcon(downloadItem.status),
                    color: _getStatusColor(context, downloadItem.status),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadControls(BuildContext context, ThemeData theme) {
    final DownloadManagerService downloadManager = DownloadManagerService.instance;

    if (isSelectionMode) {
      return const SizedBox.shrink();
    }

    switch (downloadItem.status) {
      case DownloadStatus.downloading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.pause, color: theme.colorScheme.primary),
              onPressed: () => downloadManager.pauseDownload(downloadItem.id),
            ),
            IconButton(
              icon: Icon(Icons.cancel, color: theme.colorScheme.error),
              onPressed: () => downloadManager.cancelDownload(downloadItem.id),
            ),
          ],
        );
      case DownloadStatus.paused:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow, color: theme.colorScheme.primary),
              onPressed: () => downloadManager.resumeDownload(downloadItem.id),
            ),
            IconButton(
              icon: Icon(Icons.cancel, color: theme.colorScheme.error),
              onPressed: () => downloadManager.cancelDownload(downloadItem.id),
            ),
          ],
        );
      case DownloadStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
              onPressed: () => downloadManager.resumeDownload(downloadItem.id),
            ),
            IconButton(
              icon: Icon(Icons.delete_forever, color: theme.colorScheme.error),
              onPressed: () => downloadManager.deleteDownload(downloadItem.id),
            ),
          ],
        );
      case DownloadStatus.completed:
      case DownloadStatus.pending: // No delete for pending or completed states
        return const SizedBox.shrink(); // Hide all controls
      case DownloadStatus.cancelled: // Delete visible for cancelled
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.delete_forever, color: theme.colorScheme.error),
              onPressed: () => downloadManager.deleteDownload(downloadItem.id),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}