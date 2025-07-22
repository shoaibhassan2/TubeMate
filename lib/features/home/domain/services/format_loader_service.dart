import 'package:flutter/material.dart';
import 'package:tubemate/features/home/domain/enums/video_platform.dart';
import 'package:tubemate/features/home/domain/models/identified_link.dart';
import 'package:tubemate/features/home/domain/services/platform_identifier_service.dart';
import 'package:tubemate/features/downloader/data/datasources/tiktok_api_client.dart';
import 'package:tubemate/features/downloader/data/models/tiktok_data_model.dart';
import 'package:tubemate/features/downloader/presentation/widgets/download_options_bottom_sheet.dart';

class FormatLoaderService {
  final PlatformIdentifierService _identifierService = PlatformIdentifierService();
  final TikTokApiClient _tiktokApiClient = TikTokApiClient();

  Future<void> loadFormats({
    required BuildContext context,
    required String url,
    required VoidCallback onDownloadInitiated,
    required Function(String message, Color color) showSnackBar,
    required VoidCallback clearInput,
  }) async {
    final IdentifiedLink link = _identifierService.identifyPlatform(url);

    if (link.platform == VideoPlatform.none) {
      showSnackBar('Invalid link. Please check and try again.', Colors.red);
      return;
    }

    if (link.platform == VideoPlatform.other) {
      showSnackBar('Unrecognized platform. Only TikTok, YouTube, etc.', Colors.orange);
      return;
    }

    if (link.platform == VideoPlatform.tiktok) {
      final TikTokDataModel? tiktokData = await _tiktokApiClient.fetchTiktokInfo(url);

      if (context.mounted && tiktokData?.data != null) {
        final bool? didDownload = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          builder: (_) => DownloadOptionsBottomSheet(
            videoData: tiktokData!.data!,
            onDownloadInitiated: onDownloadInitiated,
          ),
        );

        if (didDownload == true) clearInput();
      } else {
        showSnackBar('Failed to get TikTok download info. Try another link.', Colors.red);
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
