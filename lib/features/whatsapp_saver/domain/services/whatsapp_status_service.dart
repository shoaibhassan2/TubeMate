import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tubemate/core/services/permission_service.dart';
import 'package:tubemate/features/whatsapp_saver/constants/whatsapp_paths.dart';
import 'package:tubemate/features/whatsapp_saver/data/models/whatsapp_status_model.dart';
import 'package:tubemate/features/whatsapp_saver/utils/video_thumbnail_helper.dart';

class WhatsappStatusService {
  static const List<String> _validExtensions = ['.jpg', '.jpeg', '.png', '.mp4'];

  /// Tries to get status files from both WhatsApp and WhatsApp Business folders
  Future<List<WhatsappStatusModel>> getWhatsappStatuses() async {
    final bool hasPermissions = await PermissionService.ensureStoragePermission();
    if (!hasPermissions) {
      throw Exception(
        'Storage permissions not granted. Please enable "All files access" in app settings.'
      );
    }

    final List<String> pathsToCheck = [
      WhatsappPaths.statusDirectory,
      WhatsappPaths.businessStatusDirectory
    ];

    final List<WhatsappStatusModel> allStatuses = [];

    for (final path in pathsToCheck) {
      final directory = Directory(path);
      if (!await directory.exists()) continue;

      final entities = directory.listSync(recursive: false, followLinks: false);
      for (final entity in entities) {
        if (entity is! File) continue;
        final String fileName = entity.uri.pathSegments.last;
        if (fileName.startsWith('.')) continue;
        if (!_validExtensions.any((ext) => fileName.toLowerCase().endsWith(ext))) continue;

        final StatusType type = WhatsappStatusModel.getTypeFromFile(fileName);
        if (type == StatusType.unknown) continue;

        String? thumbnailPath;
        if (type == StatusType.video) {
          thumbnailPath = await VideoThumbnailHelper.generate(entity.path);
        }

        allStatuses.add(WhatsappStatusModel(
          filePath: entity.path,
          type: type,
          file: entity,
          thumbnailPath: thumbnailPath,
        ));
      }
    }

    return allStatuses;
  }
}