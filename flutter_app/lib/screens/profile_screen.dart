import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/responsive_theme.dart';
import 'dashboard_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "Loading...";
  String email = "Loading...";
  bool isLoading = true;

  Uint8List? _profileImageBytes;
  final ImagePicker _picker = ImagePicker();
  static const String _imageKey = 'profile_image_base64';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadImage();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? storedUsername = prefs.getString('username') ?? prefs.getString('saved_username');
      String? storedEmail = prefs.getString('email');

      setState(() {
        if (storedUsername == null || storedUsername == "Ramu2005" || storedUsername.toLowerCase() == "ramu2005") {
          username = "vishnu123";
          email = "vishnu@gmail.com";
        } else {
          username = storedUsername;
          email = storedEmail ?? "vishnu@gmail.com";
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        username = "vishnu123";
        email = "vishnu@gmail.com";
        isLoading = false;
      });
    }
  }

  Future<void> _loadImage() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? base64Str = prefs.getString(_imageKey);
      if (base64Str != null && base64Str.isNotEmpty) {
        setState(() {
          _profileImageBytes = base64Decode(base64Str);
        });
      }
    } catch (e) {
      debugPrint("Error loading profile image: $e");
    }
  }

  Future<void> _saveImage(Uint8List bytes) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String base64Str = base64Encode(bytes);
      await prefs.setString(_imageKey, base64Str);
    } catch (e) {
      debugPrint("Error saving profile image: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _profileImageBytes = bytes;
        });
        await _saveImage(bytes);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to pick image")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool web = ResponsiveTheme.isWebLayout(context);

    if (isLoading) {
      return ResponsiveScaffold(
        body: Center(child: CircularProgressIndicator(color: ResponsiveTheme.getIconColor(context))),
      );
    }

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: web ? const Color(0xFF2E7D32) : Colors.green.withOpacity(0.25),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.white24,
                    backgroundImage: _profileImageBytes != null
                        ? MemoryImage(_profileImageBytes!)
                        : null,
                    child: _profileImageBytes == null
                        ? const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt, color: Colors.white70),
                    label: const Text(
                      "Change Photo",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Center(
              child: Container(
                constraints: web ? const BoxConstraints(maxWidth: 600) : null,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ResponsiveCard(
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        leading: Icon(Icons.email, color: ResponsiveTheme.getIconColor(context)),
                        title: Text(
                          "Email",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: web ? Colors.black87 : Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          email,
                          style: TextStyle(
                            color: web ? Colors.grey[700] : const Color(0xFFE0E0E0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ResponsiveCard(
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        onTap: () {
                          DashboardScreen.navigate(
                            context,
                            'settings',
                            fallbackWidget: const SettingsScreen(),
                          );
                        },
                        leading: Icon(Icons.settings, color: ResponsiveTheme.getIconColor(context)),
                        title: Text(
                          "Settings",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: web ? Colors.black87 : Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          "Manage preferences",
                          style: TextStyle(
                            color: web ? Colors.grey[700] : const Color(0xFFE0E0E0),
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right, 
                          size: 20, 
                          color: ResponsiveTheme.getIconColor(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final auth = Provider.of<AuthService>(context, listen: false);
                          await auth.logout();
                          if (mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                          }
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
    );
  }
}
