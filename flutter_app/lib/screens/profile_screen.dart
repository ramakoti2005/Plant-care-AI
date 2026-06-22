import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.green[700],
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // Keeps it locked & clean on web!
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
                      backgroundImage: const AssetImage('assets/images/avatar_placeholder.png'), // Or your network image source
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
                Text(
                  "Ramu2005",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[900]),
                ),
                Text(
                  "ramakotireddy2005@gmail.com",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // --- Section: Agro Statistics ---
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

                // --- Section: Account Details ---
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

                // --- Section: Preferences ---
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
                    onPressed: () {
                       Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
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

  // Helper Widget: Section Header
  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700], letterSpacing: 0.5),
      ),
    );
  }

  // Helper Widget: Diagnostic Stat Cards
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

  // Helper Widget: Custom List Tiles
  Widget _buildListTile(IconData icon, String title, String subtitle, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: onTap != null ? const Icon(Icons.chevron_right, size: 20) : null,
      onTap: onTap,
    );
  }
}
