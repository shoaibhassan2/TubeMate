import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tubemate/features/whatsapp_saver/data/models/whatsapp_status_model.dart';
import 'package:tubemate/features/whatsapp_saver/domain/services/whatsapp_status_service.dart';
import 'package:tubemate/features/whatsapp_saver/utils/error_extensions.dart';
import 'package:tubemate/features/whatsapp_saver/presentation/widgets/status_error_widget.dart';
import 'package:tubemate/features/whatsapp_saver/presentation/widgets/status_loading_widget.dart';
import 'package:tubemate/features/whatsapp_saver/presentation/widgets/status_empty_widget.dart';
import 'package:tubemate/features/whatsapp_saver/presentation/widgets/status_list_view.dart';

class WhatsappStatusSaverScreen extends StatefulWidget {
  const WhatsappStatusSaverScreen({super.key});

  @override
  State<WhatsappStatusSaverScreen> createState() => _WhatsappStatusSaverScreenState();
}

class _WhatsappStatusSaverScreenState extends State<WhatsappStatusSaverScreen> {
  final WhatsappStatusService _statusService = WhatsappStatusService();
  late Future<List<WhatsappStatusModel>> _statusesFuture;

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    setState(() {
      _statusesFuture = _statusService.getWhatsappStatuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('WhatsApp Status Saver', style: theme.textTheme.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatuses,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStatuses,
        child: FutureBuilder<List<WhatsappStatusModel>>(
          future: _statusesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const StatusLoadingWidget();
            } else if (snapshot.hasError) {
              return StatusErrorWidget(
                message: snapshot.error?.translateError() ?? 'An unknown error occurred.',
                onRetry: _loadStatuses,
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const StatusEmptyWidget();
            } else {
              return StatusListView(statuses: snapshot.data!);
            }
          },
        ),
      ),
    );
  }
}
