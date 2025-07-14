// Path: lib/features/downloader/domain/services/download_manager_service.dart

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:tubemate/features/downloader/data/models/download_item_model.dart'; 
import 'package:tubemate/features/downloader/domain/enums/download_status.dart'; 
import 'package:tubemate/features/downloader/data/models/tiktok_data_model.dart'; 

import 'package:tubemate/core/notifications/notification_initializer.dart'
    show flutterLocalNotificationsPlugin, channel;

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

  // --- Clear/Delete methods ---

  /// Clears all completed and failed downloads from the list and persistence.
  Future<void> clearFinishedDownloads() async {
    _downloadsInternal.removeWhere((item) =>
        item.status == DownloadStatus.completed || item.status == DownloadStatus.failed);
    _updateAndNotify();
  }

  /// Clears all downloads (active, pending, completed, failed) from the list and persistence.
  /// This will also attempt to delete associated files.
  Future<void> clearAllDownloads() async {
    for (final item in _downloadsInternal) {
      item.cancelToken?.cancel('App clearing all downloads.');
      await _deleteFileFromDisk(item.tempLocalFilePath);
      await _deleteFileFromDisk(item.publicGalleryPath);
    }
    _downloadsInternal.clear();
    _updateAndNotify();
  }

  /// Deletes a specific download item and its associated files from disk and persistence.
  Future<void> deleteDownload(String id) async {
    final int index = _downloadsInternal.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _downloadsInternal[index];
      item.cancelToken?.cancel('User deleted download.');
      await _deleteFileFromDisk(item.tempLocalFilePath);
      await _deleteFileFromDisk(item.publicGalleryPath);
      
      _downloadsInternal.removeAt(index);
      _updateAndNotify();
      flutterLocalNotificationsPlugin.cancel(item.id.hashCode);
    }
  }

  // Helper to delete files safely
  Future<void> _deleteFileFromDisk(String? filePath) async {
    if (filePath != null) {
      final file = File(filePath);
      if (await file.exists()) {
        try {
          await file.delete();
          debugPrint('DownloadManagerService: Deleted file from disk: $filePath');
        } catch (e) {
          debugPrint('DownloadManagerService: Failed to delete file $filePath: $e');
        }
      }
    }
  }

  // --- Download Control methods ---

  Future<void> pauseDownload(String id) async {
    final int index = _downloadsInternal.indexWhere((item) => item.id == id);
    if (index != -1 && _downloadsInternal[index].status == DownloadStatus.downloading) {
      _updateDownloadItem(id, status: DownloadStatus.paused); // Set status to paused FIRST
      _downloadsInternal[index].cancelToken?.cancel('Download paused by user');
      debugPrint('DownloadManagerService: Signaled pause for download: ${id}');
    }
  }

  Future<void> resumeDownload(String id) async {
    final int index = _downloadsInternal.indexWhere((item) => item.id == id);
    // Can only resume if currently paused or failed (as retry also uses resume)
    if (index == -1 || (_downloadsInternal[index].status != DownloadStatus.paused && _downloadsInternal[index].status != DownloadStatus.failed)) {
      debugPrint('DownloadManagerService: Cannot resume. Item not found or not paused/failed.');
      return;
    }

    final DownloadItemModel itemToResume = _downloadsInternal[index];
    debugPrint('DownloadManagerService: Attempting to resume download: ${itemToResume.id}');

    // Update status to pending immediately to show responsiveness
    _updateDownloadItem(itemToResume.id, status: DownloadStatus.pending);

    // Determine start bytes. Crucially, use the tempLocalFilePath from the item.
    int startBytes = 0;
    if (itemToResume.tempLocalFilePath != null) {
      final File tempFile = File(itemToResume.tempLocalFilePath!);
      if (await tempFile.exists()) {
        startBytes = await tempFile.length();
        debugPrint('DownloadManagerService: Resuming from offset: $startBytes bytes for ${itemToResume.fileName}.');
      } else {
        debugPrint('DownloadManagerService: Temp file not found for resume. Restarting from 0 for ${itemToResume.fileName}.');
        startBytes = 0; // If temp file is gone, restart from beginning
      }
    } else {
      debugPrint('DownloadManagerService: No temp file path for resume. Restarting from 0 for ${itemToResume.fileName}.');
      startBytes = 0;
    }

    final newCancelToken = CancelToken(); // Create a new token for the resumed download
    // Update the item in the list with the new token *before* executing the download
    _downloadsInternal[index] = itemToResume.copyWith(cancelToken: newCancelToken); 
    
    // Call _executeDownload to perform the actual download.
    // It will use the updated item from the list, which has the new cancelToken and correct tempLocalFilePath.
    _executeDownload(
      downloadItem: _downloadsInternal[index], // Pass the updated item from list
      startBytes: startBytes,
    );
  }
  
  Future<void> cancelDownload(String id) async {
    final int index = _downloadsInternal.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _downloadsInternal[index];
      _updateDownloadItem(id, status: DownloadStatus.cancelled); // Set status to cancelled FIRST
      item.cancelToken?.cancel('Download cancelled by user');
      debugPrint('DownloadManagerService: Signaled cancel for download: ${id}');
    }
  }

  // --- New Helper Method: _executeDownload ---
  // This encapsulates the core download logic.
  // It should only be called by startDownload or resumeDownload.
  Future<void> _executeDownload({
    required DownloadItemModel downloadItem,
    int startBytes = 0, // For resume functionality
  }) async {
    // Ensure tempLocalFilePath is initialized and used correctly
    // If it's null on a fresh download (startBytes == 0), create it.
    // If resuming (startBytes > 0), it *must* come from downloadItem.tempLocalFilePath.
    String tempLocalFilePath;
    if (downloadItem.tempLocalFilePath == null) {
      final tempDir = await getTemporaryDirectory();
      final downloadDirPathTemp = Directory('${tempDir.path}/TubeMate_Temp_Downloads');
      if (!await downloadDirPathTemp.exists()) {
        await downloadDirPathTemp.create(recursive: true);
      }
      tempLocalFilePath = '${downloadDirPathTemp.path}/${downloadItem.fileName}';
      _updateDownloadItem(downloadItem.id, tempLocalFilePath: tempLocalFilePath); // Update item with this new path
    } else {
      tempLocalFilePath = downloadItem.tempLocalFilePath!; // Use the existing path
    }

    try {
      debugPrint('DownloadManagerService: Executing download of ${downloadItem.fileName} to $tempLocalFilePath (from $startBytes bytes)');
      
      // Update status to downloading. Progress updated by onReceiveProgress.
      _updateDownloadItem(downloadItem.id, status: DownloadStatus.downloading);

      await _dio.download(
        downloadItem.downloadUrl,
        tempLocalFilePath, // Use the determined tempLocalFilePath
        onReceiveProgress: (received, total) {
          final int currentReceived = startBytes + received;
          if (total != -1) {
            // Calculate progress based on original total size + starting offset
            // Ensure the total for progress is always accurate (original total + startBytes)
            // or fetch content-length to get true total size for resume.
            // For simplicity, using (total + startBytes) for percentage.
            final double progress = currentReceived / (total + startBytes);
            _updateDownloadItem(downloadItem.id, progress: progress);
          }
        },
        options: Options(
          headers: startBytes > 0 ? {'Range': 'bytes=$startBytes-'} : null, // Set Range header for resume
          // Append data to existing file if resuming
          followRedirects: true, // Crucial for some downloads
          receiveTimeout: const Duration(seconds: 30), // Example timeout
        ),
        cancelToken: downloadItem.cancelToken,
      );

      debugPrint('DownloadManagerService: Download to temporary path completed for ${downloadItem.fileName}');

      // After download, attempt to save to public folder
      _updateDownloadItem(downloadItem.id, status: DownloadStatus.pending, progress: 0.0);
      debugPrint('DownloadManagerService: Attempting to save to public Downloads/TubeMate folder for ${downloadItem.fileName}...');

      final Directory? downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('Could not access Downloads directory.');
      }
      final Directory tubemateDownloadsDir = Directory('${downloadsDir.path}/TubeMate');
      if (!await tubemateDownloadsDir.exists()) {
        await tubemateDownloadsDir.create(recursive: true);
      }
      final File publicDestinationFile = File('${tubemateDownloadsDir.path}/${downloadItem.fileName}');

      String? finalPublicDownloadPath;
      if (await publicDestinationFile.exists()) {
        debugPrint('DownloadManagerService: File already exists in public folder, attempting to rename new copy.');
        final String nameWithoutExt = downloadItem.fileName.substring(0, downloadItem.fileName.lastIndexOf('.'));
        final String ext = downloadItem.fileName.substring(downloadItem.fileName.lastIndexOf('.'));
        final String newFileName = '$nameWithoutExt-${DateTime.now().millisecondsSinceEpoch}$ext';
        finalPublicDownloadPath = '${tubemateDownloadsDir.path}/$newFileName';
      } else {
        finalPublicDownloadPath = publicDestinationFile.path;
      }
      
      await File(tempLocalFilePath).copy(finalPublicDownloadPath!);
      
      debugPrint('DownloadManagerService: Successfully copied to public Downloads: $finalPublicDownloadPath');
      _updateDownloadItem(downloadItem.id, status: DownloadStatus.completed, tempLocalFilePath: tempLocalFilePath, publicGalleryPath: finalPublicDownloadPath);

    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        debugPrint('DownloadManagerService: Download ${downloadItem.id} was cancelled/paused. Error: ${e.message}');
        // Status is already set to PAUSED or CANCELLED by the explicit calls.
        // So, we do nothing here, the status is correct.
      } else {
        // This is a genuine failure (network, server, etc.)
        String errorMessage = 'Network error: ${e.type.name}';
        if (e.response != null) {
          errorMessage += ' (HTTP ${e.response?.statusCode})';
        } else if (e.message != null) {
          errorMessage += ' - ${e.message}';
        }
        debugPrint('DownloadManagerService: Download failed for ${downloadItem.fileName}: $errorMessage');
        _updateDownloadItem(downloadItem.id, status: DownloadStatus.failed, errorMessage: errorMessage);
      }
    } catch (e, stacktrace) {
      debugPrint('DownloadManagerService: Unexpected error for ${downloadItem.fileName}: $e');
      debugPrint('DownloadManagerService: Stacktrace: $stacktrace');
      _updateDownloadItem(downloadItem.id, status: DownloadStatus.failed, errorMessage: e.toString());
    } finally {
      // Clean up temporary file ONLY IF download is completed, failed, or cancelled.
      // If it's paused, we keep the temp file for resume.
      // Retrieve the *current* status from the updated list to decide.
      final currentItemState = _downloadsInternal.firstWhere((element) => element.id == downloadItem.id);
      if (currentItemState.status == DownloadStatus.completed || 
          currentItemState.status == DownloadStatus.failed || 
          currentItemState.status == DownloadStatus.cancelled) {
        if (tempLocalFilePath != null) {
          final tempFile = File(tempLocalFilePath);
          if (await tempFile.exists()) {
            try {
              await tempFile.delete();
              debugPrint('DownloadManagerService: Cleaned up temporary file: $tempLocalFilePath after final status.');
            } catch (deleteEx) {
              debugPrint('DownloadManagerService: Failed to delete temp file $tempLocalFilePath: $deleteEx');
            }
          }
        }
      }
    }
  }

  // --- Main download initiation logic ---
  @override
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
    final CancelToken cancelToken = CancelToken();

    final DownloadItemModel downloadItem = DownloadItemModel(
      id: id,
      fileName: fileName,
      downloadUrl: downloadUrl,
      thumbnailUrl: thumbnailUrl,
      isVideo: isVideo,
      status: DownloadStatus.pending,
      cancelToken: cancelToken,
    );

    final int existingItemIndex = _downloadsInternal.indexWhere((item) => item.id == id);
    if (existingItemIndex != -1) {
        // If an item with this specific ID (which includes a timestamp) already exists,
        // it means we are trying to start a new download *instance* but perhaps the old one
        // is stuck. We cancel the old one's token and replace the item.
        _downloadsInternal[existingItemIndex].cancelToken?.cancel('New download instance started for same ID.');
        _downloadsInternal[existingItemIndex] = downloadItem;
    } else {
        _downloadsInternal.add(downloadItem);
    }
    _updateAndNotify();

    // Start the actual download process (will run in its own async execution)
    _executeDownload(downloadItem: downloadItem);
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
      final DownloadItemModel currentItem = _downloadsInternal[index];
      
      final bool wasOngoing = currentItem.status == DownloadStatus.downloading ||
                              currentItem.status == DownloadStatus.pending ||
                              currentItem.status == DownloadStatus.paused;
      
      _downloadsInternal[index] = currentItem.copyWith(
        status: status,
        progress: progress,
        tempLocalFilePath: tempLocalFilePath,
        publicGalleryPath: publicGalleryPath,
        errorMessage: errorMessage,
      );
      _updateAndNotify();

      // Cancel notification if status transitioned from ongoing to final
      if (wasOngoing && (status == DownloadStatus.completed || status == DownloadStatus.failed || status == DownloadStatus.cancelled)) {
         flutterLocalNotificationsPlugin.cancel(currentItem.id.hashCode);
      }
      _showDownloadNotification(_downloadsInternal[index]);
    }
  }

  Future<void> _showDownloadNotification(DownloadItemModel item) async {
    final int notificationId = item.id.hashCode;

    String title;
    String body = item.fileName;
    int? progressPercentage;
    bool isOngoing = false;
    List<AndroidNotificationAction> actions = [];

    final Map<String, dynamic> notificationPayloadMap = {
      'downloadId': item.id,
      'fileName': item.fileName,
      'filePath': item.publicGalleryPath,
      'isVideo': item.isVideo,
      'status': item.status.name,
    };
    final String notificationPayloadJson = jsonEncode(notificationPayloadMap);

    switch (item.status) {
      case DownloadStatus.pending:
        title = "Starting Download";
        progressPercentage = 0;
        isOngoing = true;
        break;
      case DownloadStatus.downloading:
        title = "Downloading: ${(item.progress * 100).toStringAsFixed(0)}%";
        body = item.fileName;
        progressPercentage = (item.progress * 100).toInt();
        isOngoing = true;
        actions.add(AndroidNotificationAction('pause_download_action', 'Pause'));
        actions.add(AndroidNotificationAction('cancel_download_action', 'Cancel'));
        break;
      case DownloadStatus.completed:
        title = "Download Complete";
        body = "${item.fileName} saved!";
        progressPercentage = 100;
        isOngoing = false;
        if (item.publicGalleryPath != null && item.publicGalleryPath!.isNotEmpty) {
          actions.add(AndroidNotificationAction('open_file_action', 'Open File'));
        }
        actions.add(AndroidNotificationAction('dismiss_notification_action', 'Dismiss'));
        break;
      case DownloadStatus.failed:
        title = "Download Failed!";
        body = "Error for ${item.fileName}: ${item.errorMessage ?? 'Unknown error'}";
        progressPercentage = null;
        isOngoing = false;
        actions.add(AndroidNotificationAction('retry_download_action', 'Retry'));
        actions.add(AndroidNotificationAction('dismiss_notification_action', 'Dismiss'));
        break;
      case DownloadStatus.cancelled:
        title = "Download Cancelled";
        body = item.fileName;
        progressPercentage = null;
        isOngoing = false;
        actions.add(AndroidNotificationAction('dismiss_notification_action', 'Dismiss'));
        break;
      case DownloadStatus.paused:
        title = "Download Paused";
        body = item.fileName;
        progressPercentage = (item.progress * 100).toInt();
        isOngoing = true;
        actions.add(AndroidNotificationAction('resume_download_action', 'Resume'));
        actions.add(AndroidNotificationAction('cancel_download_action', 'Cancel'));
        break;
    }

    final bool showProgressBar = isOngoing && (progressPercentage != null);

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: isOngoing ? Importance.low : Importance.high,
          priority: isOngoing ? Priority.low : Priority.high,
          playSound: channel.playSound,
          enableVibration: channel.enableVibration,
          showProgress: showProgressBar,
          maxProgress: 100,
          progress: progressPercentage ?? 0,
          ongoing: isOngoing,
          autoCancel: !isOngoing,
          visibility: NotificationVisibility.public,
          icon: '@mipmap/ic_launcher',
          actions: actions,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: !isOngoing,
          presentBadge: !isOngoing,
          presentSound: !isOngoing,
        ),
      ),
      payload: notificationPayloadJson,
    );
  }
}