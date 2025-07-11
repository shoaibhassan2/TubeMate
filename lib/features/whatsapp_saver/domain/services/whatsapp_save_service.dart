import 'dart:io'; // Required for File
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:permission_handler/permission_handler.dart'; // For permission requests
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart'; // <--- The package in question

import 'package:tubemate/features/whatsapp_saver/data/models/whatsapp_status_model.dart';

class WhatsappSaveService {
  /// Saves a given WhatsApp status file (image or video) to the device's gallery
  /// using the `flutter_image_gallery_saver` package (version 0.0.2).
  ///
  /// This method calls `saveFile` from the plugin, which determines the media type
  /// based on the file extension.
  ///
  /// WARNING: This package is very old and unmaintained. It might not handle
  /// modern Android versions (10/11/12/13+) and their Scoped Storage rules correctly,
  /// leading to files not appearing in the gallery consistently or at all.
  /// It primarily relies on `WRITE_EXTERNAL_STORAGE`.
  ///
  /// Returns `true` if the save operation was successful, `false` otherwise.
  Future<bool> saveStatus(WhatsappStatusModel status) async {
    try {
      // 1. Request permissions.
      // Even with this old package, WRITE_EXTERNAL_STORAGE is fundamentally needed.
      // On Android 11+, MANAGE_EXTERNAL_STORAGE is the real solution for broad access.
      if (Platform.isAndroid) {
        bool hasPermission = false;
        if (await Permission.manageExternalStorage.isGranted) {
          hasPermission = true; // Full access (Android 11+)
          debugPrint('WhatsappSaveService: MANAGE_EXTERNAL_STORAGE permission granted.');
        } else {
          // Fallback to general storage permission for older Android or if MANAGE_EXTERNAL_STORAGE not granted
          // This will request READ/WRITE_EXTERNAL_STORAGE.
          final storageStatus = await Permission.storage.request();
          hasPermission = storageStatus.isGranted;
          debugPrint('WhatsappSaveService: Storage permission granted (fallback): $hasPermission');
        }

        if (!hasPermission) {
          debugPrint('WhatsappSaveService: Storage permissions not granted. Cannot save file.');
          return false;
        }
      }

      // 2. Call the saver based on file path.
      // The `flutter_image_gallery_saver` package (0.0.2) has a `saveFile` method
      // that takes a file path. ITS RETURN TYPE IS VOID.
      debugPrint('WhatsappSaveService: Attempting to save file to gallery: ${status.filePath}');
      // <--- THE FIX IS HERE: DON'T ASSIGN THE RESULT OF A VOID METHOD
      await FlutterImageGallerySaver.saveFile(status.filePath);
      // If no exception is thrown, we assume success as per void methods.
      debugPrint('WhatsappSaveService: SaveFile method called. Assuming success if no error thrown.');
      return true;

    } catch (e, stacktrace) {
      debugPrint('WhatsappSaveService: Error saving status ${status.filePath}: $e');
      debugPrint('WhatsappSaveService: Stacktrace: $stacktrace');
      return false; // Return false if any exception occurs during the save attempt
    }
  }
}