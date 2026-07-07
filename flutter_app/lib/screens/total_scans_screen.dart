import 'package:flutter/material.dart';
import '../theme/responsive_theme.dart';

class TotalScansScreen extends StatelessWidget {
  const TotalScansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool web = ResponsiveTheme.isWebLayout(context);

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text(
          "Total Scans",
        ),
      ),
      body: Center(
        child: Container(
          constraints: web ? const BoxConstraints(maxWidth: 800) : null,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildStatCard(
                context,
                Icons.insert_chart,
                "Total Scans",
                "15 Scans Completed",
                const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 15),
              _buildStatCard(
                context,
                Icons.eco,
                "Healthy Plants",
                "8 Healthy Detections",
                Colors.green,
              ),
              const SizedBox(height: 15),
              _buildStatCard(
                context,
                Icons.coronavirus,
                "Diseased Plants",
                "7 Diseases Found",
                Colors.redAccent,
              ),
              const SizedBox(height: 15),
              _buildStatCard(
                context,
                Icons.track_changes,
                "Accuracy Rate",
                "92% AI Confidence",
                Colors.blueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    final bool web = ResponsiveTheme.isWebLayout(context);

    return ResponsiveCard(
      padding: EdgeInsets.zero,
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: web ? Colors.black87 : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: web ? Colors.grey[600] : const Color(0xFFE0E0E0),
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
