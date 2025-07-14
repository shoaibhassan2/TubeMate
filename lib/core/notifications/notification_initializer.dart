import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'notification_callback_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'download_progress_channel',
  'Download Progress',
  description: 'Notifications for ongoing downloads.',
  importance: Importance.low,
  playSound: false,
  enableVibration: false,
);

Future<void> initializeNotifications() async {
  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  final InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (notificationResponse) async {
      notificationTapBackground(notificationResponse);
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}
