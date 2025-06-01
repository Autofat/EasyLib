import 'dart:convert';
import 'package:easy_lib/config/appConfig.dart';
import 'package:http/http.dart' as http;
import 'package:easy_lib/models/category.dart';
import 'dart:io' show Platform;

class CategoryService {
  static String baseUrl = AppConfig.apiBaseUrl;
  // Platform.isAndroid
  //     ? 'http://10.0.2.2:8000/api'
  //     : 'http://localhost:8000/api';

  static Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}
