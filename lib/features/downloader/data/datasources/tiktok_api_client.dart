// Path: lib/features/downloader/data/datasources/tiktok_api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint

import 'package:tubemate/features/downloader/data/models/tiktok_data_model.dart';

class TikTokApiClient {
  final String _baseUrl = "https://www.tikwm.com/api/"; // Base URL for the API

  // Asynchronous method to fetch TikTok info from the API
  Future<TikTokDataModel?> fetchTiktokInfo(String videoUrl) async {
    if (videoUrl.isEmpty) {
      debugPrint('TikTokApiClient: Provided URL is empty.');
      return null;
    }

    // Construct the full API URL with the video URL and hd parameter
    final Uri apiUrl = Uri.parse("$_baseUrl?url=$videoUrl&hd=1"); // Using &hd=1 for HD quality

    try {
      debugPrint('TikTokApiClient: Fetching TikTok info from: $apiUrl');
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        debugPrint('TikTokApiClient: API call successful, status code 200.');
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        // Check for specific API error codes from the response body
        if (jsonResponse['code'] == 0) { // Assuming code 0 means success
          return TikTokDataModel.fromJson(jsonResponse);
        } else {
          debugPrint('TikTokApiClient: API returned an error code: ${jsonResponse['code']} - ${jsonResponse['msg']}');
          return null; // API returned an error message/code
        }
      } else {
        debugPrint('TikTokApiClient: API call failed with status code: ${response.statusCode}');
        // Handle HTTP error response
        return null;
      }
    } catch (e, stacktrace) {
      debugPrint('TikTokApiClient: Exception during API call: $e');
      debugPrint('TikTokApiClient: Stacktrace: $stacktrace');
      return null; // Handle any network or parsing errors
    }
  }
}