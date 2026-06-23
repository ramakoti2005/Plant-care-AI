import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  // Reads the stored login token credentials out of internal memory
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

  /// Loads the saved image from SharedPreferences
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

  /// Saves the image locally using SharedPreferences
  Future<void> _saveImage(Uint8List bytes) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String base64Str = base64Encode(bytes);
      await prefs.setString(_imageKey, base64Str);
    } catch (e) {
      debugPrint("Error saving profile image: $e");
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
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. A top header container with a dark green background.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // 2. Inside that header, display the profile picture avatar circle
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
                  // with the "Change Photo" button.
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
                  // 3. Below the avatar, display the dynamic username text widget.
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

            // Padding for the elements below the green header block
            Center(
              child: Container(
                constraints: kIsWeb ? const BoxConstraints(maxWidth: 600) : null,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 4. Below the green header block, display the large stacked input/display panels for:
                    // - Email (showing the active user's email icon and text field row).
                    Card(
                      elevation: kIsWeb ? 4 : 2,
                      shadowColor: kIsWeb ? Colors.black.withOpacity(0.04) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kIsWeb ? 16 : 12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.email, color: Color(0xFF2E7D32)),
                        title: const Text("Email"),
                        subtitle: Text(email),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // - Settings (with the chevron icon pointing right to "Manage preferences").
                    Card(
                      elevation: kIsWeb ? 4 : 2,
                      shadowColor: kIsWeb ? Colors.black.withOpacity(0.04) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kIsWeb ? 16 : 12),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                        leading: const Icon(Icons.settings, color: Color(0xFF2E7D32)),
                        title: const Text("Settings"),
                        subtitle: const Text("Manage preferences"),
                        trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF2E7D32)),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // 5. A wide, full-width Red button at the bottom for "Logout".
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
