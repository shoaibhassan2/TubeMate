// Path: lib/features/home/presentation/widgets/link_input_section.dart

import 'package:flutter/material.dart';

import 'package:tubemate/features/home/domain/enums/video_platform.dart';
import 'package:tubemate/features/home/domain/models/identified_link.dart';
import 'package:tubemate/features/home/domain/services/platform_identifier_service.dart';
import 'package:tubemate/features/home/presentation/widgets/search_bar_widget.dart';

import 'package:tubemate/features/downloader/data/datasources/tiktok_api_client.dart';
import 'package:tubemate/features/downloader/domain/services/download_manager_service.dart';
import 'package:tubemate/features/downloader/data/models/tiktok_data_model.dart';

import 'package:tubemate/features/downloader/presentation/widgets/download_options_bottom_sheet.dart'; // <--- NEW IMPORT

class LinkInputSection extends StatefulWidget {
  final TextEditingController textController;
  final FocusNode focusNode;

  const LinkInputSection({
    super.key,
    required this.textController,
    required this.focusNode,
  });

  @override
  State<LinkInputSection> createState() => _LinkInputSectionState();
}

class _LinkInputSectionState extends State<LinkInputSection> {
  final PlatformIdentifierService _identifierService = PlatformIdentifierService();
  final TikTokApiClient _tiktokApiClient = TikTokApiClient();

  IdentifiedLink? _lastIdentifiedLink;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onLoadFormatsPressed() async {
    if (_isLoading) return;

    final String url = widget.textController.text.trim();

    if (url.isEmpty) {
      _showSnackBar('Please paste a link to identify.', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _lastIdentifiedLink = _identifierService.identifyPlatform(url);

    String message;
    Color color;

    if (_lastIdentifiedLink!.platform == VideoPlatform.none) {
      message = 'Please paste a link to identify.';
      color = Colors.orange;
      _showSnackBar(message, color); // Show message immediately
      setState(() { _isLoading = false; }); // Hide loading
      return; // Exit if no link
    } else if (_lastIdentifiedLink!.platform == VideoPlatform.other) {
      message = 'Link identified: ${_lastIdentifiedLink!.platformName}. Not a recognized platform for direct download.';
      color = Colors.orange;
      _showSnackBar(message, color);
      setState(() { _isLoading = false; });
      return; // Exit if not recognized
    } else if (_lastIdentifiedLink!.platform == VideoPlatform.tiktok) {
      message = 'Identified: TikTok. Fetching download info...';
      color = Colors.blue;
      _showSnackBar(message, color);

      final TikTokDataModel? tiktokData = await _tiktokApiClient.fetchTiktokInfo(url);

      if (mounted) { // Check if widget is still mounted after async operation
        if (tiktokData != null && tiktokData.data != null) {
          // --- NEW: Show bottom sheet instead of starting download directly ---
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Allows sheet to take full height if content is large
            builder: (context) {
              return DownloadOptionsBottomSheet(videoData: tiktokData.data!);
            },
          );
          message = 'TikTok info fetched. Select download options.';
          color = Colors.green;
        } else {
          message = 'Failed to get TikTok download info. Please try another link.';
          color = Colors.red;
        }
      }
    } else {
      message = 'Link identified: ${_lastIdentifiedLink!.platformName}. API integration coming soon!';
      color = Colors.yellow;
      // Simulate delay for other platforms
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() {
      _isLoading = false;
    });
    _showSnackBar(message, color);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SearchBarWidget(
          controller: widget.textController,
          focusNode: widget.focusNode,
        ),
        const SizedBox(height: 15),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _onLoadFormatsPressed,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.download, color: Colors.white),
              label: Text(
                _isLoading ? 'Loading Formats...' : 'Load Formats',
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}