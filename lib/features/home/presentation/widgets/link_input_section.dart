// Path: lib/features/home/presentation/widgets/link_input_section.dart

// Path: lib/features/home/presentation/widgets/link_input_section.dart

import 'package:flutter/material.dart';

import 'package:tubemate/features/home/domain/enums/video_platform.dart';
import 'package:tubemate/features/home/domain/models/identified_link.dart';
import 'package:tubemate/features/home/domain/services/platform_identifier_service.dart';
import 'package:tubemate/features/home/presentation/widgets/search_bar_widget.dart';

import 'package:tubemate/features/downloader/data/datasources/tiktok_api_client.dart';
import 'package:tubemate/features/downloader/domain/services/download_manager_service.dart';
import 'package:tubemate/features/downloader/data/models/tiktok_data_model.dart';

import 'package:tubemate/features/downloader/presentation/widgets/download_options_bottom_sheet.dart'; // <--- Correct path


class LinkInputSection extends StatefulWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback navigateToDownloadsTab; // <--- NEW: Navigation callback

  const LinkInputSection({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.navigateToDownloadsTab, // <--- NEW
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

    if (_lastIdentifiedLink!.platform == VideoPlatform.none) {
      _showSnackBar('Invalid link. Please check and try again.', Colors.red);
      setState(() { _isLoading = false; });
      return;
    } else if (_lastIdentifiedLink!.platform == VideoPlatform.other) {
      _showSnackBar('Unrecognized platform link. Only TikTok, YouTube, Instagram, Facebook are supported.', Colors.orange);
      setState(() { _isLoading = false; });
      return;
    } else if (_lastIdentifiedLink!.platform == VideoPlatform.tiktok) {
      final TikTokDataModel? tiktokData = await _tiktokApiClient.fetchTiktokInfo(url);

      if (mounted) {
        if (tiktokData != null && tiktokData.data != null) {
          // --- NEW: Pass the navigation callback to the bottom sheet ---
          final bool? downloadInitiated = await showModalBottomSheet<bool>( // showModalBottomSheet can return a result
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return DownloadOptionsBottomSheet(
                videoData: tiktokData.data!,
                onDownloadInitiated: widget.navigateToDownloadsTab, // <--- Pass callback
              );
            },
          );
          // ----------------------------------------------------------

          if (downloadInitiated == true) {
            // Optional: clear text field after initiating download
            widget.textController.clear();
          }

        } else {
          _showSnackBar('Failed to get TikTok download info. Please try another link.', Colors.red);
        }
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() {
      _isLoading = false;
    });
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