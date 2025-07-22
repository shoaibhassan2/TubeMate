import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:tubemate/features/downloader/domain/services/download_manager_service.dart';
import 'package:tubemate/features/downloader/data/models/download_item_model.dart';

class DownloadsSelectionController {
  final Set<String> selectedIds = {};
  bool get isSelectionMode => selectedIds.isNotEmpty;

  void toggle(String id) {
    selectedIds.contains(id) ? selectedIds.remove(id) : selectedIds.add(id);
  }

  void clear() => selectedIds.clear();

  void cleanInvalidSelections(UnmodifiableListView<DownloadItemModel> currentList) {
    final existingIds = currentList.map((e) => e.id).toSet();
    selectedIds.removeWhere((id) => !existingIds.contains(id));
  }

  Future<void> showDeleteConfirmationDialog(BuildContext context, DownloadManagerService manager) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Selected Downloads?'),
        content: Text('Delete ${selectedIds.length} download(s)? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      for (final id in selectedIds) {
        await manager.deleteDownload(id);
      }
      clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${selectedIds.length} download(s) deleted.')),
      );
    }
  }

  Future<void> showClearAllConfirmationDialog(BuildContext context, DownloadManagerService manager) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Downloads?'),
        content: const Text('This will remove all downloads and their files. Proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear All')),
        ],
      ),
    );

    if (confirmed == true) {
      await manager.clearAllDownloads();
      clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All downloads cleared.')),
      );
    }
  }
}
