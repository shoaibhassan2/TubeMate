import 'package:flutter/material.dart';
import 'package:tubemate/features/paksim/data/models/sim_data_model.dart';
import 'package:tubemate/features/paksim/domain/services/pak_sim_service.dart';
import 'package:tubemate/features/paksim/presentation/widgets/paksim_form_widget.dart';
import 'package:tubemate/features/paksim/presentation/widgets/sim_data_dialog.dart';

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
      setState(() => _errorMessage = 'Please enter a phone number.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await PakSimService.fetchSimData(phoneNumber);
      if (results.isNotEmpty) {
        showSimDataDialog(context, results);
      } else {
        setState(() => _errorMessage = 'No data found for this number.');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pak SIM Data', style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: PakSimFormWidget(
          onSearchPressed: _handleSearch,
          isLoading: _isLoading,
          errorMessage: _errorMessage,
        ),
      ),
    );
  }
}
