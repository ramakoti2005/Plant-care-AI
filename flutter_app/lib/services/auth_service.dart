import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _token;
  String? get token => _token;

  Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email, 
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access_token'];

        await _storage.write(key: 'auth_token', value: _token);

        // Store user info for Profile Screen
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        // If your backend returns username, use it. Otherwise, use email prefix.
        await prefs.setString('username', data['username'] ?? email.split('@')[0]);

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
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('email');

    notifyListeners();
  }

  Future<void> loadToken() async {
    _token = await _storage.read(key: 'auth_token');
    if (_token != null) {
      notifyListeners();
    }
  }
}
