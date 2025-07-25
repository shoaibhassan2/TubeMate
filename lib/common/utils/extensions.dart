// Path: lib/common/utils/extensions.dart

// This extension was previously in download_progress_tile.dart
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}