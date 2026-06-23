import 'package:flutter/material.dart';

class TotalScansScreen extends StatelessWidget {
  const TotalScansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text(
          "Total Scans",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildStatCard(
            Icons.insert_chart,
            "Total Scans",
            "15 Scans Completed",
            const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 15),
          _buildStatCard(
            Icons.eco,
            "Healthy Plants",
            "8 Healthy Detections",
            Colors.green,
          ),
          const SizedBox(height: 15),
          _buildStatCard(
            Icons.coronavirus,
            "Diseased Plants",
            "7 Diseases Found",
            Colors.redAccent,
          ),
          const SizedBox(height: 15),
          _buildStatCard(
            Icons.track_changes,
            "Accuracy Rate",
            "92% AI Confidence",
            Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            Column(
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
          ],
        ),
      ),
    );
  }
}
