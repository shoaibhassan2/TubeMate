import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> ensureStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        debugPrint('MANAGE_EXTERNAL_STORAGE already granted.');
        return true;
      } else {
        // For Android 11 (API 30) and above, MANAGE_EXTERNAL_STORAGE is required for broad file access.
        // It requires the user to go to settings.
        if (await Permission.manageExternalStorage.request().isGranted) {
          debugPrint('MANAGE_EXTERNAL_STORAGE granted after request.');
          return true;
        } else {
          // Fallback for older Android or if MANAGE_EXTERNAL_STORAGE is not granted.
          // Request READ_EXTERNAL_STORAGE as it might still work on some devices/versions.
          final storageStatus = await Permission.storage.request();
          if (storageStatus.isGranted) {
            debugPrint('READ_EXTERNAL_STORAGE granted (MANAGE_EXTERNAL_STORAGE not granted).');
            return true; // Still return true if basic storage is granted, as it might be enough for some cases.
          } else {
            debugPrint('Storage permissions denied.');
            return false;
          }
        }
      }
    }
    // For iOS or other platforms, or if not Android, assume permissions are not an issue.
    return true;
  }
}
