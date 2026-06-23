import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RiceDiseasesScreen extends StatelessWidget {
  const RiceDiseasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rice Diseases"),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Center(
        child: Container(
          constraints: kIsWeb ? const BoxConstraints(maxWidth: 900) : null,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
          children: [

            diseaseCard(
              title: "Bacterial Leaf Blight",
              scientificName: "Xanthomonas oryzae",
              symptoms: [
                "Yellow leaf streaks",
                "Drying leaf tips",
                "Wilting",
              ],
              causes: [
                "Bacterial infection",
              ],
              treatment: [
                "Copper-based bactericides",
                "Balanced nitrogen use",
              ],
              prevention: [
                "Resistant varieties",
                "Clean irrigation water",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Brown Spot",
              scientificName: "Bipolaris oryzae",
              symptoms: [
                "Brown circular spots",
                "Reduced grain quality",
              ],
              causes: [
                "Fungal infection",
              ],
              treatment: [
                "Mancozeb fungicide",
                "Nutrient management",
              ],
              prevention: [
                "Healthy seeds",
                "Proper fertilization",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Leaf Smut",
              scientificName: "Entyloma oryzae",
              symptoms: [
                "Black streaks on leaves",
                "Distorted leaf tissue",
              ],
              causes: [
                "Fungal pathogen",
              ],
              treatment: [
                "Fungicide spray",
              ],
              prevention: [
                "Disease-free seed",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Healthy Rice Leaf",
              scientificName: "Healthy Plant",
              symptoms: [
                "Bright green leaves",
                "Strong tillers",
              ],
              causes: [
                "Good plant health",
              ],
              treatment: [
                "Proper water management",
                "Balanced nutrients",
              ],
              prevention: [
                "Regular crop monitoring",
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