import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'dart:convert';

import 'package:tubemate/features/paksim/data/models/sim_data_model.dart';
import 'package:tubemate/features/paksim/constants/paksim_constants.dart';

class PakSimService {
  static Future<List<SimDataModel>> fetchSimData(String mobileNumber) async {
    final Map<String, String> data = {
      'mobileNumber': mobileNumber,
      'submit': '',
    };

    try {
      final response = await http.post(
        Uri.parse('${PakSimConstants.baseUrl}${PakSimConstants.searchEndpoint}'),
        headers: PakSimConstants.defaultHeaders,
        body: data,
      );

      if (response.statusCode == 200) {
        final document = html_parser.parse(utf8.decode(response.bodyBytes));
        final resultDiv = document.getElementById('result');

        if (resultDiv != null && resultDiv.text.contains('Data Not Found!')) {
          throw Exception('No data found for this cnic or mobile number.');
        }

        final table = resultDiv?.getElementsByTagName('table').first;
        final rows = table?.getElementsByTagName('tr');

        if (rows != null && rows.length > 1) {
          final List<SimDataModel> simDataList = [];

          for (int i = 1; i < rows.length; i++) {
            final cells = rows[i].getElementsByTagName('td');
            if (cells.length >= 4) {
              simDataList.add(
                SimDataModel(
                  mobileNumber: cells[0].text.trim(),
                  name: cells[1].text.trim(),
                  cnic: cells[2].text.trim(),
                  address: cells[3].text.trim(),
                ),
              );
            }
          }

          if (simDataList.isEmpty) {
            throw Exception('No valid rows with complete data were found.');
          }

          return simDataList;
        } else {
          throw Exception('No data rows found in the response.');
        }
      } else {
        throw Exception('Failed to fetch data. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An error occurred while fetching SIM data: $e');
    }
  }
}
