import 'package:tubemate/features/home/domain/enums/video_platform.dart'; // Import the enum

// Model to hold the identified link information
class IdentifiedLink {
  final String url;
  final VideoPlatform platform;

  IdentifiedLink(this.url, this.platform);

  // Helper to get a readable name for the platform
  String get platformName {
    switch (platform) {
      case VideoPlatform.youtube: return 'YouTube';
      case VideoPlatform.instagram: return 'Instagram';
      case VideoPlatform.tiktok: return 'TikTok';
      case VideoPlatform.facebook: return 'Facebook';
      case VideoPlatform.other: return 'Other Platform';
      case VideoPlatform.none: return 'None';
    }
  }

  // Optional: For debugging or logging
  @override
  String toString() {
    return 'IdentifiedLink(url: $url, platform: $platformName)';
  }
}