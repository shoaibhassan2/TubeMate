import 'package:flutter/material.dart';
import 'package:tubemate/features/downloader/domain/services/download_manager_service.dart';
import 'package:tubemate/features/downloader/presentation/widgets/downloads_selection_controller.dart';

PreferredSizeWidget buildDownloadsAppBar({
  required BuildContext context,
  required DownloadsSelectionController selectionController,
  required DownloadManagerService downloadManager,
  required VoidCallback refresh,
}) {
  final theme = Theme.of(context);

  return AppBar(
    title: selectionController.isSelectionMode
        ? Text('${selectionController.selectedIds.length} Selected', style: theme.textTheme.headlineSmall)
        : Text('Downloads', style: theme.textTheme.headlineSmall),
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: theme.appBarTheme.foregroundColor,
    leading: selectionController.isSelectionMode
        ? IconButton(
            icon: Icon(Icons.close, color: theme.iconTheme.color),
            onPressed: () {
              selectionController.clear();
              refresh();
            },
          )
        : null,
    actions: [
      if (selectionController.isSelectionMode)
        IconButton(
          icon: Icon(Icons.delete, color: theme.colorScheme.error),
          onPressed: selectionController.selectedIds.isEmpty
              ? null
              : () async {
                  await selectionController.showDeleteConfirmationDialog(context, downloadManager);
                  refresh();
                },
        )
      else
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'clear_all') {
              await selectionController.showClearAllConfirmationDialog(context, downloadManager);
              refresh();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'clear_all', child: Text('Clear All')),
          ],
          icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
        ),
    ],
  );
}
