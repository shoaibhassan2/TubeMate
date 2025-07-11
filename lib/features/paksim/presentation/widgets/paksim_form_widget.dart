import 'package:flutter/material.dart';

// A widget that contains the input form for Pak SIM data
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
      children: <Widget>[
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
            children: <Widget>[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Enter Phone or Cnic Number',
                  prefixIcon: Icon(Icons.phone, color: theme.colorScheme.primary),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  filled: true,
                  fillColor: Colors.white10,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(color: Colors.black26, width: 1.2), // 🟢 Light black border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.isLoading
                      ? null // Disable button when loading
                      : () => widget.onSearchPressed(_phoneController.text),
                  icon: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.search, color: Colors.white),
                  label: Text(
                    widget.isLoading ? 'Searching...' : 'Get SIM Data',
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
              if (widget.errorMessage != null) ...[
                const SizedBox(height: 15.0),
                Text(
                  widget.errorMessage!,
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}