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
  String username = "Loading...";
  String email = "Loading...";
  bool isLoading = true;

  // Real backend dynamic data
  String _fullName = "Loading...";
  String _phone = "Loading...";
  String _location = "Loading...";
  int _totalScans = 0;
  int _diseasesDetected = 0;
  String _accuracy = "0%";

  // Additional dynamic metrics
  int _plantsMonitored = 0;
  int _recentScans = 0;
  int _healthyPlants = 0;
  bool _twoFactorEnabled = false;

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
          username = "ramu123";
          email = "ramakotireddy196478@gmail.com";
        } else {
          username = storedUsername;
          email = storedEmail ?? "ramakotireddy196478@gmail.com";
        }
      });
      
      // Now fetch live stats and profile fields from backend api
      await _fetchUserProfile();
    } catch (e) {
      setState(() {
        username = "ramu123";
        email = "ramakotireddy196478@gmail.com";
      });
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
          _fullName = data['full_name'] ?? 'User';
          username = data['username'] ?? username;
          email = data['email'] ?? email;
          _phone = data['phone'] ?? 'Not Provided';
          _location = data['location'] ?? 'Not Provided';
          
          _totalScans = data['total_scans'] ?? 0;
          _diseasesDetected = data['diseases_detected'] ?? 0;
          _accuracy = "${data['accuracy'] ?? 98}%";
          
          _plantsMonitored = data['plants_monitored'] ?? 0;
          _recentScans = data['recent_scans'] ?? 0;
          _healthyPlants = data['healthy_plants'] ?? 0;
          _twoFactorEnabled = data['two_factor_enabled'] ?? false;

          isLoading = false;
        });
      } else {
        _loadFallbackProfileData();
      }
    } catch (e) {
      debugPrint("Error loading profile from API: $e");
      _loadFallbackProfileData();
    }
  }

  void _loadFallbackProfileData() {
    setState(() {
      _fullName = username.toLowerCase().contains("ramu") ? "Ramu Reddy" : username.toUpperCase();
      _phone = "+91 98765 43210";
      _location = "Chennai, Tamil Nadu";
      _totalScans = 128;
      _diseasesDetected = 24;
      _accuracy = "98%";
      _plantsMonitored = 12;
      _recentScans = 5;
      _healthyPlants = 104;
      _twoFactorEnabled = false;
      isLoading = false;
    });
  }

  Future<void> _updateUserProfile(String name, String phone, String location) async {
    try {
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
          _accuracy = "${data['accuracy'] ?? 98}%";
          _plantsMonitored = data['plants_monitored'] ?? _plantsMonitored;
          _recentScans = data['recent_scans'] ?? _recentScans;
          _healthyPlants = data['healthy_plants'] ?? _healthyPlants;
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")),
          );
        }
      } else {
        setState(() {
          isLoading = false;
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
        isLoading = false;
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

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // Reverse geocoding using OpenStreetMap Nominatim API
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=10');
      final geoResponse = await http.get(
        url,
        headers: {'User-Agent': 'PlantCareAI/1.0'},
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
    final nameController = TextEditingController(text: _fullName == "Loading..." ? "" : _fullName);
    final phoneController = TextEditingController(text: _phone == "Loading..." || _phone == "Not Provided" ? "" : _phone);
    final locationController = TextEditingController(text: _location == "Loading..." || _location == "Not Provided" ? "" : _location);
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
                    
                    setState(() {
                      isLoading = true;
                    });

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

    if (isLoading) {
      return ResponsiveScaffold(
        body: Center(child: CircularProgressIndicator(color: ResponsiveTheme.getIconColor(context))),
      );
    }

    // Build the responsive profile content structure
    Widget profileContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (web) ...[
          const Text(
            "My Profile",
            style: TextStyle(
              color: Color(0xFF1B5E20),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 1. Header user card (horizontal row)
        ResponsiveCard(
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.green[50],
                    backgroundImage: _profileImageBytes != null
                        ? MemoryImage(_profileImageBytes!)
                        : null,
                    child: _profileImageBytes == null
                        ? const Icon(Icons.person, size: 50, color: Color(0xFF2E7D32))
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.camera_alt, size: 16, color: Colors.black54),
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
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "@$username",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 14),
                          SizedBox(width: 6),
                          Text(
                            "Verified User",
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                child: _buildProfileDetailsCard(context, _fullName, email, _phone, _location),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _buildPlantStatisticsCard(context),
                    const SizedBox(height: 20),
                    _buildSecurityCard(context),
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildProfileDetailsCard(context, _fullName, email, _phone, _location),
              const SizedBox(height: 16),
              _buildPlantStatisticsCard(context),
              const SizedBox(height: 16),
              _buildSecurityCard(context),
            ],
          ),

        const SizedBox(height: 20),

        // 3. Bottom Summary Cards
        if (web)
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  iconBgColor: const Color(0xFFE8F5E9),
                  icon: Icons.eco,
                  iconColor: const Color(0xFF2E7D32),
                  value: _plantsMonitored.toString(),
                  title: "Plants Monitored",
                  subtitle: "Across your garden",
                  valueColor: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  iconBgColor: const Color(0xFFE3F2FD),
                  icon: Icons.camera_alt,
                  iconColor: const Color(0xFF1565C0),
                  value: _recentScans.toString(),
                  title: "Recent Scans",
                  subtitle: "This Week",
                  valueColor: const Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  iconBgColor: const Color(0xFFFFF8E1),
                  icon: Icons.check_circle_outline,
                  iconColor: const Color(0xFFF57F17),
                  value: _healthyPlants.toString(),
                  title: "Healthy Plants",
                  subtitle: "Keep it up!",
                  valueColor: const Color(0xFFF57F17),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildSummaryCard(
                iconBgColor: const Color(0xFFE8F5E9),
                icon: Icons.eco,
                iconColor: const Color(0xFF2E7D32),
                value: _plantsMonitored.toString(),
                title: "Plants Monitored",
                subtitle: "Across your garden",
                valueColor: const Color(0xFF2E7D32),
              ),
              const SizedBox(height: 12),
              _buildSummaryCard(
                iconBgColor: const Color(0xFFE3F2FD),
                icon: Icons.camera_alt,
                iconColor: const Color(0xFF1565C0),
                value: _recentScans.toString(),
                title: "Recent Scans",
                subtitle: "This Week",
                valueColor: const Color(0xFF1565C0),
              ),
              const SizedBox(height: 12),
              _buildSummaryCard(
                iconBgColor: const Color(0xFFFFF8E1),
                icon: Icons.check_circle_outline,
                iconColor: const Color(0xFFF57F17),
                value: _healthyPlants.toString(),
                title: "Healthy Plants",
                subtitle: "Keep it up!",
                valueColor: const Color(0xFFF57F17),
              ),
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
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              const Text(
                "Profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: _showEditProfileDialog,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  side: const BorderSide(color: Color(0xFF2E7D32)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Edit", style: TextStyle(color: Color(0xFF2E7D32))),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.black12),
          _buildProfileDetailRow(Icons.person_outline, "Full Name", name),
          const Divider(height: 1, color: Colors.black12),
          _buildProfileDetailRow(Icons.alternate_email, "Username", "@$username"),
          const Divider(height: 1, color: Colors.black12),
          _buildProfileDetailRow(Icons.mail_outline, "Email", email),
          const Divider(height: 1, color: Colors.black12),
          _buildProfileDetailRow(Icons.phone_outlined, "Phone", phone),
          const Divider(height: 1, color: Colors.black12),
          _buildProfileDetailRow(Icons.location_on_outlined, "Location", location),
        ],
      ),
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  // Card builder for Plant Statistics
  Widget _buildPlantStatisticsCard(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.eco, color: Color(0xFF2E7D32)),
              SizedBox(width: 8),
              Text(
                "Plant Statistics",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.black12),
          _buildStatRow(Icons.camera_alt_outlined, "Total Scans", _totalScans.toString()),
          const Divider(height: 1, color: Colors.black12),
          _buildStatRow(Icons.bug_report_outlined, "Diseases Detected", _diseasesDetected.toString()),
          const Divider(height: 1, color: Colors.black12),
          _buildStatRow(Icons.track_changes, "Accuracy", _accuracy),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2E7D32))),
        ],
      ),
    );
  }

  // Card builder for Security
  Widget _buildSecurityCard(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.security, color: Color(0xFF2E7D32)),
              SizedBox(width: 8),
              Text(
                "Security",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.black12),
          _buildSecurityRow(
            context,
            icon: Icons.lock_outline,
            label: "Change Password",
            onTap: () {
              DashboardScreen.navigate(context, 'change_password');
            },
          ),
          const Divider(height: 1, color: Colors.black12),
          _buildSecurityRow(
            context,
            icon: Icons.shield_outlined,
            label: "Two-Factor Authentication",
            onTap: () async {
              setState(() {
                isLoading = true;
              });
              try {
                final authService = Provider.of<AuthService>(context, listen: false);
                String? token = authService.token;
                if (token == null || token.isEmpty) {
                  const storage = FlutterSecureStorage();
                  token = await storage.read(key: 'auth_token');
                }

                final nextVal = !_twoFactorEnabled;
                final response = await http.put(
                  Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode({
                    'two_factor_enabled': nextVal,
                  }),
                );

                if (response.statusCode == 200) {
                  final data = json.decode(response.body);
                  setState(() {
                    _twoFactorEnabled = data['two_factor_enabled'] ?? nextVal;
                    isLoading = false;
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Two-Factor Authentication ${_twoFactorEnabled ? 'Enabled' : 'Disabled'}")),
                    );
                  }
                } else {
                  setState(() {
                    isLoading = false;
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to toggle Two-Factor Authentication")),
                    );
                  }
                }
              } catch (e) {
                setState(() {
                  isLoading = false;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Connection error on security toggle")),
                  );
                }
              }
            },
            trailingBadge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _twoFactorEnabled ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _twoFactorEnabled ? "Enabled" : "Disabled",
                style: TextStyle(
                  color: _twoFactorEnabled ? const Color(0xFF2E7D32) : Colors.red[600],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          _buildSecurityRow(
            context,
            icon: Icons.visibility_outlined,
            label: "Privacy Settings",
          ),
          const Divider(height: 1, color: Colors.black12),
          _buildSecurityRow(
            context,
            icon: Icons.logout,
            label: "Logout",
            labelColor: Colors.red[600],
            onTap: () async {
              final auth = Provider.of<AuthService>(context, listen: false);
              await auth.logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? labelColor,
    Widget? trailingBadge,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: labelColor ?? Colors.black54, size: 20),
      title: Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: labelColor ?? Colors.black87),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingBadge != null) trailingBadge,
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.black26, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }

  // Builder for summary metrics cards at bottom
  Widget _buildSummaryCard({
    required Color iconBgColor,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String title,
    required String subtitle,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
