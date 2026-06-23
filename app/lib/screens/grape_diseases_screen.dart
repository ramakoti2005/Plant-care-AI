import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GrapeDiseasesScreen extends StatelessWidget {
  const GrapeDiseasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grape Diseases"),
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
              title: "Black Rot",
              scientificName: "Guignardia bidwellii",
              symptoms: [
                "Brown circular spots",
                "Black shriveled berries",
                "Leaf lesions",
              ],
              causes: [
                "Fungal infection",
                "Warm wet weather",
              ],
              treatment: [
                "Apply fungicides",
                "Remove infected fruits",
                "Prune affected areas",
              ],
              prevention: [
                "Good air circulation",
                "Orchard sanitation",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Esca (Black Measles)",
              scientificName: "Phaeomoniella chlamydospora",
              symptoms: [
                "Tiger-striped leaves",
                "Sudden vine collapse",
                "Fruit spotting",
              ],
              causes: [
                "Wood-inhabiting fungi",
              ],
              treatment: [
                "Remove infected vines",
                "Prune diseased wood",
              ],
              prevention: [
                "Sanitize pruning tools",
                "Avoid trunk injuries",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Leaf Blight",
              scientificName: "Pseudocercospora vitis",
              symptoms: [
                "Brown leaf lesions",
                "Yellow leaf margins",
                "Premature leaf fall",
              ],
              causes: [
                "Fungal infection",
              ],
              treatment: [
                "Fungicide spray",
                "Remove infected leaves",
              ],
              prevention: [
                "Proper vineyard hygiene",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Healthy Grape Leaf",
              scientificName: "Healthy Plant",
              symptoms: [
                "Uniform green color",
                "Strong vine growth",
                "No discoloration",
              ],
              causes: [
                "Good plant health",
              ],
              treatment: [
                "Balanced irrigation",
                "Regular pruning",
              ],
              prevention: [
                "Routine monitoring",
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