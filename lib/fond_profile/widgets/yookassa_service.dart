// lib/services/yookassa_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class YooKassaService {
  static const String _baseUrl = 'http://192.168.0.112:3000';

  Future<String?> createPayment(String amount) async {
    final url = Uri.parse('$_baseUrl/create-payment');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'amount': amount,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['confirmationUrl'];
      } else {
        print('Error creating payment: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  Future<void> createPayout(String amount) async {
    final url = Uri.parse('$_baseUrl/create-payout');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'amount': amount,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Payout created: $responseData');
      } else {
        print('Error creating payout: ${response.statusCode} ${response.body}');
        if (response.statusCode == 403) {
          print('This gateway cannot use this payout type. Contact the YooMoney manager to learn more.');
        }
      }
    } catch (e) {
      print('Exception: $e');
    }
  }
}