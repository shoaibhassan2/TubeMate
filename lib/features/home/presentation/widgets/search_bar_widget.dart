import 'dart:ui';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  bool _isFocused = false;
  bool _isLoading = false;

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
    _controller.dispose();
    super.dispose();
  }

  void _handleLoadFormats() async {
    setState(() => _isLoading = true);

    final input = _controller.text.trim();
    debugPrint('Fetching formats for: $input');

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // TODO: Replace with real format-fetching logic
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color accentColor = theme.colorScheme.primary;
    final Color textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    final bool isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Rounded input field with blur
        ClipRRect(
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
                          color: accentColor.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Paste link or search...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Solid "Load Formats" button, rounded without blur
        SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLoadFormats,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              elevation: 3,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                if (_isLoading) const SizedBox(width: 12),
                Text(
                  _isLoading ? 'Getting Formats...' : 'Load Formats',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
