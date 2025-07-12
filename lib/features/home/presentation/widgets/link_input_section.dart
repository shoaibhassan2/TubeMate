import 'package:flutter/material.dart';

import 'package:tubemate/features/home/domain/enums/video_platform.dart';
import 'package:tubemate/features/home/domain/models/identified_link.dart';
import 'package:tubemate/features/home/domain/services/platform_identifier_service.dart';
import 'package:tubemate/features/home/presentation/widgets/search_bar_widget.dart';

class LinkInputSection extends StatefulWidget {
  const LinkInputSection({super.key});

  @override
  State<LinkInputSection> createState() => _LinkInputSectionState();
}

class _LinkInputSectionState extends State<LinkInputSection> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final PlatformIdentifierService _identifierService = PlatformIdentifierService();

  IdentifiedLink? _lastIdentifiedLink; // To store the result of the last identification
  bool _isLoading = false; // <--- NEW: State for loading indicator

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Method to trigger identification and provide feedback
  Future<void> _onLoadFormatsPressed() async { // <--- Made async
    if (_isLoading) return; // Prevent multiple presses while loading

    final String url = _textController.text.trim();

    if (url.isEmpty) {
      _showSnackBar('Please paste a link to identify.', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true; // <--- Set loading to true
    });

    // Simulate network delay for identification (remove in real API integration)
    await Future.delayed(const Duration(seconds: 2)); // <--- Simulate delay

    _lastIdentifiedLink = _identifierService.identifyPlatform(url);

    String message;
    Color color;

    if (_lastIdentifiedLink!.platform == VideoPlatform.none) {
      message = 'Please paste a link to identify.';
      color = Colors.orange;
    } else if (_lastIdentifiedLink!.platform == VideoPlatform.other) {
      message = 'Link identified: ${_lastIdentifiedLink!.platformName}. Not a recognized platform for direct download.';
      color = Colors.orange;
    } else {
      message = 'Link identified: ${_lastIdentifiedLink!.platformName}. Ready to fetch formats!';
      color = Colors.green;
    }
    _showSnackBar(message, color);

    setState(() {
      _isLoading = false; // <--- Set loading to false
    });

    // TODO: Here you would typically pass _lastIdentifiedLink to a new screen or
    // a service that handles fetching formats/download options based on the platform.
    // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => FormatsScreen(link: _lastIdentifiedLink!)));
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
        // The SearchBarWidget (input field with link icon)
        SearchBarWidget(
          controller: _textController,
          focusNode: _focusNode,
        ),
        const SizedBox(height: 15), // Spacing between search bar and button

        // The "Load Formats" button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Match search bar padding
          child: SizedBox(
            width: double.infinity, // Make button full width
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _onLoadFormatsPressed, // <--- Disable when loading
              icon: _isLoading
                  ? SizedBox( // <--- Spinning circle when loading
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.download, color: Colors.white), // Default icon
              label: Text(
                _isLoading ? 'Loading Formats...' : 'Load Formats', // <--- Text changes
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary, // Use accent color for button
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0), // Match search bar's corner radius
                ),
                // Button transparency when disabled (loading)
                // This will make the button slightly transparent when onPressed is null
                // based on the default ElevatedButton style.
                // For more explicit transparency, you might need to use a custom MaterialStateProperty.
              ),
            ),
          ),
        ),
      ],
    );
  }
}