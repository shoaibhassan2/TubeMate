import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tubemate/features/downloader/data/models/download_item_model.dart';

class DownloadManagerPersistence {
  static const String _downloadsKey = 'persisted_downloads';

  static Future<List<DownloadItemModel>> loadDownloads() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? downloadsJson = prefs.getStringList(_downloadsKey);
    final List<DownloadItemModel> downloads = [];

    if (downloadsJson != null) {
      for (final jsonString in downloadsJson) {
        try {
          final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
          downloads.add(DownloadItemModel.fromJson(jsonMap));
        } catch (e) {
          debugPrint('Persistence: Error parsing download: $e');
        }
      }
    }

    return downloads;
  }

  static Future<void> saveDownloads(List<DownloadItemModel> downloads) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> downloadsJson = downloads.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_downloadsKey, downloadsJson);
  }
}
