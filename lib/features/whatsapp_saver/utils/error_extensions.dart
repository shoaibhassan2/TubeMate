// path: lib/features/whatsapp_saver/utils/error_extensions.dart
import 'dart:io';

extension ErrorTranslation on Object {
  String translateError() {
    if (this is FileSystemException) {
      return 'Cannot access storage. Please check permissions.';
    }

    final String errorStr = toString().toLowerCase();

    if (errorStr.contains('permission') || errorStr.contains('denied')) {
      return 'Storage permission denied. Enable it from settings.';
    }

    if (errorStr.contains('directory') || errorStr.contains('statuses')) {
      return 'Status folder not found. View a status in WhatsApp first.';
    }

    return 'Unexpected error occurred.';
  }
}
