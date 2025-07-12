import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tubemate/features/whatsapp_saver/data/models/whatsapp_status_model.dart';
// import 'package:tubemate/features/whatsapp_saver/presentation/screens/status_viewer_screen.dart'; // <--- REMOVE THIS IMPORT IF DELETING VIEWER SCREEN
import 'package:tubemate/features/whatsapp_saver/domain/services/whatsapp_save_service.dart';
import 'package:open_file_plus/open_file_plus.dart'; // <--- NEW IMPORT

// --- OPTIONAL: If you want a minimal image viewer, keep a simple StatusImageViewerScreen ---
// Otherwise, delete this and just display image directly or also open externally.
class StatusImageViewerScreen extends StatelessWidget {
  final WhatsappStatusModel status;
  const StatusImageViewerScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          status.file.path.split('/').last,
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
      ),
      body: Center(
        child: Image.file(
          status.file,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.broken_image, size: 80, color: Colors.grey),
              SizedBox(height: 10),
              Text('Failed to load image', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
// -------------------------------------------------------------------------------


class StatusItemTile extends StatelessWidget {
  final WhatsappStatusModel status;
  final WhatsappSaveService _saveService = WhatsappSaveService();

  StatusItemTile({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget thumbnailWidget;
    if (status.type == StatusType.image) {
      thumbnailWidget = Image.file(
        status.file,
        fit: BoxFit.cover,
        width: 80,
        height: 80,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 40, color: Colors.grey),
      );
    } else if (status.type == StatusType.video) {
      if (status.thumbnailPath != null) {
        thumbnailWidget = Stack(
          alignment: Alignment.center,
          children: [
            Image.file(
              File(status.thumbnailPath!),
              fit: BoxFit.cover,
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.videocam_off, size: 40, color: Colors.grey),
            ),
            Icon(
              Icons.play_circle_fill,
              color: Colors.white.withOpacity(0.8),
              size: 30,
            ),
          ],
        );
      } else {
        thumbnailWidget = const Icon(Icons.videocam, size: 40, color: Colors.grey);
      }
    } else {
      thumbnailWidget = const Icon(Icons.insert_drive_file, size: 40, color: Colors.grey);
    }

    return Card(
      color: theme.cardColor.withOpacity(0.8),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: SizedBox(
            width: 80,
            height: 80,
            child: thumbnailWidget,
          ),
        ),
        title: Text(
          status.file.path.split('/').last,
          style: theme.textTheme.titleLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          status.type == StatusType.image ? 'Image Status' : 'Video Status',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        trailing: IconButton(
          icon: Icon(Icons.save_alt, color: theme.colorScheme.primary),
          onPressed: () async {
            final bool saved = await _saveService.saveStatus(status);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(saved ? 'Status saved to gallery!' : 'Failed to save status.'),
                backgroundColor: saved ? Colors.green : Colors.red,
              ),
            );
          },
        ),
        onTap: () async { // Make onTap async because openFile.open returns a Future
          if (status.type == StatusType.video) {
            // Open video directly with external app
            final result = await OpenFilePlus.open(status.filePath);
            if (result.type != ResultType.done) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Could not open video: ${result.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else if (status.type == StatusType.image) {
            // Navigate to the simple image viewer for images
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StatusImageViewerScreen(status: status), // Use the simplified image viewer
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
        },
      ),
    );
  }
}