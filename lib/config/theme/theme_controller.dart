import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global instance of ThemeController for easy access
final themeController = ThemeController();

class ThemeController extends ValueNotifier<ThemeMode> {
  static const _key = 'theme_mode'; // Key for SharedPreferences

  // Constructor: initializes with system theme and loads saved preference
  ThemeController() : super(ThemeMode.system) {
    _loadTheme();
  }

  // Loads the saved theme mode from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_key) ?? ThemeMode.system.index; // Get index or default to system
    value = ThemeMode.values[idx]; // Set the current theme mode
  }

  // Sets a new theme mode and saves it to SharedPreferences
  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, mode.index); // Save the new mode's index
    value = mode; // Update the current value to notify listeners
  }
}