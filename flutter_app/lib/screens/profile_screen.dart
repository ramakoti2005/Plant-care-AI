import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import '../api_config.dart';
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
  bool _isLoading = false;
  String _fullName = 'Harshitha Karumudi'; 
  String _username = 'harshitha_k';
  String _email = 'karmudiharshitha@gmail.com';
  String _phone = '+91 98765 43210';
  String _location = 'Chennai, Tamil Nadu';

  // Real-time Statistics Binders
  int _totalScans = 128;
  int _diseasesDetected = 24;
  String _accuracyRate = '98%';

  String get _gardenerRank => 'Master Botanist 👑';

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
        if (storedUsername != null && storedUsername.isNotEmpty && storedUsername.toLowerCase() != "ramu123" && storedUsername.toLowerCase() != "ramu2005") {
          _username = storedUsername;
          _email = storedEmail ?? _email;
        }
      });
      
      // Fetch dynamic profile details from API
      await _fetchUserProfile();
    } catch (e) {
      debugPrint("Error in _loadUserData: $e");
      await _fetchUserProfile();
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      String? token = authService.token;
      if (token == null || token.isEmpty) {
        const storage = FlutterSecureStorage();
        token = await storage.read(key: 'auth_token');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _fullName = data['full_name'] ?? _fullName;
          _username = data['username'] ?? _username;
          _email = data['email'] ?? _email;
          _phone = data['phone'] ?? _phone;
          _location = data['location'] ?? _location;
          
          _totalScans = data['total_scans'] ?? _totalScans;
          _diseasesDetected = data['diseases_detected'] ?? _diseasesDetected;
          _accuracyRate = "${data['accuracy'] ?? 98}%";
        });
      }
    } catch (e) {
      debugPrint("Error loading profile from API: $e");
    }
  }

  Future<void> _updateUserProfile(String name, String phone, String location) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      String? token = authService.token;
      if (token == null || token.isEmpty) {
        const storage = FlutterSecureStorage();
        token = await storage.read(key: 'auth_token');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'full_name': name,
          'phone': phone,
          'location': location,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _fullName = data['full_name'] ?? name;
          _phone = data['phone'] ?? phone;
          _location = data['location'] ?? location;
          _totalScans = data['total_scans'] ?? _totalScans;
          _diseasesDetected = data['diseases_detected'] ?? _diseasesDetected;
          _accuracyRate = "${data['accuracy'] ?? 98}%";
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update profile details")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error updating profile: $e");
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connection error during update")),
        );
      }
    }
  }

  Future<void> _detectLocation(TextEditingController controller) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location services are disabled on this device")),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Location permissions are denied")),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permissions are permanently denied")),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      final geoResponse = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1'),
        headers: {
          'User-Agent': 'PlantCareAI/1.0',
        },
      );

      if (geoResponse.statusCode == 200) {
        final data = json.decode(geoResponse.body);
        final address = data['address'];
        if (address != null) {
          final String city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'] ?? address['suburb'] ?? "Unknown City";
          final String state = address['state'] ?? address['region'] ?? "";
          final String country = address['country'] ?? "";
          
          final String result = state.isNotEmpty ? "$city, $state" : "$city, $country";
          controller.text = result;
        } else {
          controller.text = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
        }
      } else {
        controller.text = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
      }
    } catch (e) {
      debugPrint("Error detecting location: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error detecting location")),
        );
      }
    }
  }

  void _showEditProfileDialog() {
    final bool web = ResponsiveTheme.isWebLayout(context);
    final nameController = TextEditingController(text: _fullName);
    final phoneController = TextEditingController(text: _phone);
    final locationController = TextEditingController(text: _location);
    bool isDetecting = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: const [
                  Icon(Icons.edit, color: Color(0xFF2E7D32)),
                  SizedBox(width: 8),
                  Text("Edit Profile Details", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: "Phone",
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: "Location",
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: const OutlineInputBorder(),
                        suffixIcon: isDetecting
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2E7D32)),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.gps_fixed, color: Color(0xFF2E7D32)),
                                tooltip: "Detect Location",
                                onPressed: () async {
                                  dialogSetState(() {
                                    isDetecting = true;
                                  });
                                  await _detectLocation(locationController);
                                  dialogSetState(() {
                                    isDetecting = false;
                                  });
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updatedName = nameController.text.trim();
                    final updatedPhone = phoneController.text.trim();
                    final updatedLocation = locationController.text.trim();

                    Navigator.of(context).pop();
                    await _updateUserProfile(updatedName, updatedPhone, updatedLocation);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Update", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color titleColor = isDark ? Colors.white : const Color(0xFF1B5E20);
    final Color badgeBg = isDark ? const Color(0xFF1E3525) : const Color(0xFFE8F5E9);

    if (_isLoading) {
      return ResponsiveScaffold(
        body: Center(child: CircularProgressIndicator(color: ResponsiveTheme.getIconColor(context))),
      );
    }

    Widget profileContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (web) ...[
          Text(
            "My Profile",
            style: TextStyle(
              color: titleColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 1. Header user card
        ResponsiveCard(
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: isDark ? const Color(0xFF1E3525) : Colors.green[50],
                    backgroundImage: _profileImageBytes != null
                        ? MemoryImage(_profileImageBytes!)
                        : null,
                    child: _profileImageBytes == null
                        ? Icon(Icons.person, size: 50, color: isDark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32))
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: isDark ? const Color(0xFF2A3A2E) : Colors.white,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.camera_alt, size: 16, color: isDark ? Colors.white70 : Colors.black54),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fullName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "@$_username",
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 2. Middle Cards (2-Column Grid on Web, Single Column on Mobile)
        if (web)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: _buildProfileDetailsCard(context, _fullName, _email, _phone, _location),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 5,
                child: _buildPlantStatisticsCard(context),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildProfileDetailsCard(context, _fullName, _email, _phone, _location),
              const SizedBox(height: 16),
              _buildPlantStatisticsCard(context),
            ],
          ),

        const SizedBox(height: 40),
      ],
    );

    return ResponsiveScaffold(
      appBar: !web
          ? AppBar(
              title: const Text("My Profile"),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: web
            ? Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: profileContent,
                ),
              )
            : profileContent,
      ),
    );
  }

  // Card builder for Profile Details
  Widget _buildProfileDetailsCard(BuildContext context, String name, String email, String phone, String location) {
    final theme = Theme.of(context);
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, size: 24),
              const SizedBox(width: 8),
              Text(
                "Profile",
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: _showEditProfileDialog,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  side: BorderSide(color: theme.primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Edit", style: TextStyle(color: theme.primaryColor)),
              ),
            ],
          ),
          Divider(height: 24, color: theme.dividerColor),
          _buildProfileDetailRow(context, Icons.person_outline, "Full Name", name),
          Divider(height: 1, color: theme.dividerColor),
          _buildProfileDetailRow(context, Icons.alternate_email, "Username", "@$_username"),
          Divider(height: 1, color: theme.dividerColor),
          _buildProfileDetailRow(context, Icons.mail_outline, "Email", email),
          Divider(height: 1, color: theme.dividerColor),
          _buildProfileDetailRow(context, Icons.phone_outlined, "Phone", phone),
          Divider(height: 1, color: theme.dividerColor),
          _buildProfileDetailRow(context, Icons.location_on_outlined, "Location", location),
        ],
      ),
    );
  }

  Widget _buildProfileDetailRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Card builder for Plant Statistics
  Widget _buildPlantStatisticsCard(BuildContext context) {
    final theme = Theme.of(context);
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, size: 24),
              const SizedBox(width: 8),
              Text(
                "Plant Statistics",
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
              ),
            ],
          ),
          Divider(height: 24, color: theme.dividerColor),
          _buildStatRow(context, Icons.camera_alt_outlined, "Total Scans", _totalScans.toString()),
          Divider(height: 1, color: theme.dividerColor),
          _buildStatRow(context, Icons.bug_report_outlined, "Diseases Detected", _diseasesDetected.toString()),
          Divider(height: 1, color: theme.dividerColor),
          _buildStatRow(context, Icons.track_changes, "Accuracy", _accuracyRate),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
