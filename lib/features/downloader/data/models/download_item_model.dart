// Path: lib/features/downloader/data/models/download_item_model.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // <--- NEW IMPORT for CancelToken
import 'package:tubemate/features/downloader/domain/enums/download_status.dart';

// Enum to define the status of a download (already defined in its own file)

class DownloadItemModel {
  final String id;
  final String fileName;
  final String downloadUrl;
  final String thumbnailUrl;
  final String? tempLocalFilePath;
  final String? publicGalleryPath;
  final bool isVideo;

  DownloadStatus status;
  double progress;
  String? errorMessage;
  CancelToken? cancelToken; // <--- NEW: To manage pausing/cancelling downloads

  DownloadItemModel({
    required this.id,
    required this.fileName,
    required this.downloadUrl,
    required this.thumbnailUrl,
    this.tempLocalFilePath,
    this.publicGalleryPath,
    required this.isVideo,
    this.status = DownloadStatus.pending,
    this.progress = 0.0,
    this.errorMessage,
    this.cancelToken, // <--- NEW
  });

  static String generateId(String downloadUrl, bool isVideo, [int? timestamp]) {
    final currentTimestamp = timestamp ?? DateTime.now().microsecondsSinceEpoch;
    return '${downloadUrl.hashCode}_${isVideo ? 'video' : 'audio'}_$currentTimestamp';
  }

  DownloadItemModel copyWith({
    DownloadStatus? status,
    double? progress,
    String? tempLocalFilePath,
    String? publicGalleryPath,
    String? errorMessage,
    CancelToken? cancelToken, // <--- NEW
  }) {
    return DownloadItemModel(
      id: id,
      fileName: fileName,
      downloadUrl: downloadUrl,
      thumbnailUrl: thumbnailUrl,
      tempLocalFilePath: tempLocalFilePath ?? this.tempLocalFilePath,
      publicGalleryPath: publicGalleryPath ?? this.publicGalleryPath,
      isVideo: isVideo,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      cancelToken: cancelToken ?? this.cancelToken, // <--- NEW
    );
  }

  // --- NEW: Serialization methods for Shared Preferences (update to include cancelToken) ---
  // Note: CancelToken itself cannot be serialized directly. We only save/load its presence.
  // When loaded, the token will be null, and resume would start a new download.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'downloadUrl': downloadUrl,
      'thumbnailUrl': thumbnailUrl,
      'tempLocalFilePath': tempLocalFilePath,
      'publicGalleryPath': publicGalleryPath,
      'isVideo': isVideo,
      'status': status.index,
      'progress': progress,
      'errorMessage': errorMessage,
      // 'cancelToken' cannot be serialized
    };
  }

  factory DownloadItemModel.fromJson(Map<String, dynamic> json) {
    return DownloadItemModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      downloadUrl: json['downloadUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      tempLocalFilePath: json['tempLocalFilePath'] as String?,
      publicGalleryPath: json['publicGalleryPath'] as String?,
      isVideo: json['isVideo'] as bool,
      status: DownloadStatus.values[json['status'] as int],
      progress: json['progress'] as double,
      errorMessage: json['errorMessage'] as String?,
      // cancelToken will be null when loaded from JSON
    );
  }
}