import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api_config.dart';

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _token;
  String? get token => _token;

  // IMPORTANT:
  // 10.0.2.2 points to your computer's localhost from the Android Emulator.
  // If using a REAL DEVICE, replace 10.0.2.2 with your computer's local IP (e.g., 192.168.1.10)
  Future<void> login(String email, String password) async {
    try {
      print("LOGIN URL: ${ApiConfig.baseUrl}/api/v1/auth/token");
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email, // Backend search works for both username and email now
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("TOKEN = ${data['access_token']}");

        _token = data['access_token'];

        await _storage.write(
          key: 'auth_token',
          value: _token,
        );

        notifyListeners();
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // After successful registration, log in automatically
        await login(email, password);
      } else {
        final errorBody = jsonDecode(response.body);
        var detail = errorBody['detail'] ?? 'Registration failed';
        if (detail is List) {
          detail = detail.map((e) => e['msg']).join(', ');
        }

        throw Exception(detail.toString());
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: 'auth_token');
    notifyListeners();
  }

  Future<void> loadTokenFromStorage() async {
    _token = await _storage.read(key: 'auth_token');
    if (_token != null) {
      notifyListeners();
    }
  }
}
