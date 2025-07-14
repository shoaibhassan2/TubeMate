import 'package:tubemate/core/services/permission_service.dart';
import 'package:tubemate/features/whatsapp_saver/data/models/whatsapp_status_model.dart';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'package:flutter/foundation.dart';

class WhatsappSaveService {
  Future<bool> saveStatus(WhatsappStatusModel status) async {
    try {
      final hasPermission = await PermissionService.ensureStoragePermission();
      if (!hasPermission) {
        debugPrint('WhatsappSaveService: Storage permissions not granted. Cannot save file.');
        return false;
      }

      debugPrint('WhatsappSaveService: Attempting to save file to gallery: ${status.filePath}');
      await FlutterImageGallerySaver.saveFile(status.filePath);
      debugPrint('WhatsappSaveService: SaveFile method called. Assuming success if no error thrown.');
      return true;

    } catch (e, stacktrace) {
      debugPrint('WhatsappSaveService: Error saving status ${status.filePath}: $e');
      debugPrint('WhatsappSaveService: Stacktrace: $stacktrace');
      return false;
    }
  }
}
