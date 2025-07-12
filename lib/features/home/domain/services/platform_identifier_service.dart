import 'package:flutter/foundation.dart'; // For debugPrint

import 'package:tubemate/features/home/domain/enums/video_platform.dart';
import 'package:tubemate/features/home/domain/models/identified_link.dart';

// Service responsible for identifying the platform of a given URL
class PlatformIdentifierService {
  // Regex patterns for different platforms
  static final Map<VideoPlatform, RegExp> _platformRegexes = {
    VideoPlatform.youtube: RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:m\.)?(?:youtube\.com|youtu\.be)\/(?:watch\?v=|embed\/|v\/|shorts\/|)?([\w-]{11})(?:\S+)?',
      caseSensitive: false,
    ),
    VideoPlatform.instagram: RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:instagram\.com)\/(?:p|reels|tv)\/([a-zA-Z0-9_-]+)\/?(?:.+)?',
      caseSensitive: false,
    ),
    VideoPlatform.tiktok: RegExp(
      r'https?:\/\/(?:www\.)?(?:tiktok\.com\/@[\w\._-]+\/video\/\d+|vt\.tiktok\.com\/[\w\d]+)',
      caseSensitive: false,
    ),
    VideoPlatform.facebook: RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:m\.)?(?:facebook\.com|fb\.watch)\/(?:watch\/?\?v=|video\.php\?v=|videos\/|)([\w.-]+)(?:\S+)?',
      caseSensitive: false,
    ),
  };

  /// Identifies the platform from a given URL.
  /// Returns an [IdentifiedLink] object with the URL and detected platform.
  IdentifiedLink identifyPlatform(String url) {
    if (url.trim().isEmpty) {
      debugPrint('PlatformIdentifierService: URL is empty.');
      return IdentifiedLink('', VideoPlatform.none);
    }

    VideoPlatform detectedPlatform = VideoPlatform.other;
    for (var entry in _platformRegexes.entries) {
      if (entry.value.hasMatch(url)) {
        detectedPlatform = entry.key;
        break;
      }
    }

    final identifiedLink = IdentifiedLink(url, detectedPlatform);
    debugPrint('PlatformIdentifierService: Identified: $identifiedLink');
    return identifiedLink;
  }
}