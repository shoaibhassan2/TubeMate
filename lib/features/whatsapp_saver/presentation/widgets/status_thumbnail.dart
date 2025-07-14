import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tubemate/features/whatsapp_saver/data/models/whatsapp_status_model.dart';

class StatusThumbnail extends StatelessWidget {
  final WhatsappStatusModel status;
  const StatusThumbnail({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Widget thumbnail;

    if (status.type == StatusType.image) {
      thumbnail = Image.file(
        status.file,
        fit: BoxFit.cover,
        width: 80,
        height: 80,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
      );
    } else if (status.type == StatusType.video) {
      thumbnail = Stack(
        alignment: Alignment.center,
        children: [
          if (status.thumbnailPath != null)
            Image.file(
              File(status.thumbnailPath!),
              fit: BoxFit.cover,
              width: 80,
              height: 80,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.videocam_off, size: 40, color: Colors.grey),
            )
          else
            const Icon(Icons.videocam, size: 40, color: Colors.grey),
          Icon(Icons.play_circle_fill, color: Colors.white.withOpacity(0.8), size: 30),
        ],
      );
    } else {
      thumbnail = const Icon(Icons.insert_drive_file, size: 40, color: Colors.grey);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: SizedBox(width: 80, height: 80, child: thumbnail),
    );
  }
}
