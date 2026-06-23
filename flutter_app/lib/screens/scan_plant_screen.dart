import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
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
          _result = null; 
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
          _result = null; 
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
        Uri.parse('${ApiConfig.baseUrl}/analyze'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

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
        final data = jsonDecode(body);
        setState(() {
          _result = data;
        });
      } else {
        String errorMessage = "An error occurred";
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
          "Plant Carer AI",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_imageBytes != null && !(kIsWeb && _result != null))
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Image.memory(_imageBytes!, fit: BoxFit.contain),
                            ),
                          ),
                        )
                      else if (_imageBytes == null)
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.withOpacity(0.2), width: 2),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.eco, size: 80, color: Color(0xFF2E7D32)),
                              SizedBox(height: 10),
                              Text(
                                "Upload Plant Leaf Image",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Gallery"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Camera"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (_imageBytes != null && !_loading && _result == null)
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

              if (_loading) 
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(color: Colors.green),
                ),

              if (_result != null) _buildResultView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultView() {
    if (_result!['status'] == "Unrecognized Image") {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Maintain the high-clarity 4:3 image preview panel framework
              if (_imageBytes != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        _imageBytes!, 
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              
              // 2. Your original premium red warning card container box goes right beneath it
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE), // Subtle premium soft red background tint
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      "Unrecognized Image",
                      style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result!['message'] ?? "This image is not recognized as a supported plant leaf. Please upload a clear image of a supported plant leaf.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final String plantName = _result!['plant_name'] ?? 'Unknown';
    final String diseaseName = _result!['disease_name'] ?? 'Unknown';
    final bool isHealthy = diseaseName.toLowerCase() == 'healthy';
    
    final String cause = _result!['cause'] ?? (isHealthy ? 'No disease symptoms' : 'N/A');
    final String symptoms = _result!['symptoms'] ?? (isHealthy ? 'None' : 'No symptom details available.');
    final String? organicRemedy = _result!['organic_remedy'];
    final String chemicalControl = _result!['chemical_control'] ?? (isHealthy ? 'None required' : 'No chemical control specified.');

    // Success Case
    if (kIsWeb) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Keep the image container bounded perfectly
            Expanded(
              flex: 4, // Allocates proportional space to the image column
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _imageBytes != null 
                            ? Image.memory(
                                _imageBytes!,
                                fit: BoxFit.contain,
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, size: 80, color: Colors.grey),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard("Plant Name", plantName),
                    const SizedBox(height: 10),
                    _buildInfoCard("Disease", diseaseName, 
                      isDisease: true, 
                      isHealthy: isHealthy
                    ),
                    
                    if (_result!['reference_image'] != null) ...[
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Reference Leaf Image",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          'https://${Uri.parse(ApiConfig.baseUrl).host}${_result!['reference_image']}',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 180,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Right Column: Let the treatment text scroll independently if long
            Expanded(
              flex: 6, // Gives more room to read the text comfortably
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75, // Keeps it bounded within view heights
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Treatment Information",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                      ),
                      const SizedBox(height: 10),
                      _buildSectionCard(
                        title: "Overview & Cause",
                        content: cause,
                        icon: Icons.info_outline,
                        iconColor: const Color(0xFF2E7D32),
                        bgColor: Colors.white,
                      ),
                      if (organicRemedy != null && 
                          organicRemedy.trim().isNotEmpty && 
                          organicRemedy.trim().toLowerCase() != "none" && 
                          organicRemedy.trim().toLowerCase() != "none required" &&
                          organicRemedy.trim().toLowerCase() != "null")
                        _buildSectionCard(
                          title: "Organic Remedy",
                          content: organicRemedy,
                          icon: Icons.eco_outlined,
                          iconColor: Colors.teal,
                          bgColor: Colors.white,
                        ),
                      _buildSectionCard(
                        title: "Diagnostic Symptoms",
                        content: symptoms,
                        icon: Icons.bug_report_outlined,
                        iconColor: Colors.orange,
                        bgColor: Colors.white,
                      ),
                      _buildSectionCard(
                        title: "Targeted Chemical Control",
                        content: chemicalControl,
                        icon: Icons.science_outlined,
                        iconColor: Colors.purple,
                        bgColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Native Mobile Fallback
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard("Plant Name", plantName),
          const SizedBox(height: 10),
          _buildInfoCard("Disease", diseaseName, 
            isDisease: true, 
            isHealthy: isHealthy
          ),
          
          if (_result!['reference_image'] != null) ...[
            const SizedBox(height: 20),
            const Text(
              "Reference Leaf Image",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                'https://${Uri.parse(ApiConfig.baseUrl).host}${_result!['reference_image']}',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
          const Text(
            "Treatment Information",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("• Overview & Cause", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[800])),
                const SizedBox(height: 4),
                Text(cause, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                
                Text("• Diagnostic Symptoms", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[800])),
                const SizedBox(height: 4),
                Text(symptoms, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),

                if (organicRemedy != null && 
                    organicRemedy.trim().isNotEmpty && 
                    organicRemedy.trim().toLowerCase() != "none" && 
                    organicRemedy.trim().toLowerCase() != "none required" &&
                    organicRemedy.trim().toLowerCase() != "null") ...[
                  Text("• Organic Remedy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[800])),
                  const SizedBox(height: 4),
                  Text(organicRemedy, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 12),
                ],
                
                Text("• Targeted Chemical Control", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[800])),
                const SizedBox(height: 4),
                Text(chemicalControl, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
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
        border: kIsWeb
            ? Border.all(color: Colors.transparent)
            : Border.all(color: iconColor.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: kIsWeb ? Colors.black.withOpacity(0.03) : Colors.black.withOpacity(0.02),
            blurRadius: kIsWeb ? 16 : 8,
            offset: kIsWeb ? const Offset(0, 6) : const Offset(0, 4),
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

  Widget _buildInfoCard(String label, String value, {bool isDisease = false, bool isHealthy = false}) {
    Color textColor = Colors.black87;
    if (isDisease) {
      textColor = isHealthy ? Colors.green : Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kIsWeb ? 16 : 15),
        boxShadow: [
          BoxShadow(
            color: kIsWeb ? Colors.black.withOpacity(0.03) : Colors.black.withOpacity(0.05), 
            blurRadius: kIsWeb ? 16 : 10, 
            offset: kIsWeb ? const Offset(0, 6) : const Offset(0, 4)
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }
}
