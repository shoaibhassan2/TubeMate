// Path: lib/core/theme/light_theme.dart

import 'package:flutter/material.dart';
import 'package:tubemate/core/theme/theme_constants.dart'; 


// Light Theme Configuration
final ThemeData lightAppTheme = ThemeData(
  brightness: Brightness.light,
  // Using ColorScheme.fromSeed for better color consistency and flexibility
  colorScheme: ColorScheme.fromSeed(
    seedColor: kAccentColor, // Use kAccentColor as the primary seed for light theme
    brightness: Brightness.light,
    primary: kAccentColor,
    secondary: kSecondaryAccentColor,
    surface: Colors.white,
    background: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: kDarkTextColor, // Defined in theme_constants
    onBackground: kDarkTextColor,
    error: Colors.red,
    onError: Colors.white,
  ),
  primarySwatch: Colors.teal, // Kept for primary swatch compatibility if widgets still rely on it
  scaffoldBackgroundColor: Colors.white, // Explicitly set for light theme
  dialogBackgroundColor: Colors.white, // Default for AlertDialogs

  textTheme: const TextTheme(
    displaySmall: TextStyle(fontFamily: Bold, fontSize: 20.0, color: kDarkTextColor),
    headlineMedium: TextStyle(fontFamily: Bold, fontSize: 18.0, color: kDarkTextColor),
    headlineSmall: TextStyle(fontFamily: Bold, fontSize: 16.0, color: kDarkTextColor),
    titleLarge: TextStyle(fontFamily: Bold, fontSize: 14.0, color: kDarkTextColor),
    bodyLarge: TextStyle(fontFamily: Regular, fontSize: 12.0, color: kDarkTextColor),
    bodyMedium: TextStyle(fontFamily: Regular, fontSize: 10.0, color: kDarkTextColor),
  ),
  iconTheme: IconThemeData(
    color: Colors.grey.shade600,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: kDarkTextColor, // Text color for AppBar title/icons in light mode
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: kAccentColor, // Use accent color for selected icon/label
    unselectedItemColor: Colors.grey.shade600, // Consistent with general icon theme
    backgroundColor: Colors.white,
    type: BottomNavigationBarType.fixed, // Ensure labels are always visible

  
  ),
  // Input field decoration for search and paksim widgets
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(color: kDarkTextColor.withOpacity(0.5)),
    labelStyle: TextStyle(color: kDarkTextColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Colors.black.withOpacity(0.04), // Subtle background for light mode inputs
    prefixIconColor: kAccentColor, // Icon color in input fields
  ),
);