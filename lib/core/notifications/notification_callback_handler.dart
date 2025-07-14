import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:open_file/open_file.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tubemate/features/downloader/domain/services/download_manager_service.dart';
import 'notification_initializer.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('Tapped notification: ${notificationResponse.notificationResponseType}');
  debugPrint('Action ID: ${notificationResponse.actionId}, Payload: ${notificationResponse.payload}');

  if (notificationResponse.notificationResponseType == NotificationResponseType.selectedNotificationAction) {
    final String? actionId = notificationResponse.actionId;
    final String? notificationPayload = notificationResponse.payload;

    if (actionId != null && notificationPayload != null) {
      try {
        final payload = jsonDecode(notificationPayload) as Map<String, dynamic>;
        final String? downloadId = payload['downloadId'];

        if (downloadId == null) return;

        final manager = DownloadManagerService.instance;

        switch (actionId) {
          case 'open_file_action':
            final path = payload['filePath'] as String?;
            if (path != null) OpenFile.open(path);
            break;
          case 'dismiss_notification_action':
            flutterLocalNotificationsPlugin.cancel(downloadId.hashCode);
            break;
          case 'retry_download_action':
          case 'resume_download_action':
            manager.resumeDownload(downloadId);
            break;
          case 'pause_download_action':
            manager.pauseDownload(downloadId);
            break;
          case 'cancel_download_action':
            manager.cancelDownload(downloadId);
            break;
          case 'delete_download_action':
            manager.deleteDownload(downloadId);
            break;
          default:
            debugPrint('Unhandled action ID: $actionId');
        }
      } catch (e) {
        debugPrint('Notification parsing error: $e');
      }
    }
  }
}
