import 'package:flutter/material.dart';
import 'package:tubemate/config/theme/app_theme.dart';
import 'package:tubemate/config/theme/theme_controller.dart';
import 'package:tubemate/features/home/presentation/screens/home_screen.dart';
void main() => runApp(const MyApp());

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
          home: const HomeScreen(), // <--- Set SplashScreen as the initial screen
        );
      },
    );
  }
}