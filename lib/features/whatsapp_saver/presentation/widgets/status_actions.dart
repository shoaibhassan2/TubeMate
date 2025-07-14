import 'package:flutter/material.dart';
import 'package:tubemate/features/whatsapp_saver/data/models/whatsapp_status_model.dart';
import 'package:tubemate/features/whatsapp_saver/domain/services/whatsapp_save_service.dart';

class StatusSaveButton extends StatelessWidget {
  final WhatsappStatusModel status;
  const StatusSaveButton({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.save_alt, color: Theme.of(context).colorScheme.primary),
      onPressed: () async {
        final saveService = WhatsappSaveService();
        final success = await saveService.saveStatus(status);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Status saved to gallery!' : 'Failed to save status.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      },
    );
  }
}
