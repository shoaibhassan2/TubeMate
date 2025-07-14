import 'package:flutter/material.dart';

class PakSimInputField extends StatelessWidget {
  final TextEditingController controller;

  const PakSimInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Enter Phone or CNIC Number',
        prefixIcon: Icon(Icons.phone, color: theme.colorScheme.primary),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        filled: true,
        fillColor: Colors.white10,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black26, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
        ),
      ),
    );
  }
}
