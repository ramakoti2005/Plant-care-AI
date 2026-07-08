import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/responsive_theme.dart';
import 'treatment_detail_screen.dart';

class PeachDiseasesScreen extends StatelessWidget {
  const PeachDiseasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool web = ResponsiveTheme.isWebLayout(context);

    if (!web) {
      final diseases = [
        'Bacterial Spot',
        'Healthy Peach Leaf',
      ];

      return ResponsiveScaffold(
        appBar: AppBar(
          title: const Text("Peach Diseases"),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: diseases.length,
          itemBuilder: (context, index) {
            final name = diseases[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.eco, color: Colors.green),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TreatmentDetailScreen(diseaseName: name),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    }

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text("Peach Diseases"),
      ),
      body: Center(
        child: Container(
          constraints: web ? const BoxConstraints(maxWidth: 900) : null,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: const [
                DiseaseCard(
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

                SizedBox(height: 20),

                DiseaseCard(
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
        ),
      ),
    );
  }
}
