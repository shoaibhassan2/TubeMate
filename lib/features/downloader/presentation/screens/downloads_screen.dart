// Path: lib/features/downloader/presentation/screens/downloads_screen.dart

import 'package:flutter/material.dart';
import 'dart:collection';
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
  Set<String> _selectedDownloadIds = {}; // <--- NEW: Set to store selected item IDs
  bool _isSelectionMode = false; // <--- NEW: Flag for selection mode

  @override
  void initState() {
    super.initState();
    // Listen for changes in downloads to adjust selection mode if selected items are deleted externally
    _downloadManager.addListener(_onDownloadsChanged);
  }

  @override
  void dispose() {
    _downloadManager.removeListener(_onDownloadsChanged);
    super.dispose();
  }

  void _onDownloadsChanged() {
    // If we're in selection mode and selected items no longer exist in the download list,
    // clear selection or exit selection mode.
    if (_isSelectionMode && _selectedDownloadIds.isNotEmpty) {
      final currentDownloadIds = _downloadManager.value.map((item) => item.id).toSet();
      final newSelection = _selectedDownloadIds.intersection(currentDownloadIds);
      if (newSelection.length != _selectedDownloadIds.length) {
        setState(() {
          _selectedDownloadIds = newSelection;
          if (_selectedDownloadIds.isEmpty) {
            _isSelectionMode = false;
          }
        });
      }
    }
  }

  // --- NEW: Toggle selection for an item ---
  void _toggleSelection(String id) {
    setState(() {
      if (_selectedDownloadIds.contains(id)) {
        _selectedDownloadIds.remove(id);
      } else {
        _selectedDownloadIds.add(id);
      }
      _isSelectionMode = _selectedDownloadIds.isNotEmpty; // Exit selection mode if nothing is selected
    });
  }

  // --- NEW: Show confirmation dialog for deletion ---
  Future<void> _showDeleteConfirmationDialog(List<String> idsToDelete) async {
    final theme = Theme.of(context);
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text('Delete Selected Downloads?', style: theme.textTheme.headlineSmall),
          content: Text(
            'Are you sure you want to delete ${idsToDelete.length} selected download(s)? This action cannot be undone.',
            style: theme.textTheme.bodyLarge,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false), // Cancel
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.primary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true), // OK (Confirm Delete)
              child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      for (final id in idsToDelete) {
        await _downloadManager.deleteDownload(id);
      }
      setState(() {
        _selectedDownloadIds.clear(); // Clear selection after deletion
        _isSelectionMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${idsToDelete.length} download(s) deleted.')),
      );
    }
  }

  // --- NEW: Show confirmation dialog for "Clear All" ---
  Future<void> _showClearAllConfirmationDialog() async {
    final theme = Theme.of(context);
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text('Clear All Downloads?', style: theme.textTheme.headlineSmall),
          content: Text(
            'Are you sure you want to clear ALL downloads? This will also delete the files from your device.',
            style: theme.textTheme.bodyLarge,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false), // Cancel
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.primary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true), // OK (Confirm Clear All)
              child: Text('Clear All', style: TextStyle(color: theme.colorScheme.error)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _downloadManager.clearAllDownloads();
      setState(() {
        _selectedDownloadIds.clear(); // Clear selection after deletion
        _isSelectionMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All downloads cleared.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedDownloadIds.length} Selected', style: theme.textTheme.headlineSmall)
            : Text('Downloads', style: theme.textTheme.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.appBarTheme.foregroundColor,
        leading: _isSelectionMode
            ? IconButton( // Show back button to exit selection mode
                icon: Icon(Icons.close, color: theme.iconTheme.color),
                onPressed: () {
                  setState(() {
                    _selectedDownloadIds.clear();
                    _isSelectionMode = false;
                  });
                },
              )
            : null,
        actions: [
          if (_isSelectionMode)
            IconButton( // Delete button when items are selected
              icon: Icon(Icons.delete, color: theme.colorScheme.error),
              onPressed: _selectedDownloadIds.isEmpty
                  ? null
                  : () => _showDeleteConfirmationDialog(_selectedDownloadIds.toList()),
            )
          else
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_all') {
                  _showClearAllConfirmationDialog(); // Use new dialog
                }
                // Removed 'clear_finished' as 'clear_all' covers it for this request.
                // You can add it back if specific functionality is needed.
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'clear_all',
                  child: Text('Clear All'), // Only "Clear All" option
                ),
              ],
              icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
            ),
        ],
      ),
      body: ValueListenableBuilder<UnmodifiableListView<DownloadItemModel>>(
        valueListenable: _downloadManager,
        builder: (context, currentDownloads, child) {
          if (currentDownloads.isEmpty) {
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
              itemCount: currentDownloads.length,
              itemBuilder: (context, index) {
                final item = currentDownloads[index];
                final bool isSelected = _selectedDownloadIds.contains(item.id);
                return DownloadProgressTile(
                  downloadItem: item,
                  isSelected: isSelected, // Pass selection state
                  isSelectionMode: _isSelectionMode, // Pass selection mode flag
                  onLongPress: (id) => _toggleSelection(id), // Handle long press
                  onTapWhenSelecting: (id) => _toggleSelection(id), // Tap to select/deselect
                );
              },
            );
          }
        },
      ),
    );
  }
}