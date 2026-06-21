import 'package:flutter/material.dart';

class PeachDiseasesScreen extends StatelessWidget {
  const PeachDiseasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peach Diseases"),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            diseaseCard(
              title: "Bacterial Spot",
              scientificName: "Xanthomonas arboricola pv. pruni",
              overview: "Bacterial Spot is a bacterial disease that affects peach leaves and fruits. It spreads rapidly during warm and wet weather and can reduce both fruit quality and yield.",
              causes: [
                "Xanthomonas bacteria",
                "Rain splash and strong winds",
                "Infected planting material",
                "High humidity",
              ],
              symptoms: [
                "Small dark spots on leaves",
                "Yellowing around lesions",
                "Holes in leaves",
                "Sunken spots on fruits",
              ],
              treatment: [
                "Remove infected leaves and fruits",
                "Avoid overhead irrigation",
                "Improve air circulation by pruning",
                "Apply copper-based bactericides or copper hydroxide",
              ],
              organic: [
                "Neem oil spray",
                "Copper soap formulations",
                "Maintain proper sanitation around the tree",
              ],
              prevention: [
                "Plant disease-free seedlings",
                "Prune regularly",
                "Avoid excessive nitrogen fertilizer",
                "Clean fallen leaves",
              ],
              recoveryTime: "Approximately 2–4 weeks if treated early.",
              tips: "Inspect plants weekly during the rainy season. Early detection and timely spraying greatly reduce crop damage.",
            ),

            const SizedBox(height: 20),

            diseaseCard(
              title: "Healthy Peach Leaf",
              scientificName: "Prunus persica",
              overview: "A healthy peach leaf is vibrant green, firm, and free of spots or holes.",
              causes: [
                "Optimal environmental conditions",
                "Good plant nutrition",
              ],
              symptoms: [
                "Smooth green surface",
                "No discoloration",
              ],
              treatment: [
                "Continue standard care",
              ],
              organic: [
                "Compost and mulching",
              ],
              prevention: [
                "Regular monitoring",
              ],
              recoveryTime: "N/A",
              tips: "Maintain consistent watering and nutrient supply for peak performance.",
            ),
          ],
        ),
      ),
    );
  }

  Widget diseaseCard({
    required String title,
    required String scientificName,
    required String overview,
    required List<String> causes,
    required List<String> symptoms,
    required List<String> treatment,
    required List<String> prevention,
    List<String>? organic,
    String? recoveryTime,
    String? tips,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Scientific Name: $scientificName",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
            const Divider(height: 25),
            
            const Text(
              "Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(overview),

            const SizedBox(height: 15),
            sectionTitle("Causes"),
            ...causes.map((e) => bulletPoint(e)),

            const SizedBox(height: 15),
            sectionTitle("Symptoms"),
            ...symptoms.map((e) => bulletPoint(e)),

            const SizedBox(height: 15),
            sectionTitle("Treatment"),
            ...treatment.map((e) => bulletPoint(e)),

            if (organic != null) ...[
              const SizedBox(height: 15),
              sectionTitle("Organic Remedies"),
              ...organic.map((e) => bulletPoint(e)),
            ],

            const SizedBox(height: 15),
            sectionTitle("Prevention"),
            ...prevention.map((e) => bulletPoint(e)),

            if (recoveryTime != null && recoveryTime != "N/A") ...[
              const SizedBox(height: 15),
              sectionTitle("Recovery Time"),
              Text(recoveryTime),
            ],

            if (tips != null) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Farmer Tips",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(tips),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
