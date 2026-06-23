import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_config.dart';

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

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = scan['image_url'] ?? scan['image_path'] ?? scan['image'];
    final String baseUrl = ApiConfig.baseUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  scan['plant_name'] ?? '',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

                const Divider(height: 30),

                if (imageUrl != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.green.withOpacity(0.5)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        imageUrl.startsWith('http')
                            ? imageUrl
                            : '$baseUrl${imageUrl.startsWith('/') ? '' : '/'}$imageUrl',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],

                Text(
                  "Scientific Name",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(scan['scientific_name'] ?? ''),

                const SizedBox(height: 15),

                Text(
                  "Image Quality",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(scan['image_quality'].toString()),

                const SizedBox(height: 15),

                Text(
                  "Scan Date & Time",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(_formatDate(scan['timestamp'] ?? scan['created_at'] ?? scan['date'])),

                const SizedBox(height: 20),

                const Divider(height: 40),

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
                  title: "Overview & Causes",
                  content: "Crop: ${scan['plant_name'] ?? 'Unknown'}\nCondition: ${scan['scientific_name'] ?? scan['disease_name'] ?? 'Unknown'}\n\nPathogen/Cause: ${scan['cause'] ?? ( (scan['disease_name']?.toString().toLowerCase().contains('healthy') ?? false) ? 'No disease symptoms' : 'N/A' )}",
                  icon: Icons.info_outline,
                  iconColor: const Color(0xFF2E7D32),
                  bgColor: const Color(0xFFF1F8E9),
                ),

                _buildSectionCard(
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
                    title: "Organic Remedy",
                    content: scan['organic_remedy'],
                    icon: Icons.eco,
                    iconColor: const Color(0xFF2E7D32),
                    bgColor: const Color(0xFFE8F5E9),
                  ),

                _buildSectionCard(
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
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: iconColor.withOpacity(0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}