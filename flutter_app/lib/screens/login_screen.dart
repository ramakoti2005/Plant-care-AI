import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../theme/responsive_theme.dart';
import '../widgets/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('saved_username') ?? '';
      _rememberMe = prefs.getBool('remember_me') ?? false;
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_username', _emailController.text.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_username');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      
      await auth.login(_emailController.text.trim(), _passwordController.text.trim());
      await _saveCredentials();
      TextInput.finishAutofillContext();

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Login failed: ${e.toString().replaceAll('Exception: ', '')}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color labelColor = isDark ? Colors.white70 : Colors.black54;
    final Color iconColor = isDark ? Colors.white70 : Colors.grey;
    final Color borderColor = isDark ? Colors.white30 : Colors.grey;
    final Color textButtonColor = isDark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32);

    return ResponsiveScaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: AutofillGroup(
                  child: ResponsiveCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco, size: 80, color: ResponsiveTheme.getIconColor(context)),
                          const SizedBox(height: 10),
                          Text(
                            "Plant Care AI",
                            style: ResponsiveTheme.getHeaderStyle(context, fontSize: 28),
                          ),
                          Text(
                            "AI Powered Plant Disease Detection",
                            textAlign: TextAlign.center,
                            style: ResponsiveTheme.getSubHeaderStyle(context, fontSize: 14),
                          ),
                          const SizedBox(height: 30),
                          
                          // Username / Email Field
                          TextFormField(
                            controller: _emailController,
                            autofillHints: const [AutofillHints.username, AutofillHints.email],
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              labelText: 'Username or Email',
                              labelStyle: TextStyle(color: labelColor),
                              prefixIcon: Icon(Icons.person, color: iconColor),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: ResponsiveTheme.getIconColor(context)),
                              ),
                            ),
                            validator: (value) => (value == null || value.isEmpty) 
                              ? 'Please enter your username or email' : null,
                          ),
                          const SizedBox(height: 15),
                          
                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            autofillHints: const [AutofillHints.password],
                            obscureText: _obscurePassword,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: labelColor),
                              prefixIcon: Icon(Icons.lock, color: iconColor),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: iconColor),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: ResponsiveTheme.getIconColor(context)),
                              ),
                            ),
                            validator: (value) => (value == null || value.isEmpty) 
                              ? 'Please enter your password' : null,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          
                          // Remember Me Checkbox
                          const SizedBox(height: 10),
                          Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: labelColor,
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  activeColor: ResponsiveTheme.getIconColor(context),
                                  checkColor: Colors.white,
                                  onChanged: (value) => setState(() => _rememberMe = value ?? false),
                                ),
                                Text(
                                  "Remember Me",
                                  style: TextStyle(color: textColor),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _isLoading ? null : _submit,
                              child: const Text(
                                'LOGIN',
                                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed('/register'),
                            child: Text(
                              "Don't have an account? Register",
                              style: TextStyle(
                                color: textButtonColor, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) const LoadingIndicator(),
        ],
      ),
    );
  }
}
