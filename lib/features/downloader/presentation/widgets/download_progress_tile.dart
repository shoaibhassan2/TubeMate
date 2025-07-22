import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:tubemate/common/utils/extensions.dart';
import 'package:tubemate/features/downloader/data/models/download_item_model.dart';
import 'package:tubemate/features/downloader/domain/enums/download_status.dart';
import 'package:tubemate/features/downloader/presentation/widgets/progress_tile/status_utils.dart';
import 'package:tubemate/features/downloader/presentation/widgets/progress_tile/download_controls.dart';
import 'package:tubemate/features/downloader/presentation/widgets/progress_tile/tile_helpers.dart';
import 'package:tubemate/features/downloader/presentation/widgets/progress_tile/tile_error_text.dart';
import 'package:tubemate/features/downloader/presentation/widgets/progress_tile/tile_progress_bar.dart';
import 'package:tubemate/features/downloader/presentation/widgets/progress_tile/tile_selection_icon.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String mediaType = downloadItem.isVideo ? 'Video' : 'Audio';
    final String statusText =
        'Status: ${downloadItem.status.name.capitalizeFirst()} ($mediaType)';
    final String? displayErrorMessage =
        sanitizeError(downloadItem.errorMessage);

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
            : () => handleTap(context, downloadItem),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              if (isSelectionMode)
                TileSelectionIcon(
                  isSelected: isSelected,
                  theme: theme,
                ),
              Expanded(
                child: ListTile(
                  leading: buildThumbnail(downloadItem, theme),
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
                          color: getStatusColor(context, downloadItem.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (downloadItem.status == DownloadStatus.downloading)
                        TileProgressBar(progress: downloadItem.progress),
                      if (downloadItem.status == DownloadStatus.downloading)
                        Text(
                          '${(downloadItem.progress * 100).toStringAsFixed(1)}%',
                          style: theme.textTheme.bodySmall,
                        ),
                      if (displayErrorMessage != null &&
                          displayErrorMessage.isNotEmpty)
                        TileErrorText(errorMessage: displayErrorMessage),
                      DownloadControls(
                        status: downloadItem.status,
                        downloadId: downloadItem.id,
                        isSelectionMode: isSelectionMode,
                      ),
                    ],
                  ),
                  trailing: Icon(
                    getStatusIcon(downloadItem.status),
                    color: getStatusColor(context, downloadItem.status),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
