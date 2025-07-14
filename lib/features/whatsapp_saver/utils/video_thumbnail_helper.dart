import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class VideoThumbnailHelper {
  static Future<String?> generate(String videoPath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 128,
        maxWidth: 128,
        quality: 75,
      );
      return thumbnailPath;
    } catch (e) {
      debugPrint('VideoThumbnailHelper error: $e');
      return null;
    }
  }
}
