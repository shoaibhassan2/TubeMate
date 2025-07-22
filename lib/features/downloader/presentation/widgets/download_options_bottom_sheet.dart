// Path: lib/features/downloader/presentation/widgets/download_options_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:tubemate/features/downloader/data/models/tiktok_data_model.dart';
import 'package:tubemate/features/downloader/domain/services/download_manager_service.dart';
import 'package:tubemate/features/downloader/presentation/widgets/download_options/quality_enum.dart';
import 'package:tubemate/features/downloader/presentation/widgets/download_options/download_logic.dart';
import 'package:tubemate/features/downloader/presentation/widgets/download_options/quality_list_tiles.dart';

class DownloadOptionsBottomSheet extends StatefulWidget {
  final TikTokVideoData videoData;
  final VoidCallback onDownloadInitiated;

  const DownloadOptionsBottomSheet({
    super.key,
    required this.videoData,
    required this.onDownloadInitiated,
  });

  @override
  State<DownloadOptionsBottomSheet> createState() => _DownloadOptionsBottomSheetState();
}

class _DownloadOptionsBottomSheetState extends State<DownloadOptionsBottomSheet> {
  late VideoQuality _selectedQuality;
  bool _isDownloading = false;
  final DownloadManagerService _downloadManager = DownloadManagerService.instance;

  @override
  void initState() {
    super.initState();
    _selectedQuality = determineInitialQuality(widget.videoData);
  }

  void _startDownloadAndDismiss() {
    if (_isDownloading) return;

    setState(() => _isDownloading = true);

    final logic = DownloadLogic(
      context: context,
      videoData: widget.videoData,
      quality: _selectedQuality,
    );

    logic.startDownload(
      onError: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initiate download: $e'),
            backgroundColor: Colors.red,
          ),
        );
      },
      onComplete: () {
        if (!mounted) return;
        setState(() => _isDownloading = false);
      },
    );

    widget.onDownloadInitiated();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String musicDurationText = getMusicDurationText(widget.videoData);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 5)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.videoData.title ?? 'Download Options',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 15),
          Text('Select Quality:', style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          ...buildQualityTiles(context, widget.videoData, _selectedQuality, (newVal) {
            if (newVal != null) setState(() => _selectedQuality = newVal);
          }, musicDurationText),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isDownloading || _selectedQuality == VideoQuality.none ? null : _startDownloadAndDismiss,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Icon(Icons.download, color: Colors.white),
              label: Text(
                _isDownloading ? 'Starting Download...' : 'Download',
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
