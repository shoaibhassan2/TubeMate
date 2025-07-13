// Path: lib/features/downloader/presentation/widgets/download_options_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:tubemate/features/downloader/data/models/tiktok_data_model.dart';
import 'package:tubemate/features/downloader/domain/services/download_manager_service.dart';

// Enum for quality options
enum VideoQuality {
  hdNoWatermark, // Corresponds to 'play' or 'hdplay'
  hdWithWatermark, // Corresponds to 'wmplay'
  audioOnly, // Corresponds to 'music'
  none, // No selection
}

class DownloadOptionsBottomSheet extends StatefulWidget {
  final TikTokVideoData videoData; // Data fetched from TikTok API

  const DownloadOptionsBottomSheet({
    super.key,
    required this.videoData,
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
    // Initialize selected quality based on what's available
    if ((widget.videoData.hdplay != null && widget.videoData.hdplay!.isNotEmpty) ||
        (widget.videoData.play != null && widget.videoData.play!.isNotEmpty)) {
      _selectedQuality = VideoQuality.hdNoWatermark;
    } else if (widget.videoData.wmplay != null && widget.videoData.wmplay!.isNotEmpty) {
      _selectedQuality = VideoQuality.hdWithWatermark;
    } else if (widget.videoData.music != null && widget.videoData.music!.isNotEmpty) {
      _selectedQuality = VideoQuality.audioOnly;
    } else {
      _selectedQuality = VideoQuality.none; // No default selection if nothing is available
    }
  }

  // Helper to get the correct download URL based on selected quality
  String? _getDownloadUrl(VideoQuality quality) {
    switch (quality) {
      case VideoQuality.hdNoWatermark:
        return widget.videoData.hdplay ?? widget.videoData.play;
      case VideoQuality.hdWithWatermark:
        return widget.videoData.wmplay;
      case VideoQuality.audioOnly:
        return widget.videoData.music;
      case VideoQuality.none:
        return null;
    }
  }

  // Helper to get the file extension based on selected quality
  String _getFileExtension(VideoQuality quality) {
    switch (quality) {
      case VideoQuality.hdNoWatermark:
      case VideoQuality.hdWithWatermark:
        return '.mp4';
      case VideoQuality.audioOnly:
        return '.mp3';
      case VideoQuality.none:
        return '';
    }
  }

  // Method to handle the download button press
  Future<void> _startDownload() async {
    if (_isDownloading) return;

    final String? selectedDownloadUrl = _getDownloadUrl(_selectedQuality);
    final String fileExtension = _getFileExtension(_selectedQuality);
    final bool isVideo = (_selectedQuality != VideoQuality.audioOnly);

    if (selectedDownloadUrl == null || selectedDownloadUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected quality URL is not available.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      String sanitizedTitle = widget.videoData.title?.replaceAll(RegExp(r'[^\w\s.-]'), '') ?? 'tiktok_download';
      const int maxFileNameLength = 100;
      if (sanitizedTitle.length > maxFileNameLength) {
        sanitizedTitle = sanitizedTitle.substring(0, maxFileNameLength);
        if (sanitizedTitle.length > 5) {
          sanitizedTitle = '${sanitizedTitle.substring(0, maxFileNameLength - 5)}...';
        }
      }
      final String fileName = '$sanitizedTitle$fileExtension';

      await _downloadManager.startDownload(
        downloadUrl: selectedDownloadUrl,
        fileName: fileName,
        thumbnailUrl: widget.videoData.cover ?? '',
        isVideo: isVideo,
      );

      if (mounted) {
        Navigator.pop(context); // Close the bottom sheet on success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download started! Check Downloads tab.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start download: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final double musicDurationMinutes = (widget.videoData.musicInfo?.duration ?? 0) / 60.0;
    String musicDurationText = '';
    if (widget.videoData.musicInfo?.duration != null && widget.videoData.musicInfo!.duration! > 0) {
      musicDurationText = '~${musicDurationMinutes.toStringAsFixed(1)} min';
    }


    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
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
          Text(
            'Select Quality:',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 10),

          // HD Video (No Watermark) Option (using play or hdplay)
          if ((widget.videoData.play != null && widget.videoData.play!.isNotEmpty) ||
             (widget.videoData.hdplay != null && widget.videoData.hdplay!.isNotEmpty))
            ListTile(
              // <--- ADDED onTap to ListTile for Radio button selection
              onTap: () => setState(() => _selectedQuality = VideoQuality.hdNoWatermark),
              title: Text('HD Video (No Watermark)', style: theme.textTheme.bodyLarge),
              leading: Radio<VideoQuality>(
                value: VideoQuality.hdNoWatermark,
                groupValue: _selectedQuality,
                onChanged: (VideoQuality? value) {
                  if (value != null) setState(() => _selectedQuality = value);
                },
                activeColor: theme.colorScheme.primary,
              ),
              trailing: Text(
                '~${((widget.videoData.hdSize ?? widget.videoData.size ?? 0) / (1024 * 1024)).toStringAsFixed(1)} MB',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),

          // HD Video (With Watermark) Option
          if (widget.videoData.wmplay != null && widget.videoData.wmplay!.isNotEmpty)
            ListTile(
              // <--- ADDED onTap to ListTile for Radio button selection
              onTap: () => setState(() => _selectedQuality = VideoQuality.hdWithWatermark),
              title: Text('HD Video (With Watermark)', style: theme.textTheme.bodyLarge),
              leading: Radio<VideoQuality>(
                value: VideoQuality.hdWithWatermark,
                groupValue: _selectedQuality,
                onChanged: (VideoQuality? value) {
                  if (value != null) setState(() => _selectedQuality = value);
                },
                activeColor: theme.colorScheme.primary,
              ),
              trailing: Text(
                '~${((widget.videoData.wmSize ?? 0) / (1024 * 1024)).toStringAsFixed(1)} MB',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
          
          // Audio Only Option
          if (widget.videoData.music != null && widget.videoData.music!.isNotEmpty)
            ListTile(
              // <--- ADDED onTap to ListTile for Radio button selection
              onTap: () => setState(() => _selectedQuality = VideoQuality.audioOnly),
              title: Text('Audio Only', style: theme.textTheme.bodyLarge),
              leading: Radio<VideoQuality>(
                value: VideoQuality.audioOnly,
                groupValue: _selectedQuality,
                onChanged: (VideoQuality? value) {
                  if (value != null) setState(() => _selectedQuality = value);
                },
                activeColor: theme.colorScheme.primary,
              ),
              trailing: Text(
                musicDurationText,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              // Disable if no quality is selected or downloading
              onPressed: _isDownloading || _selectedQuality == VideoQuality.none ? null : _startDownload,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.download, color: Colors.white),
              label: Text(
                _isDownloading ? 'Starting Download...' : 'Download',
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}