import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tubemate/features/whatsapp_saver/data/models/whatsapp_status_model.dart';

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
