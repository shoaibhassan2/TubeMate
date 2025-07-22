// Path: lib/features/downloader/data/models/download_item_model.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tubemate/features/downloader/domain/enums/download_status.dart';

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
  CancelToken? cancelToken;

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
    this.cancelToken,
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
    CancelToken? cancelToken,
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
    );
  }
}