import 'package:flutter/material.dart';
import 'package:tubemate/features/downloader/data/models/download_item_model.dart';
import 'package:tubemate/features/downloader/presentation/widgets/download_progress_tile.dart';
import 'downloads_selection_controller.dart';

class DownloadsListView extends StatelessWidget {
  final List<DownloadItemModel> downloads;
  final DownloadsSelectionController selectionController;
  final VoidCallback refresh;

  const DownloadsListView({
    super.key,
    required this.downloads,
    required this.selectionController,
    required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final item = downloads[index];
        return DownloadProgressTile(
          downloadItem: item,
          isSelected: selectionController.selectedIds.contains(item.id),
          isSelectionMode: selectionController.isSelectionMode,
          onTapWhenSelecting: (id) {
            selectionController.toggle(id);
            refresh();
          },
          onLongPress: (id) {
            selectionController.toggle(id);
            refresh();
          },
        );
      },
    );
  }
}
