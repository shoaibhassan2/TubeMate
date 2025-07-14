import 'package:flutter/material.dart';
import 'package:tubemate/features/paksim/presentation/widgets/paksim_input_field.dart';
import 'package:tubemate/features/paksim/presentation/widgets/paksim_submit_button.dart';
import 'package:tubemate/features/paksim/presentation/widgets/paksim_error_text.dart';

class PakSimFormWidget extends StatefulWidget {
  final Function(String phoneNumber) onSearchPressed;
  final bool isLoading;
  final String? errorMessage;

  const PakSimFormWidget({
    super.key,
    required this.onSearchPressed,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  State<PakSimFormWidget> createState() => _PakSimFormWidgetState();
}

class _PakSimFormWidgetState extends State<PakSimFormWidget> {
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
            'Get SIM Data',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              PakSimInputField(controller: _phoneController),
              const SizedBox(height: 15),
              PakSimSubmitButton(
                isLoading: widget.isLoading,
                onPressed: () => widget.onSearchPressed(_phoneController.text),
              ),
              if (widget.errorMessage != null) ...[
                const SizedBox(height: 15),
                PakSimErrorText(message: widget.errorMessage!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
