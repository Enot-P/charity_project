import 'dart:convert';
import 'package:http/http.dart' as http;

class TagData {
  static const String apiUrl = 'http://192.168.0.112:3000/get-tags';

  static Future<List<String>> fetchTags() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> tagsJson = json.decode(response.body);
      List<String> tags = tagsJson.map((tag) => tag['name'].toString()).toList();
      return tags;
    } else {
      throw Exception('Failed to load tags');
    }
  }
}