import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'total_scans_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  static const String _imageKey = 'profile_image_path';

  // Temporary mock data
  String _username = "vishnu123";
  String _email = "vishnu@gmail.com";

  @override
  void initState() {
    super.initState();
    _loadImagePath();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? storedUsername = prefs.getString('username') ?? prefs.getString('saved_username');
      String? storedEmail = prefs.getString('email');
      setState(() {
        if (storedUsername == null || storedUsername == "Ramu2005" || storedUsername.toLowerCase() == "ramu2005") {
          _username = "vishnu123";
          _email = "vishnu@gmail.com";
        } else {
          _username = storedUsername;
          _email = storedEmail ?? "vishnu@gmail.com";
        }
      });
    } catch (e) {
      setState(() {
        _username = "vishnu123";
        _email = "vishnu@gmail.com";
      });
    }
  }

  /// Loads the saved image path from SharedPreferences
  Future<void> _loadImagePath() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? path = prefs.getString(_imageKey);
      if (path != null && path.isNotEmpty) {
        final File imageFile = File(path);
        if (await imageFile.exists()) {
          setState(() {
            _profileImage = imageFile;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading image path: $e");
    }
  }

  /// Saves the image path locally using SharedPreferences
  Future<void> _saveImagePath(String path) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_imageKey, path);
    } catch (e) {
      debugPrint("Error saving image path: $e");
    }
  }

  /// Opens gallery to pick an image and saves its path
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        await _saveImagePath(pickedFile.path);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF4),
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 65,
                backgroundColor: const Color(0xFF2E7D32),
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : null,
                child: _profileImage == null
                    ? const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 10),

            // Change Photo Button
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt, color: Color(0xFF2E7D32)),
              label: const Text(
                "Change Photo",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 5),

            // Username
            Text(
              _username,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: Container(
                constraints: kIsWeb ? const BoxConstraints(maxWidth: 600) : null,
                child: Column(
                  children: [
                    // Email Card
                    Card(
                      elevation: kIsWeb ? 4 : 2,
                      shadowColor: kIsWeb ? Colors.black.withOpacity(0.04) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kIsWeb ? 16 : 12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.email, color: Color(0xFF2E7D32)),
                        title: const Text("Email"),
                        subtitle: Text(_email),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Total Scans Card
                    Card(
                      elevation: kIsWeb ? 4 : 2,
                      shadowColor: kIsWeb ? Colors.black.withOpacity(0.04) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kIsWeb ? 16 : 12),
                      ),
                      child: ListTile(
                        onTap: () {
                          DashboardScreen.navigate(
                            context,
                            'custom',
                            fallbackWidget: const TotalScansScreen(),
                            customWidget: const TotalScansScreen(),
                          );
                        },
                        leading: const Icon(Icons.history, color: Color(0xFF2E7D32)),
                        title: const Text("Total Scans"),
                        subtitle: const Text("View scan count"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Settings Card
                    Card(
                      elevation: kIsWeb ? 4 : 2,
                      shadowColor: kIsWeb ? Colors.black.withOpacity(0.04) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kIsWeb ? 16 : 12),
                      ),
                      child: ListTile(
                        onTap: () {
                          DashboardScreen.navigate(
                            context,
                            'settings',
                            fallbackWidget: const SettingsScreen(),
                          );
                        },
                        leading: const Icon(Icons.settings, color: Color(0xFF2E7D32)),
                        title: const Text("Settings"),
                        subtitle: const Text("Manage preferences"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          "Logout",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kIsWeb ? 16 : 12),
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
