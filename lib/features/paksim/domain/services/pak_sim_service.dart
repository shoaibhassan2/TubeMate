import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'dart:convert';

import 'package:tubemate/features/paksim/data/models/sim_data_model.dart';

class PakSimService {
  static const String _baseUrl = 'https://minahilsimsdata.pro';
  static const String _searchEndpoint = '/search.php';

  static Map<String, String> _getHeaders() {
    return {
      'accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
      'accept-language': 'en-US,en;q=0.9',
      'cache-control': 'max-age=0',
      'content-type': 'application/x-www-form-urlencoded',
      'origin': _baseUrl,
      'referer': '$_baseUrl$_searchEndpoint',
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36',
    };
  }

  /// Fetches multiple SIM data records for a given mobile number.
  /// Returns a list of [SimDataModel].
  static Future<List<SimDataModel>> fetchSimData(String mobileNumber) async {
    final Map<String, String> data = {
      'mobileNumber': mobileNumber,
      'submit': '',
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_searchEndpoint'),
        headers: _getHeaders(),
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

          // Skip header (index 0)
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
