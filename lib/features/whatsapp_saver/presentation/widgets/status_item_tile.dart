import 'package:flutter/material.dart';
import 'package:tubemate/features/whatsapp_saver/data/models/whatsapp_status_model.dart';
import 'package:tubemate/features/whatsapp_saver/presentation/widgets/status_thumbnail.dart';
import 'package:tubemate/features/whatsapp_saver/presentation/widgets/status_type_label.dart';
import 'package:tubemate/features/whatsapp_saver/presentation/widgets/status_actions.dart';
import 'package:tubemate/features/whatsapp_saver/presentation/widgets/status_on_tap_handler.dart';

class StatusItemTile extends StatelessWidget {
  final WhatsappStatusModel status;
  const StatusItemTile({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor.withOpacity(0.8),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: StatusThumbnail(status: status),
        title: Text(
          status.file.path.split('/').last,
          style: theme.textTheme.titleLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: StatusTypeLabel(status: status),
        trailing: StatusSaveButton(status: status),
        onTap: () => handleStatusTap(context, status),
      ),
    );
  }
}
