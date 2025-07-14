import 'package:flutter/material.dart';
import 'package:tubemate/core/theme/theme_constants.dart';

final ThemeData darkAppTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kAccentColor,
    brightness: Brightness.dark,
    primary: kAccentColor,
    secondary: kSecondaryAccentColor,
    surface: kPrimaryColor,
    background: kPrimaryColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: kLightTextColor,
    onBackground: kLightTextColor,
    error: Colors.red,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: kPrimaryColor,
  dialogBackgroundColor: kPrimaryColor.withOpacity(0.95),
  textTheme: const TextTheme(
    displaySmall: TextStyle(fontFamily: Bold, fontSize: 20.0, color: kLightTextColor),
    headlineMedium: TextStyle(fontFamily: Bold, fontSize: 18.0, color: kLightTextColor),
    headlineSmall: TextStyle(fontFamily: Bold, fontSize: 16.0, color: kLightTextColor),
    titleLarge: TextStyle(fontFamily: Bold, fontSize: 14.0, color: kLightTextColor),
    bodyLarge: TextStyle(fontFamily: Regular, fontSize: 12.0, color: kLightTextColor),
    bodyMedium: TextStyle(fontFamily: Regular, fontSize: 10.0, color: kLightTextColor),
  ),
  iconTheme: const IconThemeData(color: Colors.grey),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: kLightTextColor,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: kAccentColor,
    unselectedItemColor: Colors.grey,
    backgroundColor: kPrimaryColor,
    type: BottomNavigationBarType.fixed,
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(color: kLightTextColor.withOpacity(0.5)),
    labelStyle: TextStyle(color: kLightTextColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Colors.white.withOpacity(0.1),
    prefixIconColor: kAccentColor,
  ),
);
