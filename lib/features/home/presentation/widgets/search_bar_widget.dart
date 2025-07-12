import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:tubemate/features/home/domain/enums/video_platform.dart'; // Import enum
import 'package:tubemate/features/home/domain/models/identified_link.dart'; // Import model
import 'package:tubemate/features/home/domain/services/platform_identifier_service.dart'; // Import service

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();
  bool _isFocused = false;
  bool _isButtonPressed = false;

  final PlatformIdentifierService _identifierService = PlatformIdentifierService(); // Instantiate the service
  IdentifiedLink? _lastIdentifiedLink; // To store the result of the last identification

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  // Method to trigger identification and provide feedback
  void _performIdentification() {
    final String url = _textController.text.trim();
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

    // TODO: Here you would typically pass _lastIdentifiedLink to a new screen or
    // a service that handles fetching formats/download options based on the platform.
    // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => FormatsScreen(link: _lastIdentifiedLink!)));
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color accentColor = theme.colorScheme.primary;
    final Color textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    final bool isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 55,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(
              color: _isFocused
                  ? accentColor
                  : (isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black12),
              width: 1.8,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: accentColor.withOpacity(0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Icon(Icons.link, color: accentColor),
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Paste link or search...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _isButtonPressed = true),
                  onTapUp: (_) {
                    setState(() => _isButtonPressed = false);
                    _performIdentification(); // Call the delegated method
                  },
                  onTapCancel: () => setState(() => _isButtonPressed = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isButtonPressed
                          ? accentColor.withOpacity(0.5)
                          : accentColor.withOpacity(0.9),
                    ),
                    child: const Icon(Icons.search,
                        color: Colors.white, size: 22),
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}