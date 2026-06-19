import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import '../api_config.dart';

class ScanPlantScreen extends StatefulWidget {
  const ScanPlantScreen({super.key});

  @override
  State<ScanPlantScreen> createState() => _ScanPlantScreenState();
}

class _ScanPlantScreenState extends State<ScanPlantScreen> {
  Uint8List? _imageBytes;
  String? _imageName;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Map<String, dynamic>? _result;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = pickedFile.name;
        });
      }
    } catch (e) {
      debugPrint("Gallery Error: $e");
    }
  }

  Future<void> _pickCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = pickedFile.name;
        });
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  Future<void> _analyzeDisease() async {
    if (_imageBytes == null) return;

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final token = await _storage.read(key: 'auth_token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/v1/analyze'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Determine the content type based on the file extension
      String extension = _imageName != null ? _imageName!.split('.').last.toLowerCase() : 'jpeg';
      MediaType contentType = MediaType('image', extension == 'png' ? 'png' : 'jpeg');

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _imageBytes!,
          filename: _imageName ?? 'image.jpg',
          contentType: contentType,
        ),
      );

      var response = await request.send();
      String body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        setState(() {
          _result = jsonDecode(body);
          if (_result != null && !_result!.containsKey('timestamp')) {
            _result!['timestamp'] = DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now());
          }
        });
      } else {
        String errorMessage = body;
        try {
          final errorData = jsonDecode(body);
          if (errorData is Map && errorData.containsKey('detail')) {
            errorMessage = errorData['detail'];
          }
        } catch (_) {}
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection error: $e")),
        );
      }
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF4),
      appBar: AppBar(
        title: const Text(
          "Scan Plant",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),

              if (_imageBytes != null)
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(
                      _imageBytes!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                const Column(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 120,
                      color: Color(0xFF2E7D32),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Upload Plant Leaf Image",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Choose From Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(15),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Take Photo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(15),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              if (_imageBytes != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _analyzeDisease,
                    icon: const Icon(Icons.analytics),
                    label: const Text("Analyze Disease"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(15),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              if (_loading) const Center(child: CircularProgressIndicator()),

              if (_result != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Plant: ${_result!['plant_name']}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Scientific Name: ${_result!['scientific_name']}"),
                        Text("Confidence: ${_result!['confidence']}"),
                        Text("Image Quality: ${_result!['image_quality']}"),
                        if (_result!.containsKey('timestamp'))
                          Text("Scan Date & Time: ${_result!['timestamp']}"),
                        const SizedBox(height: 10),
                        const Text(
                          "Solution:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(_result!['solution_suggestion'] ?? "No suggestion available"),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
