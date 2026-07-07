import 'dart:convert';
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
      );

      if (response.statusCode == 200) {
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
      print(e);
    }
  }

  Future<void> _deleteScanFromBackend(dynamic scanId) async {
    if (scanId == null) return;
    try {
      String? token = await _storage.read(key: 'auth_token');
      await http.delete(
        Uri.parse('$_baseUrl/plants/history/$scanId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print("Error deleting from backend: $e");
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
    return 'https://plant-care-ai-6ng8.onrender.com/$cleanPath';
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
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(color: Colors.green));
      },
    );
  }

  Widget _buildHistoryCard(dynamic item, int index) {
    String imgPath = item['image_path'] ?? item['image'] ?? '';
    final String finalImageUrl = getFullImageUrl(imgPath);
    final bool web = ResponsiveTheme.isWebLayout(context);

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
                  item['plant_name'] ?? 'Unknown Plant',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: web ? const Color(0xFF2E7D32) : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['scientific_name'] ?? item['disease_name'] ?? 'Healthy',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: web ? Colors.grey[700] : const Color(0xFFE0E0E0),
                  ),
                ),
                Text(
                  _formatDate(item['timestamp'] ?? item['created_at'] ?? item['date']),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: web ? Colors.grey[600] : const Color(0xFFB0BEC5),
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
                        onPressed: () {
                          final deletedItem = item;
                          final originalIndex = index;

                          setState(() {
                            _history.removeAt(originalIndex);
                          });

                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Scan history deleted successfully'),
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'UNDO',
                                textColor: Colors.yellow,
                                onPressed: () {
                                  setState(() {
                                    _history.insert(originalIndex, deletedItem);
                                  });
                                },
                              ),
                            ),
                          ).closed.then((reason) {
                            if (reason != SnackBarClosedReason.action) {
                              _deleteScanFromBackend(deletedItem['id']);
                            }
                          });
                        },
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
              : web
                  ? Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, 
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final item = _history[index];
                            return _buildHistoryCard(item, index);
                          },
                        ),
                      ),
                    )
                  : Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: ListView.builder(
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final item = _history[index];

                            return ResponsiveCard(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              padding: EdgeInsets.zero,
                              onTap: () {
                                DashboardScreen.navigate(
                                  context,
                                  'custom',
                                  fallbackWidget: HistoryDetailScreen(scan: item),
                                  customWidget: HistoryDetailScreen(scan: item),
                                );
                              },
                              child: ListTile(
                                title: Text(
                                  item['plant_name'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatDate(item['timestamp'] ?? item['created_at'] ?? item['date']),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFE0E0E0),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
    );
  }
}