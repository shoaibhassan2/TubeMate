import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tubemate/core/notifications/notification_initializer.dart';
import 'package:tubemate/features/downloader/data/models/download_item_model.dart';
import 'package:tubemate/features/downloader/domain/enums/download_status.dart';

class DownloadNotificationService {
  const DownloadNotificationService(); // optional singleton-style instantiation

  Future<void> showDownloadNotification(DownloadItemModel item) async {
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
        progressPercentage = null;
        isOngoing = false;
        actions.add(AndroidNotificationAction('dismiss_notification_action', 'Dismiss'));
        break;
      case DownloadStatus.paused:
        title = "Download Paused";
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
