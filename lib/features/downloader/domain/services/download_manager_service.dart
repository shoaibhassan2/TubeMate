// Path: lib/features/downloader/domain/services/download_manager_service.dart

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // <--- NEW IMPORT for notifications

import 'package:tubemate/features/downloader/data/models/download_item_model.dart';
import 'package:tubemate/features/downloader/domain/enums/download_status.dart';
import 'package:tubemate/features/downloader/data/models/tiktok_data_model.dart';

// Import the global notification plugin instance from main.dart
import 'package:tubemate/main.dart' show flutterLocalNotificationsPlugin, channel; // <--- NEW IMPORT

class DownloadManagerService extends ValueNotifier<UnmodifiableListView<DownloadItemModel>> {
  final List<DownloadItemModel> _downloadsInternal = [];
  final Dio _dio = Dio();
  static const String _downloadsKey = 'persisted_downloads';

  DownloadManagerService._internal() : super(UnmodifiableListView([])) {
    _loadDownloads();
  }

  static final DownloadManagerService _instance = DownloadManagerService._internal();

  static DownloadManagerService get instance => _instance;

  void _updateAndNotify() {
    value = UnmodifiableListView(_downloadsInternal);
    _saveDownloads();
  }

  // --- Persistence methods ---

  Future<void> _loadDownloads() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? downloadsJson = prefs.getStringList(_downloadsKey);
    if (downloadsJson != null) {
      _downloadsInternal.clear();
      for (final jsonString in downloadsJson) {
        try {
          final Map<String, dynamic> jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
          _downloadsInternal.add(DownloadItemModel.fromJson(jsonMap));
        } catch (e) {
          debugPrint('DownloadManagerService: Error parsing persisted download: $e');
        }
      }
      debugPrint('DownloadManagerService: Loaded ${_downloadsInternal.length} downloads from preferences.');
      _updateAndNotify();
    }
  }

  Future<void> _saveDownloads() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> downloadsJson = _downloadsInternal.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_downloadsKey, downloadsJson);
    debugPrint('DownloadManagerService: Saved ${_downloadsInternal.length} downloads to preferences.');
  }

  // --- Clear methods ---

  /// Clears all completed and failed downloads from the list and persistence.
  Future<void> clearFinishedDownloads() async {
    _downloadsInternal.removeWhere((item) =>
        item.status == DownloadStatus.completed || item.status == DownloadStatus.failed);
    _updateAndNotify();
  }

  /// Clears all downloads (active, pending, completed, failed) from the list and persistence.
  /// Use with caution for active downloads.
  Future<void> clearAllDownloads() async {
    _downloadsInternal.clear();
    _updateAndNotify();
  }

  // --- Existing download logic ---

  /// Starts a download process.
  Future<void> startDownload({
    required String downloadUrl,
    required String fileName,
    required String thumbnailUrl,
    required bool isVideo,
  }) async {
    if (downloadUrl.isEmpty) {
      debugPrint('DownloadManagerService: Provided download URL is empty.');
      return;
    }

    final String id = DownloadItemModel.generateId(downloadUrl, isVideo);

    final DownloadItemModel downloadItem = DownloadItemModel(
      id: id,
      fileName: fileName,
      downloadUrl: downloadUrl,
      thumbnailUrl: thumbnailUrl,
      isVideo: isVideo,
      status: DownloadStatus.pending,
    );

    _downloadsInternal.add(downloadItem);
    _updateAndNotify();

    String? tempLocalFilePath;
    String? finalPublicDownloadPath;

    // Send initial notification
    _showDownloadNotification(downloadItem); // <--- NEW

    try {
      final tempDir = await getTemporaryDirectory();
      final downloadDirPathTemp = Directory('${tempDir.path}/TubeMate_Temp_Downloads');
      if (!await downloadDirPathTemp.exists()) {
        await downloadDirPathTemp.create(recursive: true);
      }
      tempLocalFilePath = '${downloadDirPathTemp.path}/$fileName';

      debugPrint('DownloadManagerService: Starting download of $fileName to temporary path: $tempLocalFilePath');
      _updateDownloadItem(downloadItem.id, status: DownloadStatus.downloading);

      await _dio.download(
        downloadUrl,
        tempLocalFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final double progress = received / total;
            _updateDownloadItem(downloadItem.id, progress: progress);
          }
        },
      );

      debugPrint('DownloadManagerService: Download to temporary path completed for $fileName');

      _updateDownloadItem(downloadItem.id, status: DownloadStatus.pending, progress: 0.0);
      debugPrint('DownloadManagerService: Attempting to save to public Downloads/TubeMate folder...');

      final Directory? downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('Could not access Downloads directory.');
      }
      final Directory tubemateDownloadsDir = Directory('${downloadsDir.path}/TubeMate');
      if (!await tubemateDownloadsDir.exists()) {
        await tubemateDownloadsDir.create(recursive: true);
      }
      final File publicDestinationFile = File('${tubemateDownloadsDir.path}/$fileName');

      if (await publicDestinationFile.exists()) {
        debugPrint('DownloadManagerService: File already exists in public folder, attempting to rename new copy.');
        final String nameWithoutExt = fileName.substring(0, fileName.lastIndexOf('.'));
        final String ext = fileName.substring(fileName.lastIndexOf('.'));
        final String newFileName = '$nameWithoutExt-${DateTime.now().millisecondsSinceEpoch}$ext';
        finalPublicDownloadPath = '${tubemateDownloadsDir.path}/$newFileName';
      } else {
        finalPublicDownloadPath = publicDestinationFile.path;
      }
      
      await File(tempLocalFilePath).copy(finalPublicDownloadPath!);
      
      debugPrint('DownloadManagerService: Successfully copied to public Downloads: $finalPublicDownloadPath');
      _updateDownloadItem(downloadItem.id, status: DownloadStatus.completed, tempLocalFilePath: tempLocalFilePath, publicGalleryPath: finalPublicDownloadPath);

    } on DioException catch (e) {
      debugPrint('DownloadManagerService: Download failed for $fileName: ${e.message}');
      _updateDownloadItem(downloadItem.id, status: DownloadStatus.failed, errorMessage: e.message);
    } catch (e, stacktrace) {
      debugPrint('DownloadManagerService: Unexpected error for $fileName: $e');
      debugPrint('DownloadManagerService: Stacktrace: $stacktrace');
      _updateDownloadItem(downloadItem.id, status: DownloadStatus.failed, errorMessage: e.toString());
    } finally {
      if (tempLocalFilePath != null) {
        final tempFile = File(tempLocalFilePath);
        if (await tempFile.exists()) {
          try {
            await tempFile.delete();
            debugPrint('DownloadManagerService: Cleaned up temporary file: $tempLocalFilePath');
          } catch (deleteEx) {
            debugPrint('DownloadManagerService: Failed to delete temp file: $deleteEx');
          }
        }
      }
    }
  }

  void _updateDownloadItem(String id, {
    DownloadStatus? status,
    double? progress,
    String? tempLocalFilePath,
    String? publicGalleryPath,
    String? errorMessage,
  }) {
    final int index = _downloadsInternal.indexWhere((item) => item.id == id);
    if (index != -1) {
      _downloadsInternal[index] = _downloadsInternal[index].copyWith(
        status: status,
        progress: progress,
        tempLocalFilePath: tempLocalFilePath,
        publicGalleryPath: publicGalleryPath,
        errorMessage: errorMessage,
      );
      _updateAndNotify();
      _showDownloadNotification(_downloadsInternal[index]); // <--- NEW: Update notification
    }
  }

  // --- NEW: Notification methods ---

  Future<void> _showDownloadNotification(DownloadItemModel item) async {
    final int notificationId = item.id.hashCode; // Use a stable ID for notification updates

    String title;
    String body;
    int? progressPercentage;

    switch (item.status) {
      case DownloadStatus.pending:
        title = "Starting Download";
        body = item.fileName;
        progressPercentage = 0;
        break;
      case DownloadStatus.downloading:
        title = "Downloading: ${(item.progress * 100).toStringAsFixed(0)}%";
        body = item.fileName;
        progressPercentage = (item.progress * 100).toInt();
        break;
      case DownloadStatus.completed:
        title = "Download Complete";
        body = "${item.fileName} saved to Downloads/TubeMate";
        progressPercentage = 100;
        break;
      case DownloadStatus.failed:
        title = "Download Failed!";
        body = "Error for ${item.fileName}: ${item.errorMessage ?? 'Unknown error'}";
        progressPercentage = null; // No progress for failed
        break;
      case DownloadStatus.cancelled: // Not yet implemented, but good to have
        title = "Download Cancelled";
        body = item.fileName;
        progressPercentage = null;
        break;
      case DownloadStatus.paused: // Not yet implemented
        title = "Download Paused";
        body = item.fileName;
        progressPercentage = (item.progress * 100).toInt();
        break;
    }

    // Determine if it's an ongoing progress notification or a final one
    final bool isOngoing = item.status == DownloadStatus.downloading || item.status == DownloadStatus.pending;

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: Priority.low, // Lower priority for ongoing, can be high for completed/failed
          playSound: channel.playSound,
          enableVibration: channel.enableVibration,
          showProgress: isOngoing, // Show progress bar
          maxProgress: 100,
          progress: progressPercentage ?? 0, // Current progress
          ongoing: isOngoing, // Make it an ongoing notification
          autoCancel: !isOngoing, // Auto cancel if not ongoing (i.e., completed, failed, cancelled)
          visibility: NotificationVisibility.public, // Visible on lock screen
          icon: '@mipmap/ic_launcher', // Use your app icon
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: !isOngoing,
          presentBadge: !isOngoing,
          presentSound: !isOngoing,
        ),
      ),
    );
  }
}