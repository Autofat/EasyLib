import 'dart:convert';
import 'package:easy_lib/config/appConfig.dart';
import 'package:easy_lib/models/category.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:easy_lib/models/book.dart';

class BookService {
  static String baseUrl = AppConfig.apiBaseUrl;
  // Platform.isAndroid
  //     ? 'http://10.0.2.2:8000/api'
  //     : 'http://localhost:8000/api';

  // Get all books with optional search and category filters
  static Future<List<Book>> getBooks(
      {String? search, int? categoryId, String? categoryName}) async {
    try {
      String url = '$baseUrl/books';

      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }

      if (queryParams.isNotEmpty) {
        url += '?' + Uri(queryParameters: queryParams).query;
      }

      print('Fetching books from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<dynamic> data;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          data = responseData['data'];
        } else {
          throw Exception('Unexpected API response format');
        }

        return data.map((json) => Book.fromJson(json)).toList();
      } else {
        print('API error: ${response.statusCode}, ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error in getBooks: $e');
      return [];
    }
  }

  // Get book details by ID
  static Future<Map<String, dynamic>> getBookDetail(int id) async {
    try {
      print('Fetching book details for ID: $id');

      final response = await http.get(
        Uri.parse('$baseUrl/books/$id'),
        headers: {
          'Accept': 'application/json',
        },
      );

      print('Book detail response status: ${response.statusCode}');

      // Handle 404 Not Found specifically
      if (response.statusCode == 404) {
        print('Book with ID $id not found');
        return {
          'success': false,
          'error': 'not_found',
          'message': 'Buku tidak ditemukan'
        };
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Extract book data based on API structure
        Map<String, dynamic> bookData;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          if (responseData['data'] == null) {
            return {
              'success': false,
              'error': 'not_found',
              'message': 'Buku tidak ditemukan'
            };
          }
          bookData = responseData['data'];
        } else if (responseData is Map<String, dynamic>) {
          bookData = responseData;
        } else {
          return {
            'success': false,
            'error': 'unexpected_format',
            'message': 'Format data tidak sesuai'
          };
        }

        final book = Book.fromJson(bookData);
        return {'success': true, 'data': book};
      } else {
        return {
          'success': false,
          'error': 'api_error',
          'message': 'Error API: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error in getBookDetail: $e');
      return {'success': false, 'error': 'exception', 'message': 'Error: $e'};
    }
  }

  // Get random recommendations (limited number of books)
  static Future<List<Book>> getRandomRecommendations({int limit = 5}) async {
    try {
      final books = await getBooks();

      if (books.isEmpty) {
        return []; // Return empty list instead of dummy data
      }

      // Shuffle the books to get random recommendations
      books.shuffle();

      // Return up to the requested limit
      return books.length <= limit ? books : books.sublist(0, limit);
    } catch (e) {
      print('Error in getRandomRecommendations: $e');
      return []; // Return empty list instead of dummy data
    }
  }
}
