// Path: main.dart

import 'package:flutter/material.dart';
import 'package:tubemate/config/theme/app_theme.dart';
import 'package:tubemate/config/theme/theme_controller.dart';
import 'package:tubemate/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // <--- NEW IMPORT

// Global instance for notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Define notification channel details (for Android O and above)
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'download_progress_channel', // id
  'Download Progress', // name
  description: 'Notifications for ongoing downloads.', // description
  importance: Importance.low, // Low importance to avoid sound/vibration unless needed
  playSound: false, // Don't play sound for progress updates
  enableVibration: false, // Don't vibrate
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized before plugins

  // Initialize notifications
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // Use your app icon
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create notification channel for Android O+
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'TubeMate',
          theme: lightAppTheme,
          darkTheme: darkAppTheme,
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
        );
      },
    );
  }
}