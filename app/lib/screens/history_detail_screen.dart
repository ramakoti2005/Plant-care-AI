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
      DateTime dt = DateTime.parse(dateValue.toString());
      return DateFormat('yyyy-MM-dd hh:mm a').format(dt);
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
                if (imageUrl != null)
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
                Text(
                  scan['plant_name'] ?? '',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

                const Divider(height: 30),

                Text(
                  "Scientific Name",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(scan['scientific_name'] ?? ''),

                const SizedBox(height: 15),

                Text(
                  "Confidence",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(scan['confidence'].toString()),

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

                const Text(
                  "Treatment Recommendation",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  scan['solution_suggestion'] ?? '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}