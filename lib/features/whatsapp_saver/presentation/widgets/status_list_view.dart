import 'package:flutter/material.dart';
import 'package:tubemate/features/whatsapp_saver/data/models/whatsapp_status_model.dart';
import 'package:tubemate/features/whatsapp_saver/presentation/widgets/status_item_tile.dart';

class StatusListView extends StatelessWidget {
  final List<WhatsappStatusModel> statuses;

  const StatusListView({super.key, required this.statuses});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: statuses.length,
      itemBuilder: (context, index) {
        return StatusItemTile(status: statuses[index]);
      },
    );
  }
}
