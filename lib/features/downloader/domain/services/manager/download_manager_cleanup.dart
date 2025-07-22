import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:tubemate/features/downloader/data/models/download_item_model.dart';
import 'package:tubemate/features/downloader/domain/enums/download_status.dart';
import 'package:tubemate/core/notifications/notification_initializer.dart'
    show flutterLocalNotificationsPlugin;

class DownloadManagerCleanup {
  static Future<void> clearFinishedDownloads(List<DownloadItemModel> downloads) async {
    downloads.removeWhere((item) =>
        item.status == DownloadStatus.completed || item.status == DownloadStatus.failed);
  }

  static Future<void> clearAllDownloads(List<DownloadItemModel> downloads) async {
    for (final item in downloads) {
      item.cancelToken?.cancel('App clearing all downloads.');
      await _deleteFileFromDisk(item.tempLocalFilePath);
      await _deleteFileFromDisk(item.publicGalleryPath);
    }
    downloads.clear();
  }

  static Future<void> deleteDownloadById(List<DownloadItemModel> downloads, String id) async {
    final int index = downloads.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = downloads[index];
      item.cancelToken?.cancel('User deleted download.');
      await _deleteFileFromDisk(item.tempLocalFilePath);
      await _deleteFileFromDisk(item.publicGalleryPath);
      downloads.removeAt(index);
      flutterLocalNotificationsPlugin.cancel(item.id.hashCode);
    }
  }

  static Future<void> _deleteFileFromDisk(String? filePath) async {
    if (filePath != null) {
      final file = File(filePath);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (e) {
          debugPrint('DownloadManagerCleanup: Failed to delete file $filePath: $e');
        }
      }
    }
  }
}
