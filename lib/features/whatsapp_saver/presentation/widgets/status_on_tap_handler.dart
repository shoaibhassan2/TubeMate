import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:tubemate/features/whatsapp_saver/data/models/whatsapp_status_model.dart';
import 'package:tubemate/features/whatsapp_saver/presentation/screens/status_image_viewer_screen.dart';

Future<void> handleStatusTap(BuildContext context, WhatsappStatusModel status) async {
  if (status.type == StatusType.video) {
    final result = await OpenFile.open(status.filePath);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open video: ${result.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } else if (status.type == StatusType.image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusImageViewerScreen(status: status),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unsupported file type for viewing.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
