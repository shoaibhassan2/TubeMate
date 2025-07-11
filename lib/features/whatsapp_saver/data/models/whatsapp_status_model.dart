import 'dart:io';

// Enum to categorize the type of status media
enum StatusType {
  image,
  video,
  unknown, // For files that are neither image nor video (e.g., .nomedia)
}

// Model class to hold details of a WhatsApp status file
class WhatsappStatusModel {
  final String filePath; // Full path to the status file
  final StatusType type; // Type of media (image, video, unknown)
  final File file; // The actual File object

  // Path to a generated thumbnail image for videos (null for images)
  String? thumbnailPath;

  WhatsappStatusModel({
    required this.filePath,
    required this.type,
    required this.file,
    this.thumbnailPath,
  });

  // Static helper to determine the media type based on file extension
  static StatusType getTypeFromFile(String path) {
    final lowerCasePath = path.toLowerCase();
    if (lowerCasePath.endsWith('.jpg') || lowerCasePath.endsWith('.jpeg') || lowerCasePath.endsWith('.png') || lowerCasePath.endsWith('.webp')) {
      return StatusType.image;
    } else if (lowerCasePath.endsWith('.mp4') || lowerCasePath.endsWith('.gif') || lowerCasePath.endsWith('.mov') || lowerCasePath.endsWith('.3gp')) {
      return StatusType.video;
    }
    return StatusType.unknown;
  }
}