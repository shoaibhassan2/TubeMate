import 'package:flutter/material.dart';
import 'package:tubemate/features/home/domain/services/format_loader_service.dart';
import 'package:tubemate/features/home/presentation/widgets/search_bar_widget.dart';
import 'package:tubemate/features/home/presentation/widgets/load_formats_button.dart';

class LinkInputSection extends StatefulWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback navigateToDownloadsTab;

  const LinkInputSection({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.navigateToDownloadsTab,
  });

  @override
  State<LinkInputSection> createState() => _LinkInputSectionState();
}

class _LinkInputSectionState extends State<LinkInputSection> {
  final FormatLoaderService _formatLoader = FormatLoaderService();

  bool _isLoading = false;

  Future<void> _handleLoadFormats() async {
    final url = widget.textController.text.trim();

    if (url.isEmpty) {
      _showSnackBar('Please paste a link to identify.', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    await _formatLoader.loadFormats(
      context: context,
      url: url,
      onDownloadInitiated: widget.navigateToDownloadsTab,
      clearInput: () => widget.textController.clear(),
      showSnackBar: _showSnackBar,
    );

    if (mounted) setState(() => _isLoading = false);
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
    return Column(
      children: [
        SearchBarWidget(
          controller: widget.textController,
          focusNode: widget.focusNode,
        ),
        const SizedBox(height: 15),
        LoadFormatsButton(
          isLoading: _isLoading,
          onPressed: _handleLoadFormats,
        ),
      ],
    );
  }
}
