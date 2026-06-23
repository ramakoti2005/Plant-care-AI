import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PotatoDiseasesScreen extends StatelessWidget {
  const PotatoDiseasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Potato Diseases"),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
          children: [

            diseaseCard(
              title: "Early Blight",
              scientificName: "Alternaria solani",
              symptoms: [
                "Dark concentric rings on leaves",
                "Yellowing foliage",
                "Reduced yield",
              ],
              causes: [
                "Fungal infection",
                "Warm humid conditions",
              ],
              treatment: [
                "Chlorothalonil fungicide",
                "Remove infected leaves",
              ],
              prevention: [
                "Crop rotation",
                "Disease-free seeds",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Late Blight",
              scientificName: "Phytophthora infestans",
              symptoms: [
                "Water-soaked lesions",
                "White fungal growth",
                "Tuber rot",
              ],
              causes: [
                "Oomycete pathogen",
                "Cool wet weather",
              ],
              treatment: [
                "Metalaxyl fungicide",
                "Remove infected plants",
              ],
              prevention: [
                "Proper drainage",
                "Certified seed potatoes",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Healthy Potato Leaf",
              scientificName: "Healthy Plant",
              symptoms: [
                "Dark green foliage",
                "Uniform growth",
              ],
              causes: [
                "Good plant health",
              ],
              treatment: [
                "Adequate watering",
                "Balanced fertilization",
              ],
              prevention: [
                "Regular monitoring",
              ],
            ),
          ],
        ),
      ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
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