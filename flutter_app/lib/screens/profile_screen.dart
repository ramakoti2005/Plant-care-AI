import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "Loading...";
  String email = "Loading...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Reads the stored login token credentials out of internal memory
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        // Checking for 'saved_username' since LoginScreen uses that
        username = prefs.getString('username') ?? prefs.getString('saved_username') ?? "Ramu2005"; 
        email = prefs.getString('email') ?? "ramakotireddy2005@gmail.com";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        username = "Farmer User";
        email = "No email linked";
        isLoading = false;
      });
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
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.green[700],
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // --- Avatar Section ---
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.green[50],
                      child: Icon(Icons.person, size: 60, color: Colors.green[700]),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: CircleAvatar(
                        backgroundColor: Colors.green[700],
                        radius: 18,
                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 🔊 DYNAMIC METRICS LINKED HERE:
                Text(
                  username, 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[900]),
                ),
                Text(
                  email, 
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // --- Crop Diagnostics Overview ---
                _buildSectionHeader("Crop Diagnostics Overview"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildStatCard("Total Scans", "42", Icons.qr_code_scanner, Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard("Diseased Cases", "18", Icons.coronavirus, Colors.amber[700]!)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard("Healthy Crops", "24", Icons.check_circle, Colors.green)),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Account Details ---
                _buildSectionHeader("Account & Field Management"),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      _buildListTile(Icons.person, "Account Tier", "Professional Farmer", null),
                      const Divider(height: 1),
                      _buildListTile(Icons.location_on, "Region / Zone", "Chennai, India", () {}),
                      const Divider(height: 1),
                      _buildListTile(Icons.shield, "Security Settings", "Update password & active sessions", () {}),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- Settings Preferences ---
                _buildSectionHeader("Application Settings"),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      _buildListTile(Icons.g_translate, "App Language", "English (Default)", () {}),
                      const Divider(height: 1),
                      _buildListTile(Icons.notifications, "Alert & Outbreak Notifications", "Enabled", () {}),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // --- Logout Button ---
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
                    label: const Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700], letterSpacing: 0.5)),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500]), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: onTap != null ? const Icon(Icons.chevron_right, size: 20) : null,
      onTap: onTap,
    );
  }
}
