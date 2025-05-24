import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'auth_bridge.dart';

class PeminjamanService {
  static String baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:8000/api'
      : 'http://localhost:8000/api';

  // Get list of borrowed books - matches getPeminjaman controller method
  static Future<List<Map<String, dynamic>>> getBorrowedBooks() async {
    try {
      final token = await AuthBridge.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/peminjaman'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data['status'] == 'success' && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw Exception(data['message'] ?? 'Failed to load borrowed books');
    } catch (e) {
      print('Error fetching borrowed books: $e');
      return [];
    }
  }

  // Borrow a book - matches pinjamBuku controller method
  static Future<Map<String, dynamic>> borrowBook(int bookId) async {
    try {
      final token = await AuthBridge.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/peminjaman'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'buku_id': bookId, // Match the parameter name in your controller
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': data['status'] == 'success',
          'message': data['message'] ?? 'Buku berhasil dipinjam',
          'data': data['data']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal meminjam buku',
        };
      }
    } catch (e) {
      print('Error borrowing book: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Return a borrowed book - matches kembalikanBuku controller method
  static Future<Map<String, dynamic>> returnBook(int borrowId) async {
    try {
      final token = await AuthBridge.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Changed from POST to PUT to match your API route
      final response = await http.put(
        Uri.parse('$baseUrl/peminjaman/$borrowId/return'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': data['status'] == 'success',
          'message': data['message'] ?? 'Buku berhasil dikembalikan',
          'data': data['data']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengembalikan buku',
        };
      }
    } catch (e) {
      print('Error returning book: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
}
