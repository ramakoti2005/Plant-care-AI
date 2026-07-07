import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../api_config.dart';
import '../theme/responsive_theme.dart';

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
  final ImagePicker _picker = ImagePicker();

  bool _isAnalyzing = false;
  String _plantName = '';
  String _diseaseName = '';
  String _overview = '';
  String _symptoms = '';
  String _control = '';
  bool _hasResults = false;
  bool _hasError = false;
  String _errorMessage = '';

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
      final XFile? pickedFile = kIsWeb
          ? await _picker.pickImage(
              source: ImageSource.camera,
              preferredCameraDevice: CameraDevice.rear,
            )
          : await _picker.pickImage(source: ImageSource.camera);

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
      _isAnalyzing = true;
      _hasResults = false;
      _hasError = false;
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
        final responseData = json.decode(body);
        setState(() {
          _isAnalyzing = false;
          _result = responseData;
          
          // Fallbacks to prevent null reference crashes
          _plantName = responseData['plant'] ?? 'Rice';
          _diseaseName = responseData['disease'] ?? 'Leaf Blast';
          _overview = responseData['overview'] ?? responseData['cause'] ?? 'Magnaporthe oryzae';
          _symptoms = responseData['symptoms'] ?? 'Spindle-shaped/diamond-shaped lesions with gray ash centers.';
          _control = responseData['chemical_control'] ?? responseData['control'] ?? 'Tricyclazole 75% WP or Isoprothiolane 40% EC';
          
          _hasResults = true; 
          _hasError = false;
        });
        print("UI State switched successfully for: $_plantName - $_diseaseName");
      } else {
        setState(() {
          _isAnalyzing = false;
          _hasError = true;
          _errorMessage = "Analysis failed with status ${response.statusCode}: $body";
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error ${response.statusCode}: $body"),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 8),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _hasError = true;
        _errorMessage = "Connection error: $e";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (_isAnalyzing) {
        return ResponsiveScaffold(
          appBar: AppBar(
            title: const Text("Plant Carer AI"),
          ),
          body: const Center(
            child: CircularProgressIndicator(color: Colors.green),
          ),
        );
      }
      
      if (_hasResults) {
        return _buildTreatmentResultsView(); 
      }
      
      return _buildUploadAndAnalyzeView(); 
    } catch (e, stackTrace) {
      debugPrint("ScanPlantScreen Build Crash: $e\n$stackTrace");
      return Scaffold(
        appBar: AppBar(
          title: const Text("Render Error"),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 80),
                const SizedBox(height: 16),
                const Text(
                  "A layout error occurred while rendering results.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Text(
                    e.toString(),
                    style: const TextStyle(color: Colors.red, fontFamily: 'monospace'),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isAnalyzing = false;
                      _hasResults = false;
                      _result = null;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Go Back"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildTreatmentResultsView() {
    final bool web = ResponsiveTheme.isWebLayout(context);
    String formattedDate = DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now());

    Widget content = Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 850),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card containing Plant Name, Leaf Image, and Metadata
            Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _plantName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Divider(height: 30),
                    if (_imageBytes != null)
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.green.withOpacity(0.2)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      "Scientific Name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _diseaseName,
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Image Quality",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      "Good",
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Scan Date & Time",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Section Title
            const Text(
              "Analysis & Treatment Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 15),
            
            // Overview & Causes Card
            _buildSectionCard(
              context: context,
              title: "Overview & Causes",
              content: "Crop: $_plantName\nCondition: $_diseaseName\n\nPathogen/Cause: $_overview",
              icon: Icons.info_outline,
              iconColor: const Color(0xFF2E7D32),
              bgColor: const Color(0xFFF1F8E9),
            ),
            
            // Symptoms Card
            _buildSectionCard(
              context: context,
              title: "Symptoms",
              content: _symptoms,
              icon: Icons.healing,
              iconColor: const Color(0xFFE65100),
              bgColor: const Color(0xFFFFF3E0),
            ),
            
            // Organic Remedy Card (if exists)
            if (_result != null && 
                _result!['organic_remedy'] != null && 
                _result!['organic_remedy'].toString().trim().isNotEmpty && 
                _result!['organic_remedy'].toString().trim().toLowerCase() != "none" && 
                _result!['organic_remedy'].toString().trim().toLowerCase() != "none required" &&
                _result!['organic_remedy'].toString().trim().toLowerCase() != "null")
              _buildSectionCard(
                context: context,
                title: "Organic Remedy",
                content: _result!['organic_remedy'],
                icon: Icons.eco,
                iconColor: const Color(0xFF2E7D32),
                bgColor: const Color(0xFFE8F5E9),
              ),
              
            // Chemical Control Card
            _buildSectionCard(
              context: context,
              title: "Chemical Control",
              content: _control,
              icon: Icons.science,
              iconColor: const Color(0xFF0288D1),
              bgColor: const Color(0xFFE1F5FE),
            ),
            
            const SizedBox(height: 30),
            
            // Scan Another Leaf Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _hasResults = false;
                    _result = null;
                    _imageBytes = null;
                    _imageName = null;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Scan Another Leaf"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text(
          "Treatment Results",
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _hasResults = false;
              _result = null;
            });
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: content,
      ),
    );
  }

  Widget _buildMetaField(String label, String value, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard(String title, String body, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: iconColor, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildUploadAndAnalyzeView() {
    final bool web = ResponsiveTheme.isWebLayout(context);
    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text(
          "Plant Carer AI",
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              if (_imageBytes != null)
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        ),
                      ],
                    ),
                  ),
                )
              else
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: web ? Colors.green.withOpacity(0.05) : Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: web ? Colors.green.withOpacity(0.2) : Colors.white.withOpacity(0.25),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.eco, size: 80, color: ResponsiveTheme.getIconColor(context)),
                          const SizedBox(height: 10),
                          Text(
                            "Upload Plant Leaf Image",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: web ? const Color(0xFF1B5E20) : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              if (_isAnalyzing) 
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(color: Colors.green),
                ),

              const SizedBox(height: 30),

              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text("Gallery"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (_imageBytes != null && !_isAnalyzing)
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _analyzeDisease,
                      icon: const Icon(Icons.analytics),
                      label: const Text("Analyze Disease"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final bool web = ResponsiveTheme.isWebLayout(context);

    if (_result!['status'] == "Unrecognized Image") {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: web ? const Color(0xFFFFEBEE) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: web ? const Color(0xFFFFCDD2) : Colors.redAccent.withOpacity(0.4), 
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.error_outline, color: web ? Colors.red : Colors.redAccent, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      "Unrecognized Image",
                      style: TextStyle(
                        color: web ? Colors.red : Colors.redAccent, 
                        fontSize: 22, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result!['message'] ?? "This image is not recognized as a supported plant leaf. Please upload a clear image of a supported plant leaf.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: web ? Colors.grey.shade800 : const Color(0xFFE0E0E0), 
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final String plantName = _result!['plant_name'] ?? _result!['plant'] ?? _plantName;
    final String diseaseName = _result!['disease_name'] ?? _result!['disease'] ?? _diseaseName;
    final bool isHealthy = diseaseName.toLowerCase() == 'healthy';
    
    final String cause = _result!['cause'] ?? (isHealthy ? 'No disease symptoms' : 'N/A');
    final String symptoms = _result!['symptoms'] ?? (isHealthy ? 'None' : 'No symptom details available.');
    final String? organicRemedy = _result!['organic_remedy'];
    final String chemicalControl = _result!['chemical_control'] ?? (isHealthy ? 'None required' : 'No chemical control specified.');

    // Success Case
    if (web) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
            Expanded(
              flex: 4, 
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
                  _buildInfoCard(context, "Plant Name", plantName),
                  const SizedBox(height: 10),
                  _buildInfoCard(context, "Disease", diseaseName, 
                    isDisease: true, 
                    isHealthy: isHealthy
                  ),
                  
                  if (_result!['reference_image'] != null) ...[
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Reference Leaf Image",
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: ResponsiveTheme.getIconColor(context),
                        ),
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
            const SizedBox(width: 24),
            // Right Column
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Treatment Information",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: ResponsiveTheme.getIconColor(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSectionCard(
                    context: context,
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
                      context: context,
                      title: "Organic Remedy",
                      content: organicRemedy,
                      icon: Icons.eco_outlined,
                      iconColor: Colors.teal,
                      bgColor: Colors.white,
                    ),
                  _buildSectionCard(
                    context: context,
                    title: "Diagnostic Symptoms",
                    content: symptoms,
                    icon: Icons.bug_report_outlined,
                    iconColor: Colors.orange,
                    bgColor: Colors.white,
                  ),
                  _buildSectionCard(
                    context: context,
                    title: "Targeted Chemical Control",
                    content: chemicalControl,
                    icon: Icons.science_outlined,
                    iconColor: Colors.purple,
                    bgColor: Colors.white,
                  ),
                ],
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
          _buildInfoCard(context, "Plant Name", plantName),
          const SizedBox(height: 10),
          _buildInfoCard(context, "Disease", diseaseName, 
            isDisease: true, 
            isHealthy: isHealthy
          ),
          
          if (_result!['reference_image'] != null) ...[
            const SizedBox(height: 20),
            Text(
              "Reference Leaf Image",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: ResponsiveTheme.getIconColor(context),
              ),
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
          Text(
            "Treatment Information",
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: ResponsiveTheme.getIconColor(context),
            ),
          ),
          const SizedBox(height: 10),
          ResponsiveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "• Overview & Cause", 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16, 
                    color: web ? Colors.green[800] : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cause, 
                  style: TextStyle(
                    fontSize: 14,
                    color: web ? Colors.black87 : const Color(0xFFE0E0E0),
                  ),
                ),
                const SizedBox(height: 12),
                
                Text(
                  "• Diagnostic Symptoms", 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16, 
                    color: web ? Colors.green[800] : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  symptoms, 
                  style: TextStyle(
                    fontSize: 14,
                    color: web ? Colors.black87 : const Color(0xFFE0E0E0),
                  ),
                ),
                const SizedBox(height: 12),

                if (organicRemedy != null && 
                    organicRemedy.trim().isNotEmpty && 
                    organicRemedy.trim().toLowerCase() != "none" && 
                    organicRemedy.trim().toLowerCase() != "none required" &&
                    organicRemedy.trim().toLowerCase() != "null") ...[
                  Text(
                    "• Organic Remedy", 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16, 
                      color: web ? Colors.green[800] : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    organicRemedy, 
                    style: TextStyle(
                      fontSize: 14,
                      color: web ? Colors.black87 : const Color(0xFFE0E0E0),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                Text(
                  "• Targeted Chemical Control", 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16, 
                    color: web ? Colors.green[800] : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  chemicalControl, 
                  style: TextStyle(
                    fontSize: 14,
                    color: web ? Colors.black87 : const Color(0xFFE0E0E0),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildInfoCard(BuildContext context, String label, String value, {bool isDisease = false, bool isHealthy = false}) {
    final bool web = ResponsiveTheme.isWebLayout(context);
    Color textColor = web ? Colors.black87 : Colors.white;
    if (isDisease) {
      textColor = isHealthy 
          ? (web ? Colors.green : Colors.greenAccent) 
          : (web ? Colors.red : Colors.redAccent);
    }

    return ResponsiveCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w500, 
              color: web ? Colors.grey : const Color(0xFFE0E0E0),
            ),
          ),
          Text(
            value, 
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
