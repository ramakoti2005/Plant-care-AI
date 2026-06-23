import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'screens.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Plant Care AI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      drawer: _buildNavigationDrawer(context),
      body: Center(
        child: Container(
          constraints: kIsWeb ? const BoxConstraints(maxWidth: 1100) : null,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Leaf Logo Header
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF2E7D32),
                  child: Icon(
                    Icons.eco,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Welcome to Plant Care AI",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "AI Powered Plant Disease Detection",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 40),

                // Dashboard Cards Grid/List Selection
                if (kIsWeb)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 3.0,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildDashboardCard(
                        context,
                        icon: Icons.camera_alt,
                        title: "Scan Plant",
                        subtitle: "Upload leaf image for disease detection",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ScanPlantScreen()),
                        ),
                      ),
                      _buildDashboardCard(
                        context,
                        icon: Icons.history,
                        title: "History",
                        subtitle: "View previous diagnoses",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HistoryScreen()),
                        ),
                      ),
                      _buildDashboardCard(
                        context,
                        icon: Icons.medical_services,
                        title: "Treatments",
                        subtitle: "Recommended solutions",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TreatmentsScreen()),
                        ),
                      ),
                      _buildDashboardCard(
                        context,
                        icon: Icons.person,
                        title: "Profile",
                        subtitle: "Manage account settings",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        ),
                      ),
                    ],
                  )
                else ...[
                  _buildDashboardCard(
                    context,
                    icon: Icons.camera_alt,
                    title: "Scan Plant",
                    subtitle: "Upload leaf image for disease detection",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScanPlantScreen()),
                    ),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.history,
                    title: "History",
                    subtitle: "View previous diagnoses",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    ),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.medical_services,
                    title: "Treatments",
                    subtitle: "Recommended solutions",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TreatmentsScreen()),
                    ),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.person,
                    title: "Profile",
                    subtitle: "Manage account settings",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final double radius = kIsWeb ? 16.0 : 20.0;
    return Container(
      margin: kIsWeb ? EdgeInsets.zero : const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: kIsWeb ? Colors.black.withOpacity(0.03) : Colors.black.withOpacity(0.05),
            blurRadius: kIsWeb ? 16 : 10,
            offset: kIsWeb ? const Offset(0, 6) : const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Leading Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF2E7D32),
                    size: 32,
                  ),
                ),
                
                const SizedBox(width: 20),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Trailing Arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1B5E20), // Deep forest green canvas theme color
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.eco, color: Color(0xFF2E7D32), size: 40),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Plant Care AI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Scrollable Drawer Items
          Expanded(
            child: SingleChildScrollView(
              child: Theme(
                // Overrides the ExpansionTile theme to ensure white text/icons
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  unselectedWidgetColor: Colors.white70,
                  colorScheme: const ColorScheme.light(
                    primary: Colors.white,
                  ),
                ),
                child: Column(
                  children: [
                    // Top Level Actions (Always Visible)
                    ListTile(
                      leading: const Icon(Icons.dashboard, color: Colors.white),
                      title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt, color: Colors.white),
                      title: const Text("Scan Plant", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ScanPlantScreen()),
                        );
                      },
                    ),

                    const Divider(color: Colors.white24, height: 1),

                    // Section 1: Treatments
                    ExpansionTile(
                      leading: const Icon(Icons.medical_services, color: Colors.white),
                      title: const Text(
                        "Treatments",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white70,
                      childrenPadding: const EdgeInsets.only(left: 16),
                      children: [
                        _buildSubMenuItem(
                          context,
                          icon: Icons.apple,
                          title: "Apple Diseases",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppleDiseasesScreen())),
                        ),
                        _buildSubMenuItem(
                          context,
                          icon: Icons.grass,
                          title: "Corn Diseases",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CornDiseasesScreen())),
                        ),
                        _buildSubMenuItem(
                          context,
                          icon: Icons.local_florist,
                          title: "Grape Diseases",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GrapeDiseasesScreen())),
                        ),
                        _buildSubMenuItem(
                          context,
                          icon: Icons.eco,
                          title: "Peach Diseases",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PeachDiseasesScreen())),
                        ),
                        _buildSubMenuItem(
                          context,
                          icon: Icons.eco,
                          title: "Potato Diseases",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PotatoDiseasesScreen())),
                        ),
                        _buildSubMenuItem(
                          context,
                          icon: Icons.agriculture,
                          title: "Rice Diseases",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiceDiseasesScreen())),
                        ),
                        _buildSubMenuItem(
                          context,
                          icon: Icons.energy_savings_leaf,
                          title: "Tomato Diseases",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TomatoDiseasesScreen())),
                        ),
                      ],
                    ),

                    const Divider(color: Colors.white24, height: 1),

                    // Section 2: User Space
                    ExpansionTile(
                      leading: const Icon(Icons.person_pin, color: Colors.white),
                      title: const Text(
                        "User Space",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white70,
                      childrenPadding: const EdgeInsets.only(left: 16),
                      children: [
                        _buildSubMenuItem(
                          context,
                          icon: Icons.history,
                          title: "History",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                        ),
                        _buildSubMenuItem(
                          context,
                          icon: Icons.person,
                          title: "Profile",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                        ),
                      ],
                    ),

                    const Divider(color: Colors.white24, height: 1),

                    // Section 3: Utilities & System Context
                    ListTile(
                      leading: const Icon(Icons.settings, color: Colors.white),
                      title: const Text("Settings", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.help_outline, color: Colors.white),
                      title: const Text("Help & Support", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutAppScreen()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white),
                      title: const Text("Log Out", style: TextStyle(color: Colors.white)),
                      onTap: () async {
                        Navigator.pop(context); // Close drawer
                        try {
                          await Provider.of<AuthService>(context, listen: false).logout();
                        } catch (_) {}
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Pinned bottom plant decorative graphic
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_florist,
                  size: 60,
                  color: Colors.green[200],
                ),
                const SizedBox(height: 4),
                Container(
                  width: 30,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.brown[300],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Keep your plants healthy!",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 20),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
    );
  }
}
