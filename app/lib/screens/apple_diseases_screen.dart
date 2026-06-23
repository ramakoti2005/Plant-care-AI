import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppleDiseasesScreen extends StatelessWidget {
  const AppleDiseasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Apple Diseases"),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Center(
        child: Container(
          constraints: kIsWeb ? const BoxConstraints(maxWidth: 800) : null,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
          children: [
            diseaseCard(
              title: "Apple Scab",
              scientificName: "Venturia inaequalis",
              symptoms: [
                "Olive-green spots on leaves",
                "Dark lesions on fruits",
                "Premature leaf drop",
                "Cracked fruit surface",
              ],
              causes: [
                "Fungal infection",
                "Wet and humid weather",
                "Poor air circulation",
              ],
              treatment: [
                "Apply Captan fungicide",
                "Remove infected leaves",
                "Prune crowded branches",
                "Avoid overhead irrigation",
              ],
              prevention: [
                "Maintain orchard hygiene",
                "Use resistant apple varieties",
                "Ensure proper spacing",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Black Rot",
              scientificName: "Botryosphaeria obtusa",
              symptoms: [
                "Purple spots on leaves",
                "Black rotten fruits",
                "Dead branches",
                "Cankers on bark",
              ],
              causes: [
                "Fungal infection",
                "Warm and humid conditions",
              ],
              treatment: [
                "Remove infected fruits",
                "Prune diseased branches",
                "Apply fungicide spray",
                "Burn infected debris",
              ],
              prevention: [
                "Proper sanitation",
                "Regular pruning",
                "Improve air circulation",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Cedar Apple Rust",
              scientificName:
              "Gymnosporangium juniperi-virginianae",
              symptoms: [
                "Bright yellow leaf spots",
                "Orange lesions",
                "Premature leaf drop",
              ],
              causes: [
                "Fungal pathogen",
                "Nearby cedar/juniper trees",
              ],
              treatment: [
                "Use fungicides",
                "Remove nearby infected cedar hosts",
                "Prune affected leaves",
              ],
              prevention: [
                "Plant resistant cultivars",
                "Monitor orchard regularly",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Healthy Apple Leaf",
              scientificName: "Healthy Plant",
              symptoms: [
                "Uniform green color",
                "No spots or lesions",
                "Strong leaf structure",
                "Normal growth pattern",
              ],
              causes: [
                "Good plant health",
              ],
              treatment: [
                "Proper irrigation",
                "Balanced fertilization",
              ],
              prevention: [
                "Pest monitoring",
                "Seasonal pruning",
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