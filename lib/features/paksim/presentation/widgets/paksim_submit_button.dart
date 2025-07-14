import 'package:flutter/material.dart';

class PakSimSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const PakSimSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
            : const Icon(Icons.search, color: Colors.white),
        label: Text(
          isLoading ? 'Searching...' : 'Get SIM Data',
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
