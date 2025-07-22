import 'package:flutter/material.dart';
import 'package:tubemate/features/downloader/domain/enums/download_status.dart';

IconData getStatusIcon(DownloadStatus status) {
  switch (status) {
    case DownloadStatus.pending:
      return Icons.hourglass_empty;
    case DownloadStatus.downloading:
      return Icons.downloading;
    case DownloadStatus.paused:
      return Icons.pause_circle_filled;
    case DownloadStatus.completed:
      return Icons.check_circle;
    case DownloadStatus.failed:
      return Icons.error;
    case DownloadStatus.cancelled:
      return Icons.cancel;
    default:
      return Icons.info_outline;
  }
}

Color getStatusColor(BuildContext context, DownloadStatus status) {
  final theme = Theme.of(context);
  switch (status) {
    case DownloadStatus.completed:
      return Colors.green;
    case DownloadStatus.failed:
      return theme.colorScheme.error;
    case DownloadStatus.downloading:
      return theme.colorScheme.primary;
    case DownloadStatus.pending:
      return Colors.blueGrey;
    case DownloadStatus.paused:
      return Colors.amber;
    case DownloadStatus.cancelled:
      return Colors.grey;
    default:
      return Colors.grey;
  }
}

String? sanitizeError(String? errorMessage) {
  if (errorMessage == null || errorMessage.isEmpty) return null;
  if (errorMessage.startsWith('PlatformException(error, ')) {
    errorMessage = errorMessage.substring('PlatformException(error, '.length);
    if (errorMessage.endsWith(')')) {
      errorMessage = errorMessage.substring(0, errorMessage.length - 1);
    }
  }
  if (errorMessage.contains('Closure: () => String') || errorMessage.contains('Function: ')) {
    return 'An internal error occurred.';
  }
  return errorMessage;
}
