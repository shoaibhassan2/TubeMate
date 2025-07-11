import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'; // Import for openAppSettings
import 'package:tubemate/features/whatsapp_saver/data/models/whatsapp_status_model.dart';
import 'package:tubemate/features/whatsapp_saver/domain/services/whatsapp_status_service.dart';
import 'package:tubemate/features/whatsapp_saver/presentation/widgets/status_item_tile.dart';

class WhatsappStatusSaverScreen extends StatefulWidget {
  const WhatsappStatusSaverScreen({super.key});

  @override
  State<WhatsappStatusSaverScreen> createState() => _WhatsappStatusSaverScreenState();
}

class _WhatsappStatusSaverScreenState extends State<WhatsappStatusSaverScreen> {
  late Future<List<WhatsappStatusModel>> _statusesFuture;
  final WhatsappStatusService _statusService = WhatsappStatusService();

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  void _loadStatuses() {
    setState(() {
      _statusesFuture = _statusService.getWhatsappStatuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('WhatsApp Status Saver', style: theme.textTheme.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.iconTheme.color),
            onPressed: _loadStatuses,
          ),
        ],
      ),
      body: FutureBuilder<List<WhatsappStatusModel>>(
        future: _statusesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error, size: 60),
                    const SizedBox(height: 10),
                    Text(
                      'Error: ${snapshot.error}',
                      style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Direct user to app settings to grant the specific MANAGE_EXTERNAL_STORAGE permission
                        openAppSettings();
                      },
                      icon: const Icon(Icons.settings, color: Colors.white),
                      label: Text('Enable "All files access"', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                     ElevatedButton.icon(
                      onPressed: _loadStatuses,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: Text('Retry', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off, color: theme.iconTheme.color, size: 60),
                  const SizedBox(height: 10),
                  Text(
                    'No WhatsApp statuses found or accessible.',
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Please ensure you have viewed statuses in WhatsApp and granted "All files access" permission for this app.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _loadStatuses,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: Text('Refresh', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final status = snapshot.data![index];
                return StatusItemTile(status: status);
              },
            );
          }
        },
      ),
    );
  }
}