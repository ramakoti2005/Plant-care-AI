import 'dart:ui';
import 'dart:convert';
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
    if (path.startsWith('data:')) {
      return path;
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path; 
    }
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return 'https://plant-care-ai-6ng8.onrender.com/$cleanPath';
  }

  Widget buildDetailImage(String imageUrl, {BoxFit fit = BoxFit.cover, Color progressColor = Colors.green, Color iconColor = Colors.grey}) {
    if (imageUrl.startsWith('data:image')) {
      final base64RawString = imageUrl.split(',')[1];
      return Image.memory(
        base64Decode(base64RawString),
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image, size: 50, color: iconColor)),
      );
    }
    return Image.network(
      imageUrl,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image, size: 50, color: iconColor)),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(child: CircularProgressIndicator(color: progressColor));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String imgPath = scan['image_path'] ?? scan['image'] ?? '';
    final String finalImageUrl = getFullImageUrl(imgPath);
    final bool web = ResponsiveTheme.isWebLayout(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final String plantName = scan['plant_name'] ?? '';
    final String diseaseName = scan['disease_name'] ?? scan['scientific_name'] ?? '';
    final bool isUnrecognized = plantName.toLowerCase() == 'unknown' && 
                                (diseaseName.toLowerCase() == 'no plant detected' || 
                                 diseaseName.toLowerCase() == 'unrecognized image');

    if (isUnrecognized) {
      return ResponsiveScaffold(
        appBar: AppBar(
          title: const Text("Scan Details"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (imgPath.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: buildDetailImage(
                            finalImageUrl,
                            fit: BoxFit.contain,
                            progressColor: isDark ? Colors.white : const Color(0xFF2E7D32),
                            iconColor: isDark ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.red.withOpacity(0.15) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.redAccent.withOpacity(0.3) : const Color(0xFFFFCDD2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, color: isDark ? Colors.redAccent.shade200 : Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          "Unrecognized Image",
                          style: TextStyle(
                            color: isDark ? Colors.redAccent.shade200 : Colors.red,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          scan['solution_suggestion'] ?? "This image is not recognized as a supported plant leaf. Please upload a clear image of a supported plant leaf.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? const Color(0xFFE0E0E0) : Colors.grey.shade800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final Color titleColor = isDark ? Colors.white : const Color(0xFF1B5E20);
    final Color labelColor = isDark ? Colors.white70 : Colors.black54;
    final Color valueColor = isDark ? const Color(0xFFE0E0E0) : Colors.black87;
    final Color dividerColor = isDark ? Colors.white24 : Colors.grey.shade300;

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (imgPath.isNotEmpty)
                              AspectRatio(
                                aspectRatio: 4 / 3,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: buildDetailImage(
                                    finalImageUrl,
                                    fit: BoxFit.contain,
                                    progressColor: Colors.green,
                                    iconColor: Colors.grey,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Text(
                              scan['plant_name'] ?? '',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFA5D6A7) : const Color(0xFF1B5E20),
                              ),
                            ),
                            Divider(height: 30, color: dividerColor),
                            Text(
                              "Scientific Name",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: labelColor,
                              ),
                            ),
                            Text(
                              scan['scientific_name'] ?? '',
                              style: TextStyle(color: valueColor),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "Image Quality",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: labelColor,
                              ),
                            ),
                            Text(
                              scan['image_quality'].toString(),
                              style: TextStyle(color: valueColor),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "Scan Date & Time",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: labelColor,
                              ),
                            ),
                            Text(
                              _formatDate(scan['timestamp'] ?? scan['created_at'] ?? scan['date']),
                              style: TextStyle(color: valueColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right Column
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Analysis & Treatment Details",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
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
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan['plant_name'] ?? '',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      Divider(height: 30, color: dividerColor),
                      if (imgPath.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: dividerColor),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                             child: buildDetailImage(
                               finalImageUrl,
                               fit: BoxFit.cover,
                               progressColor: isDark ? Colors.white : const Color(0xFF2E7D32),
                               iconColor: isDark ? Colors.white70 : Colors.grey,
                             ),
                          ),
                        ),
                      Text(
                        "Scientific Name",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: labelColor,
                        ),
                      ),
                      Text(
                        scan['scientific_name'] ?? '',
                        style: TextStyle(color: valueColor),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Image Quality",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: labelColor,
                        ),
                      ),
                      Text(
                        scan['image_quality'].toString(),
                        style: TextStyle(color: valueColor),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Scan Date & Time",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: labelColor,
                        ),
                      ),
                      Text(
                        _formatDate(scan['timestamp'] ?? scan['created_at'] ?? scan['date']),
                        style: TextStyle(color: valueColor),
                      ),
                      const SizedBox(height: 20),
                      Divider(height: 40, color: dividerColor),
                      Text(
                        "Analysis & Treatment Details",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color resolvedBgColor = isDark ? const Color(0xFF1E3324) : bgColor;
    final Color resolvedColor = isDark ? const Color(0xFFA5D6A7) : iconColor;
    final Color bodyColor = isDark ? const Color(0xFFE0E0E0) : Colors.black87;

    return ResponsiveCard(
      webBgColor: resolvedBgColor,
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: resolvedColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: resolvedColor,
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
              color: bodyColor,
            ),
          ),
        ],
      ),
    );
  }
}