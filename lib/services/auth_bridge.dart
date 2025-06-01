import 'dart:convert';
import 'dart:io' show Platform, HttpClient;
import 'package:easy_lib/config/appConfig.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as connect;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

/// This class provides a bridge to connect with the JavaScript AuthService functionality
/// It provides authentication features by making API calls to the Laravel backend
class AuthBridge {
  static Dio? _dio;

  // API URL Configuration - matching what's in JavaScript service
  static String _baseUrl = AppConfig.apiBaseUrl;
  // Platform.isAndroid
  //     ? 'http://10.0.2.2:8000/api'
  //     : 'http://localhost:8000/api'; // Use your actual server IP if not testing on localhost !!ANDROID: 10.0.2.2
  static const String _loginEndpoint = '/login';
  static const String _registerEndpoint = '/register';
  static const String _logoutEndpoint = '/logout';

  // Headers
  static Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Set auth token in headers
  static void _setAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
    _dio?.options.headers['Authorization'] = 'Bearer $token';
  }

  // Initialize Dio without cookie support
  static Future<Dio> _getDio() async {
    if (_dio == null) {
      _dio = Dio(BaseOptions(
        baseUrl: _baseUrl.split('/api')[0], // Base URL without /api
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: _headers,
      ));

      // Add logging interceptor for debugging
      _dio!.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));

      print('Dio client initialized to connect to: ${_dio!.options.baseUrl}');
    }
    return _dio!;
  }

  // Create a standard HTTP client (for backward compatibility)
  static http.Client _createClient() {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..badCertificateCallback = (cert, host, port) => true; // For dev only

    print('Creating HTTP client to connect to: $_baseUrl');
    return connect.IOClient(client);
  }

  // Login method using Dio without cookie support
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final dio = await _getDio();
      final response = await dio.post(
        '/api$_loginEndpoint',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('Response status code: ${response.statusCode}');

      final responseData = response.data;

      if (response.statusCode == 200) {
        // Save token and user data
        final token = responseData['data']['token'];
        await _saveToken(token);
        await _saveUser(jsonEncode(responseData['data']['user']));
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
          'errors': responseData['errors'],
        };
      }
    } on DioException catch (e) {
      print('Login error: ${e.toString()}');
      final responseData = e.response?.data;
      return {
        'success': false,
        'message': responseData?['message'] ?? 'Network error: ${e.toString()}',
        'errors': responseData?['errors'],
      };
    } catch (e) {
      print('Login error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Register method - compatible with JS AuthService.register()
  static Future<Map<String, dynamic>> register({
    required String name,
    required String gender,
    required String address,
    required String email,
    required String phoneNumber,
    required String dateOfBirth,
    required String password,
    required String passwordConfirmation,
  }) async {
    final client = _createClient();
    try {
      final response = await client
          .post(
            Uri.parse('$_baseUrl$_registerEndpoint'),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'gender': gender,
              'address': address,
              'email': email,
              'phone_number': phoneNumber,
              'date_of_birth': dateOfBirth,
              'password': password,
              'password_confirmation': passwordConfirmation,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Save token and user data
        final token = responseData['data']['token'];
        await _saveToken(token);
        await _saveUser(jsonEncode(responseData['data']['user']));
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      print('Registration error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    } finally {
      client.close();
    }
  }

  // Logout method
  static Future<Map<String, dynamic>> logout() async {
    final client = _createClient();
    try {
      final token = await getToken();
      if (token != null) {
        _setAuthToken(token);
      }

      final response = await client
          .post(
            Uri.parse('$_baseUrl$_logoutEndpoint'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      // Clear stored user data regardless of response
      await _clearUserData();

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'message': 'Logged out successfully',
      };
    } catch (e) {
      print('Logout error: ${e.toString()}');
      // Even if the request fails, clear user data
      await _clearUserData();
      return {
        'success':
            true, // Consider logout successful even if server request fails
        'message': 'Logged out (offline)',
      };
    } finally {
      client.close();
    }
  }

  // Storage methods - matching JS service's local storage functions
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _setAuthToken(token);
  }

  static Future<void> _saveUser(String user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', user);
  }

  static Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    _headers.remove('Authorization');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      return jsonDecode(userStr) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  static Future<Map<String, dynamic>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Ambil token yang tersimpan

    if (token == null) {
      return {
        'success': false,
        'message': 'User not authenticated',
      };
    }

    final response = await http.get(
      Uri.parse(
          '$_baseUrl/user/profile'), // Endpoint API untuk mengambil data pengguna
      headers: {
        'Authorization':
            'Bearer $token', // Kirimkan token di header untuk autentikasi
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return {
        'success': true,
        'message': responseData['message'],
        'data': responseData['data'],
      };
    } else {
      return {
        'success': false,
        'message': 'Failed to fetch user data',
      };
    }
  }
}
