import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'history_detail_screen.dart';
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
      String? token =
      await _storage.read(key: 'auth_token');

      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/history'),
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

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '';
    try {
      DateTime dt = DateTime.parse(dateValue.toString());
      return DateFormat('yyyy-MM-dd hh:mm a').format(dt);
    } catch (e) {
      return dateValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan History",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme:
        const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _history.isEmpty
          ? const Center(
        child: Text(
          "No Scan History Found",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistoryDetailScreen(scan: item),
                  ),
                );
              },
              title: Text(
                item['plant_name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Confidence: ${item['confidence']}"),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(item['timestamp'] ?? item['created_at'] ?? item['date']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}