import 'package:flutter/material.dart';
import 'package:tubemate/features/downloader/data/models/tiktok_data_model.dart';
import 'package:tubemate/features/downloader/domain/services/download_manager_service.dart';
import 'quality_enum.dart';

class DownloadLogic {
  final BuildContext context;
  final TikTokVideoData videoData;
  final VideoQuality quality;

  DownloadLogic({
    required this.context,
    required this.videoData,
    required this.quality,
  });

  String? _getDownloadUrl() {
    switch (quality) {
      case VideoQuality.hdNoWatermark:
        return videoData.hdplay ?? videoData.play;
      case VideoQuality.hdWithWatermark:
        return videoData.wmplay;
      case VideoQuality.audioOnly:
        return videoData.music;
      case VideoQuality.none:
        return null;
    }
  }

  String _getFileExtension() {
    switch (quality) {
      case VideoQuality.audioOnly:
        return '.mp3';
      default:
        return '.mp4';
    }
  }

  void startDownload({
    required void Function(String error) onError,
    required VoidCallback onComplete,
  }) {
    final url = _getDownloadUrl();
    if (url == null || url.isEmpty) {
      onError('Selected quality URL is not available.');
      return;
    }

    final isVideo = quality != VideoQuality.audioOnly;
    String sanitizedTitle = videoData.title?.replaceAll(RegExp(r'[^\w\s.-]'), '') ?? 'tiktok_download';
    if (sanitizedTitle.length > 100) {
      sanitizedTitle = sanitizedTitle.substring(0, 95) + '...';
    }

    final fileName = '$sanitizedTitle${_getFileExtension()}';

    DownloadManagerService.instance.startDownload(
      downloadUrl: url,
      fileName: fileName,
      thumbnailUrl: videoData.cover ?? '',
      isVideo: isVideo,
    ).catchError((e) {
      onError(e.toString());
    }).whenComplete(onComplete);
  }
}
