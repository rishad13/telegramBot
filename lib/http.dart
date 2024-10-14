import 'dart:convert';

import 'package:http/http.dart' as http;

class GasOracle {
  static final String baseUrl = 'https://api.etherscan.io/api';
  static final String apiKey = 'Y3QKB8YMSCSIX8N882731GG15TMA3EDCDC';

  static Future<Map<String, dynamic>> getGasPrices() async {
    try {
      print('Sending request to fetch gas prices...');
      var request = http.Request(
          'GET',
          Uri.parse(
              '$baseUrl?module=gastracker&action=gasoracle&apikey=$apiKey'));

      http.StreamedResponse response =
          await request.send().timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        String responseData = await response.stream.bytesToString();
        print('Response data received: $responseData');

        final jsonResponse = jsonDecode(responseData);

        if (jsonResponse['result'] != null) {
          final result = jsonResponse['result'];
          String lowGasPrice = result['SafeGasPrice'] ?? '0';
          String averageGasPrice = result['ProposeGasPrice'] ?? '0';
          String highGasPrice = result['FastGasPrice'] ?? '0';
          print(
              'Gas prices - Low: $lowGasPrice, Average: $averageGasPrice, High: $highGasPrice');

          return {
            'low': lowGasPrice,
            'average': averageGasPrice,
            'high': highGasPrice
          };
        } else {
          print('Result not found in response');
          throw Exception('Result not found in response');
        }
      } else {
        print(
            'Failed to load gas prices: ${response.reasonPhrase} (status code: ${response.statusCode})');
        throw Exception(
            'Failed to load gas prices: ${response.reasonPhrase} (status code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error occurred while fetching gas prices: $e');
      throw Exception('Error occurred while fetching gas prices: $e');
    }
  }
}
