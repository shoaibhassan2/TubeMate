import 'package:flutter/material.dart';
import 'package:tubemate/features/paksim/data/models/sim_data_model.dart';
import 'package:tubemate/features/paksim/domain/services/pak_sim_service.dart';
import 'package:tubemate/features/paksim/presentation/widgets/paksim_form_widget.dart';

class PakSimScreen extends StatefulWidget {
  const PakSimScreen({super.key});

  @override
  State<PakSimScreen> createState() => _PakSimScreenState();
}

class _PakSimScreenState extends State<PakSimScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleSearch(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a phone number.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<SimDataModel> results = await PakSimService.fetchSimData(phoneNumber);

      if (results.isNotEmpty) {
        _showSimDataDialog(context, results);
      } else {
        setState(() {
          _errorMessage = 'No data found for this number.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSimDataDialog(BuildContext context, List<SimDataModel> simDataList) {
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text(
            'SIM Records (${simDataList.length})',
            style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Scrollbar(
              child: ListView.builder(
                itemCount: simDataList.length,
                itemBuilder: (context, index) {
                  final sim = simDataList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(theme, 'Mobile', sim.mobileNumber, Icons.phone),
                          _buildInfoRow(theme, 'Name', sim.name, Icons.person),
                          _buildInfoRow(theme, 'CNIC', sim.cnic, Icons.credit_card),
                          _buildInfoRow(theme, 'Address', sim.address, Icons.location_on),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Close', style: TextStyle(color: theme.colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.iconTheme.color?.withOpacity(0.7), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: value,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Pak SIM Data', style: theme.textTheme.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PakSimFormWidget(
              onSearchPressed: _handleSearch,
              isLoading: _isLoading,
              errorMessage: _errorMessage,
            ),
          ],
        ),
      ),
    );
  }
}
