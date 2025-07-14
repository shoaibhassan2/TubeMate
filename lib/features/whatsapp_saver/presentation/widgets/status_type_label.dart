import 'package:flutter/material.dart';
import 'package:tubemate/features/whatsapp_saver/data/models/whatsapp_status_model.dart';

class StatusTypeLabel extends StatelessWidget {
  final WhatsappStatusModel status;
  const StatusTypeLabel({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final label = switch (status.type) {
      StatusType.image => 'Image Status',
      StatusType.video => 'Video Status',
      _ => 'Unknown Status'
    };

    return Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
    );
  }
}
