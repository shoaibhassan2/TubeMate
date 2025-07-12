import 'dart:ui';
import 'package:flutter/material.dart';

// This widget is now solely responsible for the visual search bar input.
// Its internal "Download" button logic is removed, as external "Load Formats" will handle it.
class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller; // Controller passed from parent
  final FocusNode focusNode; // FocusNode passed from parent

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() => _isFocused = widget.focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    // Controller and FocusNode are managed by the parent, so don't dispose here.
    super.dispose();
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
                child: Icon(Icons.link, color: accentColor), // <--- RESTORED LINK ICON
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller, // Use controller from parent
                  focusNode: widget.focusNode, // Use focusNode from parent
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
              // The download/search icon logic is removed from here.
              // It will be part of the external "Load Formats" button.
            ],
          ),
        ),
      ),
    );
  }
}