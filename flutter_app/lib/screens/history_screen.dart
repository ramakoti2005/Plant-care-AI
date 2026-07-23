import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../theme/responsive_theme.dart';
import 'history_detail_screen.dart';
import 'dashboard_screen.dart';
import '../api_config.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _storage = const FlutterSecureStorage();
  List<dynamic> _history = [];
  bool _loading = true;
  final String _baseUrl = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      String? token = await _storage.read(key: 'auth_token');

      final response = await http.get(
        Uri.parse('$_baseUrl/plants/history'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
          throw const FormatException("Server is currently waking up from sleep. Please wait a few moments and refresh.");
        }
        setState(() {
          _history = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
        print(response.body);
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        String msg = e.toString().contains("FormatException") 
            ? "Server is currently waking up. Please wait 1 minute and try again." 
            : "Connection error: $e";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
      print(e);
    }
  }

  Future<void> _deleteScanFromBackend(dynamic scanId) async {
    if (scanId == null) return;
    try {
      String? token = await _storage.read(key: 'auth_token');
      final response = await http.delete(
        Uri.parse('$_baseUrl/plants/history/$scanId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print("Delete Scan response: ${response.statusCode} - ${response.body}");
    } catch (e) {
      print("Error deleting from backend: $e");
    }
  }

  Future<void> _confirmDelete(dynamic item, int index) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text("Delete History", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            "Are you sure you want to permanently delete the scan history of ${item['plant_name'] ?? 'this plant'}?",
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // 1. Remove from local list immediately
      setState(() {
        _history.removeAt(index);
      });
      // 2. Call backend immediately
      await _deleteScanFromBackend(item['id']);
    }
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '';
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
    final uri = Uri.parse(ApiConfig.baseUrl);
    final baseDomain = "${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}";
    return '$baseDomain/$cleanPath';
  }

  Widget buildHistoryThumbnail(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      final base64RawString = imageUrl.split(',')[1];
      return Image.memory(
        base64Decode(base64RawString),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
    if (imageUrl.startsWith('http') || kIsWeb) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        },
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
  }

  Widget _buildHistoryCard(dynamic item, int index) {
    String imgPath = item['image_path'] ?? item['image'] ?? '';
    final String finalImageUrl = getFullImageUrl(imgPath);
    final bool web = ResponsiveTheme.isWebLayout(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color titleColor = isDark ? const Color(0xFFA5D6A7) : const Color(0xFF1B5E20);
    final Color diagnosisColor = isDark ? const Color(0xFFE0E0E0) : Colors.black87;
    final Color dateColor = isDark ? const Color(0xFFB0BEC5) : Colors.black54;

    final String pName = item['plant_name'] ?? '';
    final String dName = item['disease_name'] ?? item['scientific_name'] ?? '';
    final bool isUnrecognizedItem = pName.toLowerCase() == 'unknown' && 
                                    (dName.toLowerCase() == 'no plant detected' || 
                                     dName.toLowerCase() == 'unrecognized image');

    return ResponsiveCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: imgPath.isNotEmpty
                  ? buildHistoryThumbnail(finalImageUrl)
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUnrecognizedItem ? "Unrecognized Scan" : (item['plant_name'] ?? 'Unknown Plant'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isUnrecognizedItem ? Colors.redAccent : titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isUnrecognizedItem
                      ? "No plant leaf detected"
                      : ((item['scientific_name'] != null &&
                              item['scientific_name'].toString() != 'N/A' &&
                              item['scientific_name'].toString() != 'No Plant Detected')
                          ? item['scientific_name'].toString()
                          : (item['disease_name'] ?? 'Healthy')),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isUnrecognizedItem ? (isDark ? Colors.redAccent.shade100 : Colors.red) : diagnosisColor,
                  ),
                ),
                Text(
                  _formatDate(item['timestamp'] ?? item['created_at'] ?? item['date']),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: dateColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          DashboardScreen.navigate(
                            context,
                            'custom',
                            fallbackWidget: HistoryDetailScreen(scan: item),
                            customWidget: HistoryDetailScreen(scan: item),
                          );
                        },
                        child: const Text("View Details", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: web ? Colors.grey.shade300 : Colors.white24),
                        borderRadius: BorderRadius.circular(8),
                        color: web ? Colors.white : Colors.white.withOpacity(0.12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete_outline, color: web ? Colors.redAccent : Colors.redAccent.shade100),
                        onPressed: () => _confirmDelete(item, index),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool web = ResponsiveTheme.isWebLayout(context);
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text(
          "Scan History",
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _history.isEmpty
              ? Center(
                  child: Text(
                    "No Scan History Found",
                    style: TextStyle(
                      fontSize: 18,
                      color: web ? Colors.black54 : Colors.white70,
                    ),
                  ),
                )
              : Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: web ? 1200 : 600),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : 3, 
                        crossAxisSpacing: isMobile ? 16 : 24,
                        mainAxisSpacing: isMobile ? 16 : 24,
                        childAspectRatio: isMobile ? 1.05 : 0.85,
                      ),
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        return _buildHistoryCard(item, index);
                      },
                    ),
                  ),
                ),
    );
  }
}