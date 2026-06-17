import 'package:flutter/material.dart';

class TomatoDiseasesScreen extends StatelessWidget {
  const TomatoDiseasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tomato Diseases"),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            diseaseCard(
              title: "Bacterial Spot",
              scientificName: "Xanthomonas campestris",
              symptoms: [
                "Small dark leaf spots",
                "Fruit lesions",
              ],
              causes: [
                "Bacterial infection",
              ],
              treatment: [
                "Copper fungicides",
                "Remove infected plants",
              ],
              prevention: [
                "Certified seeds",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Early Blight",
              scientificName: "Alternaria solani",
              symptoms: [
                "Target-shaped spots",
                "Yellow leaves",
              ],
              causes: [
                "Fungal infection",
              ],
              treatment: [
                "Chlorothalonil fungicide",
              ],
              prevention: [
                "Crop rotation",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Late Blight",
              scientificName: "Phytophthora infestans",
              symptoms: [
                "Dark water-soaked lesions",
                "Fruit rot",
              ],
              causes: [
                "Oomycete infection",
              ],
              treatment: [
                "Metalaxyl fungicide",
              ],
              prevention: [
                "Proper spacing",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Leaf Mold",
              scientificName: "Passalora fulva",
              symptoms: [
                "Yellow leaf patches",
                "Olive-green mold underneath",
              ],
              causes: [
                "High humidity",
              ],
              treatment: [
                "Fungicide spray",
                "Improve ventilation",
              ],
              prevention: [
                "Reduce humidity",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Septoria Leaf Spot",
              scientificName: "Septoria lycopersici",
              symptoms: [
                "Small circular gray spots",
                "Yellowing leaves",
              ],
              causes: [
                "Fungal pathogen",
              ],
              treatment: [
                "Copper fungicides",
              ],
              prevention: [
                "Remove infected debris",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Mosaic Virus",
              scientificName: "Tomato Mosaic Virus (ToMV)",
              symptoms: [
                "Mosaic leaf patterns",
                "Stunted growth",
              ],
              causes: [
                "Viral infection",
              ],
              treatment: [
                "No cure available",
                "Remove infected plants",
              ],
              prevention: [
                "Resistant varieties",
                "Sanitize tools",
              ],
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Healthy Tomato Leaf",
              scientificName: "Healthy Plant",
              symptoms: [
                "Bright green foliage",
                "No lesions",
              ],
              causes: [
                "Good plant health",
              ],
              treatment: [
                "Proper irrigation",
                "Balanced nutrients",
              ],
              prevention: [
                "Pest monitoring",
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