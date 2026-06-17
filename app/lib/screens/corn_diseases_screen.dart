import 'package:flutter/material.dart';

class CornDiseasesScreen extends StatelessWidget {
  const CornDiseasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Corn Diseases"),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            diseaseCard(
              title: "Common Rust",
              scientificName: "Puccinia sorghi",
              symptoms: [
                "Small reddish-brown pustules on leaves",
                "Yellow halos around lesions",
                "Reduced photosynthesis",
                "Premature leaf drying",
              ],
              causes: [
                "Fungal infection",
                "High humidity",
                "Moderate temperatures",
              ],
              treatment: [
                "Apply fungicides containing Azoxystrobin",
                "Remove infected leaves",
                "Improve field sanitation",
              ],
              prevention: [
                "Plant resistant varieties",
                "Maintain proper spacing",
                "Monitor crops regularly",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Gray Leaf Spot",
              scientificName: "Cercospora zeae-maydis",
              symptoms: [
                "Rectangular gray lesions",
                "Brown leaf spots",
                "Leaf blight",
                "Reduced grain yield",
              ],
              causes: [
                "Fungus infection",
                "Warm humid weather",
                "Crop residue contamination",
              ],
              treatment: [
                "Spray fungicides",
                "Remove infected debris",
                "Rotate crops",
              ],
              prevention: [
                "Use resistant hybrids",
                "Proper field drainage",
                "Crop rotation",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Northern Leaf Blight",
              scientificName: "Exserohilum turcicum",
              symptoms: [
                "Long cigar-shaped lesions",
                "Gray-green spots",
                "Leaf death",
              ],
              causes: [
                "Fungal pathogen",
                "High moisture conditions",
              ],
              treatment: [
                "Fungicide application",
                "Remove infected leaves",
                "Improve airflow",
              ],
              prevention: [
                "Disease-resistant hybrids",
                "Crop rotation",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Healthy Corn Leaf",
              scientificName: "Healthy Plant",
              symptoms: [
                "Bright green leaves",
                "Uniform growth",
                "No lesions or spots",
              ],
              causes: [
                "Good plant health",
              ],
              treatment: [
                "Adequate irrigation",
                "Balanced nutrients",
              ],
              prevention: [
                "Regular monitoring",
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget diseaseCard({
    required String title,
    required String scientificName,
    required List<String> symptoms,
    required List<String> causes,
    required List<String> treatment,
    required List<String> prevention,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Scientific Name: $scientificName",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            const Text(
              "Symptoms",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...symptoms.map((e) => Text("• $e")),

            const SizedBox(height: 12),

            const Text(
              "Causes",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...causes.map((e) => Text("• $e")),

            const SizedBox(height: 12),

            const Text(
              "Treatment",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...treatment.map((e) => Text("• $e")),

            const SizedBox(height: 12),

            const Text(
              "Prevention",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...prevention.map((e) => Text("• $e")),
          ],
        ),
      ),
    );
  }
}