import 'package:flutter/material.dart';
import 'package:tubemate/features/downloader/domain/services/download_manager_service.dart';
import 'package:tubemate/features/downloader/presentation/widgets/downloads_appbar.dart';
import 'package:tubemate/features/downloader/presentation/widgets/downloads_empty_view.dart';
import 'package:tubemate/features/downloader/presentation/widgets/downloads_list_view.dart';
import 'package:tubemate/features/downloader/presentation/widgets/downloads_selection_controller.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final DownloadManagerService _downloadManager = DownloadManagerService.instance;
  final DownloadsSelectionController _selectionController = DownloadsSelectionController();

  @override
  void initState() {
    super.initState();
    _downloadManager.addListener(_onDownloadsChanged);
  }

  @override
  void dispose() {
    _downloadManager.removeListener(_onDownloadsChanged);
    super.dispose();
  }

  void _onDownloadsChanged() {
    setState(() => _selectionController.cleanInvalidSelections(_downloadManager.value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildDownloadsAppBar(
        context: context,
        selectionController: _selectionController,
        downloadManager: _downloadManager,
        refresh: () => setState(() {}),
      ),
      body: ValueListenableBuilder(
        valueListenable: _downloadManager,
        builder: (context, downloads, _) {
          if (downloads.isEmpty) return const DownloadsEmptyView();
          return DownloadsListView(
            downloads: downloads,
            selectionController: _selectionController,
            refresh: () => setState(() {}),
          );
        },
      ),
    );
  }
}
