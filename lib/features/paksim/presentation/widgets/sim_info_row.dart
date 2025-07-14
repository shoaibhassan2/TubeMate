import 'package:flutter/material.dart';

class SimInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const SimInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.iconTheme.color?.withOpacity(0.7), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: value,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
