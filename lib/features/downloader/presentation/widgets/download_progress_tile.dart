// Path: lib/features/downloader/presentation/widgets/download_progress_tile.dart

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:tubemate/features/downloader/data/models/download_item_model.dart';
import 'package:tubemate/features/downloader/domain/enums/download_status.dart';

class DownloadProgressTile extends StatelessWidget {
  final DownloadItemModel downloadItem;

  const DownloadProgressTile({
    super.key,
    required this.downloadItem,
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

    // Determine media type for display (e.g., "Video", "Audio")
    String mediaType = downloadItem.isVideo ? 'Video' : 'Audio';

    // Construct the status text, ensuring it always shows the enum name
    String statusText = 'Status: ${downloadItem.status.name.capitalizeFirst()} ($mediaType)';

    // Add error message to the status text if present and not empty
    String? displayErrorMessage = downloadItem.errorMessage;
    if (displayErrorMessage != null && displayErrorMessage.isNotEmpty) {
      // Clean up common PlatformException prefixes
      if (displayErrorMessage.startsWith('PlatformException(error, ')) {
        displayErrorMessage = displayErrorMessage.substring('PlatformException(error, '.length);
        if (displayErrorMessage.endsWith(')')) {
          displayErrorMessage = displayErrorMessage.substring(0, displayErrorMessage.length - 1);
        }
      }
      // Remove any Closure or function type string if it appears (this is a heuristic)
      if (displayErrorMessage.contains('Closure: () => String') || displayErrorMessage.contains('Function: ')) {
         displayErrorMessage = 'An internal error occurred.';
      }
    }


    return Card(
      color: theme.cardColor.withOpacity(isDark ? 0.2 : 0.8),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              statusText, // Use the correctly formatted status text
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
            // Display error message separately if exists and is valid
            if (displayErrorMessage != null && displayErrorMessage.isNotEmpty)
              Text(
                'Error: $displayErrorMessage',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Icon(
          _getStatusIcon(downloadItem.status),
          color: _getStatusColor(context, downloadItem.status),
        ),
        onTap: () async {
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
      ),
    );
  }
}

extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}