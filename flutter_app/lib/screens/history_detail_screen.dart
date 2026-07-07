import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_config.dart';
import '../theme/responsive_theme.dart';

class HistoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> scan;

  const HistoryDetailScreen({
    super.key,
    required this.scan,
  });

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';
    try {
      String dateStr = dateValue.toString();
      DateTime dt = DateTime.parse(dateStr);
      if (!dt.isUtc && !dateStr.endsWith('Z') && !RegExp(r'[+-]\d\d:?\d\d$').hasMatch(dateStr)) {
        dt = DateTime.utc(
          dt.year,
          dt.month,
          dt.day,
          dt.hour,
          dt.minute,
          dt.second,
          dt.millisecond,
          dt.microsecond,
        );
      }
      return DateFormat('yyyy-MM-dd hh:mm a').format(dt.toLocal());
    } catch (e) {
      return dateValue.toString();
    }
  }

  String getFullImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path; 
    }
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return 'https://plant-care-ai-6ng8.onrender.com/$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    String imgPath = scan['image_path'] ?? scan['image'] ?? '';
    final String finalImageUrl = getFullImageUrl(imgPath);
    final bool web = ResponsiveTheme.isWebLayout(context);

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text(
          "Scan Details",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            constraints: web ? const BoxConstraints(maxWidth: 1100) : null,
            child: web
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        flex: 4,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (imgPath.isNotEmpty)
                                AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      finalImageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator(color: Colors.green));
                                      },
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Text(
                                scan['plant_name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const Divider(height: 30),
                              const Text(
                                "Scientific Name",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(scan['scientific_name'] ?? ''),
                              const SizedBox(height: 15),
                              const Text(
                                "Image Quality",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(scan['image_quality'].toString()),
                              const SizedBox(height: 15),
                              const Text(
                                "Scan Date & Time",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(_formatDate(scan['timestamp'] ?? scan['created_at'] ?? scan['date'])),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right Column
                      Expanded(
                        flex: 6,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Analysis & Treatment Details",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B5E20),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                _buildSectionCard(
                                  context: context,
                                  title: "Overview & Causes",
                                  content: "Crop: ${scan['plant_name'] ?? 'Unknown'}\nCondition: ${scan['scientific_name'] ?? scan['disease_name'] ?? 'Unknown'}\n\nPathogen/Cause: ${scan['cause'] ?? ( (scan['disease_name']?.toString().toLowerCase().contains('healthy') ?? false) ? 'No disease symptoms' : 'N/A' )}",
                                  icon: Icons.info_outline,
                                  iconColor: const Color(0xFF2E7D32),
                                  bgColor: const Color(0xFFF1F8E9),
                                ),
                                _buildSectionCard(
                                  context: context,
                                  title: "Symptoms",
                                  content: scan['symptoms'] ?? ( (scan['disease_name']?.toString().toLowerCase().contains('healthy') ?? false) ? 'None' : 'No symptom details available.' ),
                                  icon: Icons.healing,
                                  iconColor: const Color(0xFFE65100),
                                  bgColor: const Color(0xFFFFF3E0),
                                ),
                                if (scan['organic_remedy'] != null && 
                                    scan['organic_remedy'].toString().trim().isNotEmpty && 
                                    scan['organic_remedy'].toString().trim().toLowerCase() != "none" && 
                                    scan['organic_remedy'].toString().trim().toLowerCase() != "none required" &&
                                    scan['organic_remedy'].toString().trim().toLowerCase() != "null")
                                  _buildSectionCard(
                                    context: context,
                                    title: "Organic Remedy",
                                    content: scan['organic_remedy'],
                                    icon: Icons.eco,
                                    iconColor: const Color(0xFF2E7D32),
                                    bgColor: const Color(0xFFE8F5E9),
                                  ),
                                _buildSectionCard(
                                  context: context,
                                  title: "Chemical Control",
                                  content: scan['chemical_control'] ?? ( (scan['disease_name']?.toString().toLowerCase().contains('healthy') ?? false) ? 'None required' : 'No chemical control specified.' ),
                                  icon: Icons.science,
                                  iconColor: const Color(0xFF0288D1),
                                  bgColor: const Color(0xFFE1F5FE),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan['plant_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Divider(height: 30, color: Colors.white24),
                      if (imgPath.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white.withOpacity(0.25)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              finalImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.white70));
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator(color: Colors.white));
                              },
                            ),
                          ),
                        ),
                      const Text(
                        "Scientific Name",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        scan['scientific_name'] ?? '',
                        style: const TextStyle(color: Color(0xFFE0E0E0)),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Image Quality",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        scan['image_quality'].toString(),
                        style: const TextStyle(color: Color(0xFFE0E0E0)),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Scan Date & Time",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _formatDate(scan['timestamp'] ?? scan['created_at'] ?? scan['date']),
                        style: const TextStyle(color: Color(0xFFE0E0E0)),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 40, color: Colors.white24),
                      const Text(
                        "Analysis & Treatment Details",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildSectionCard(
                        context: context,
                        title: "Overview & Causes",
                        content: "Crop: ${scan['plant_name'] ?? 'Unknown'}\nCondition: ${scan['scientific_name'] ?? scan['disease_name'] ?? 'Unknown'}\n\nPathogen/Cause: ${scan['cause'] ?? ( (scan['disease_name']?.toString().toLowerCase().contains('healthy') ?? false) ? 'No disease symptoms' : 'N/A' )}",
                        icon: Icons.info_outline,
                        iconColor: const Color(0xFF2E7D32),
                        bgColor: const Color(0xFFF1F8E9),
                      ),
                      _buildSectionCard(
                        context: context,
                        title: "Symptoms",
                        content: scan['symptoms'] ?? ( (scan['disease_name']?.toString().toLowerCase().contains('healthy') ?? false) ? 'None' : 'No symptom details available.' ),
                        icon: Icons.healing,
                        iconColor: const Color(0xFFE65100),
                        bgColor: const Color(0xFFFFF3E0),
                      ),
                      if (scan['organic_remedy'] != null && 
                          scan['organic_remedy'].toString().trim().isNotEmpty && 
                          scan['organic_remedy'].toString().trim().toLowerCase() != "none" && 
                          scan['organic_remedy'].toString().trim().toLowerCase() != "none required" &&
                          scan['organic_remedy'].toString().trim().toLowerCase() != "null")
                        _buildSectionCard(
                          context: context,
                          title: "Organic Remedy",
                          content: scan['organic_remedy'],
                          icon: Icons.eco,
                          iconColor: const Color(0xFF2E7D32),
                          bgColor: const Color(0xFFE8F5E9),
                        ),
                      _buildSectionCard(
                        context: context,
                        title: "Chemical Control",
                        content: scan['chemical_control'] ?? ( (scan['disease_name']?.toString().toLowerCase().contains('healthy') ?? false) ? 'None required' : 'No chemical control specified.' ),
                        icon: Icons.science,
                        iconColor: const Color(0xFF0288D1),
                        bgColor: const Color(0xFFE1F5FE),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    final bool web = ResponsiveTheme.isWebLayout(context);
    return ResponsiveCard(
      webBgColor: bgColor,
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: web ? iconColor : Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: web ? iconColor.withOpacity(0.85) : Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: web ? Colors.black87 : const Color(0xFFE0E0E0),
            ),
          ),
        ],
      ),
    );
  }
}