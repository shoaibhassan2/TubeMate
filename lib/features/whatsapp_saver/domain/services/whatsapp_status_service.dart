import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

import 'package:tubemate/features/whatsapp_saver/data/models/whatsapp_status_model.dart';

class WhatsappStatusService {
  // The common WhatsApp Statuses directory path on Android.
  static const String _whatsappStatusPath = '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses';

  /// Requests necessary storage permissions, prioritizing MANAGE_EXTERNAL_STORAGE for Android 11+.
  /// Returns true if permissions are granted and directory is accessible, false otherwise.
  Future<bool> requestPermissions() async {
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


  /// Checks if the WhatsApp Statuses directory exists and is accessible.
  Future<bool> _isStatusesDirectoryAccessible() async {
    final Directory statusDir = Directory(_whatsappStatusPath);
    try {
      return await statusDir.exists();
    } catch (e) {
      debugPrint("Error checking directory existence: $e");
      return false;
    }
  }

  /// Retrieves a list of WhatsApp status files (images and videos).
  ///
  /// Returns a Future<List<WhatsappStatusModel>>.
  /// Throws an [Exception] if permissions are not granted or directory is not accessible.
  Future<List<WhatsappStatusModel>> getWhatsappStatuses() async {
    // 1. Check for storage permissions first
    final bool hasPermissions = await requestPermissions();
    if (!hasPermissions) {
      throw Exception('Storage permissions not granted. Please enable "All files access" in app settings.');
    }

    // 2. Check if the WhatsApp Statuses directory is accessible
    final bool isAccessible = await _isStatusesDirectoryAccessible();
    if (!isAccessible) {
      throw Exception(
          'WhatsApp Statuses directory not found or not accessible. '
          'This might be due to Android version restrictions (e.g., Scoped Storage) or WhatsApp settings. '
          'Please ensure you have viewed some statuses in WhatsApp and granted "All files access" permission.');
    }

    final Directory statusDir = Directory(_whatsappStatusPath);
    final List<FileSystemEntity> entities = statusDir.listSync(recursive: false, followLinks: false);

    final List<WhatsappStatusModel> statuses = [];

    // 3. Process each file in the directory
    for (final FileSystemEntity entity in entities) {
      if (entity is File) {
        final String fileName = entity.uri.pathSegments.last;

        // Skip hidden files like .nomedia and other dotfiles
        if (fileName.startsWith('.')) continue;

        final StatusType type = WhatsappStatusModel.getTypeFromFile(fileName);

        if (type != StatusType.unknown) {
          String? thumbnailPath;
          if (type == StatusType.video) {
            // Generate thumbnail for video files
            thumbnailPath = await _generateVideoThumbnail(entity.path);
          }
          statuses.add(WhatsappStatusModel(
            filePath: entity.path,
            type: type,
            file: entity,
            thumbnailPath: thumbnailPath,
          ));
        }
      }
    }
    return statuses;
  }

  /// Generates a thumbnail for a given video file path.
  /// Returns the path to the generated thumbnail image (JPEG).
  Future<String?> _generateVideoThumbnail(String videoPath) async {
    try {
      final tempDir = await getTemporaryDirectory(); // Get app's temporary directory
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: tempDir.path, // Save thumbnail in temp directory
        imageFormat: ImageFormat.JPEG,
        maxHeight: 128, // Max height of the thumbnail
        maxWidth: 128, // Max width of the thumbnail
        quality: 75, // Quality of the thumbnail (0-100)
      );
      return thumbnailPath;
    } catch (e) {
      debugPrint('Error generating video thumbnail for $videoPath: $e');
      return null; // Return null if thumbnail generation fails
    }
  }
}