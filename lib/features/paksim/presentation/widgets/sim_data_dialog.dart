import 'package:flutter/material.dart';
import 'package:tubemate/features/paksim/data/models/sim_data_model.dart';
import 'package:tubemate/features/paksim/data/models/sim_data_model.dart';
import 'package:tubemate/features/paksim/presentation/widgets/sim_info_row.dart';

void showSimDataDialog(BuildContext context, List<SimDataModel> simDataList) {
  final theme = Theme.of(context);

  showDialog<void>(
    context: context,
    builder: (context) {
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
                        SimInfoRow(label: 'Mobile', value: sim.mobileNumber, icon: Icons.phone),
                        SimInfoRow(label: 'Name', value: sim.name, icon: Icons.person),
                        SimInfoRow(label: 'CNIC', value: sim.cnic, icon: Icons.credit_card),
                        SimInfoRow(label: 'Address', value: sim.address, icon: Icons.location_on),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: TextStyle(color: theme.colorScheme.primary)),
          ),
        ],
      );
    },
  );
}
