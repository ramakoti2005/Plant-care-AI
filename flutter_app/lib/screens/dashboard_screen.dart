import 'package:flutter/material.dart';
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
        title: const Text(
          'Plant Care AI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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

            // Dashboard Cards
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
            
            const SizedBox(height: 20),
          ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
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
}
