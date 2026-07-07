import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../api_config.dart';
import '../theme/responsive_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _obscureCurrent = true;
      _obscureNew = true;
      _obscureConfirm = true;
    });
  }

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("New passwords do not match"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        String? token = authService.token;
        if (token == null || token.isEmpty) {
          const storage = FlutterSecureStorage();
          token = await storage.read(key: 'auth_token');
        }

        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/auth/change-password'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'current_password': _currentPasswordController.text.trim(),
            'new_password': _newPasswordController.text.trim(),
          }),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Password changed successfully"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          final errData = json.decode(response.body);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errData['detail'] ?? "Failed to change password"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool web = ResponsiveTheme.isWebLayout(context);

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text(
          "Change Password",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: web ? const BoxConstraints(maxWidth: 550) : null,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: ResponsiveTheme.getIconColor(context),
                ),
                const SizedBox(height: 20),
                ResponsiveCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Current Password
                        TextFormField(
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrent,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            labelText: "Current Password",
                            labelStyle: const TextStyle(color: Colors.black54),
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: ResponsiveTheme.getIconColor(context)),
                            ),
                          ),
                          validator: (value) => (value == null || value.isEmpty) ? "Enter current password" : null,
                        ),
                        const SizedBox(height: 15),

                        // New Password
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: _obscureNew,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            labelText: "New Password",
                            labelStyle: const TextStyle(color: Colors.black54),
                            prefixIcon: const Icon(Icons.vpn_key_outlined, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => _obscureNew = !_obscureNew),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: ResponsiveTheme.getIconColor(context)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Enter new password";
                            if (value.length < 8) return "Password must be at least 8 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            labelText: "Confirm New Password",
                            labelStyle: const TextStyle(color: Colors.black54),
                            prefixIcon: const Icon(Icons.check_circle_outline, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: ResponsiveTheme.getIconColor(context)),
                            ),
                          ),
                          validator: (value) => (value == null || value.isEmpty) ? "Confirm your password" : null,
                        ),
                        const SizedBox(height: 30),

                        // Action Buttons
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isSaving
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "Change Password",
                                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _isSaving ? null : _resetFields,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF2E7D32)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              "Reset Fields",
                              style: TextStyle(
                                fontSize: 16, 
                                color: Color(0xFF2E7D32), 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
