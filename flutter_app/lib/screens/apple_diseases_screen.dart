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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                diseaseCard(
                  title: "Apple Scab",
                  scientificName: "Venturia inaequalis",
                  overview: "Apple scab is a major fungal disease affecting apple trees, causing scabby lesions on leaves and fruit. It thrives in cool, wet spring weather and can cause severe defoliation and yield loss.",
                  causes: [
                    "Venturia inaequalis fungus",
                    "Cool and wet spring conditions",
                    "Overwintered leaf debris on orchard floor",
                  ],
                  symptoms: [
                    "Olive-green to black spots on leaves",
                    "Dark velvety lesions on fruit",
                    "Premature leaf drop",
                    "Cracked fruit surface",
                  ],
                  treatment: [
                    "Apply Captan or Mancozeb fungicide sprays",
                    "Prune branches to increase air circulation",
                    "Destroy fallen leaves",
                  ],
                  organic: [
                    "Sulfur/copper fungicides",
                    "Baking soda sprays",
                    "Neem oil",
                    "Compost tea to boost leaf health",
                  ],
                  prevention: [
                    "Plant scab-resistant cultivars",
                    "Rake and burn fallen leaves",
                    "Maintain proper tree spacing and pruning",
                  ],
                  recoveryTime: "Approximately 3 to 6 weeks depending on early detection.",
                  tips: "Inspect leaves weekly during cool, damp spring weather. Fast action prevents early spore dissemination.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Black Rot",
                  scientificName: "Botryosphaeria obtusa",
                  overview: "Black rot causes frog-eye leaf spot, fruit rot, and cankers on branches. It overwinters in cankers and mummified fruit, spreading rapidly during warm, wet summer weather.",
                  causes: [
                    "Botryosphaeria obtusa fungus",
                    "Warm and humid summer conditions",
                    "Infected dead wood or mummified fruit left on trees",
                  ],
                  symptoms: [
                    "Frog-eye spots on leaves",
                    "Dark brown rotating circles on fruit",
                    "Mummified black fruit",
                    "Cankers on limbs",
                  ],
                  treatment: [
                    "Remove infected fruits and mummified fruit",
                    "Prune cankered limbs",
                    "Apply copper sprays or chemical fungicides",
                  ],
                  organic: [
                    "Liquid copper hydroxide sprays",
                    "Organic pruning paint",
                    "Regular application of compost tea",
                  ],
                  prevention: [
                    "Practice meticulous sanitation by pruning out dead wood",
                    "Burn infected debris",
                    "Choose resistant varieties",
                  ],
                  recoveryTime: "Approximately 4 to 8 weeks for branch canker healing; fruit rot is irreversible.",
                  tips: "Check branches for dark, sunken cankers during winter pruning. Early removal prevents spring spore release.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Cedar Apple Rust",
                  scientificName: "Gymnosporangium juniperi-virginianae",
                  overview: "Cedar apple rust is a dual-host fungal disease requiring both apple trees and red cedars to complete its life cycle. It causes bright orange spots on leaves and distorts developing fruit.",
                  causes: [
                    "Gymnosporangium juniperi-virginianae fungus",
                    "Nearby cedar or juniper trees",
                    "Humid air and rain",
                  ],
                  symptoms: [
                    "Bright yellow-orange shiny spots on upper leaves",
                    "Tiny tube structures underneath leaves",
                    "Defoliation",
                  ],
                  treatment: [
                    "Apply Myclobutanil or Propiconazole fungicides",
                    "Remove nearby infected cedar hosts",
                    "Prune infected leaves",
                  ],
                  organic: [
                    "Sulfur sprays",
                    "Neem oil",
                    "Copper fungicides",
                    "Removing cedar galls before they release spores",
                  ],
                  prevention: [
                    "Avoid planting apples near cedars",
                    "Choose rust-resistant varieties",
                    "Monitor trees closely during warm spring rains",
                  ],
                  recoveryTime: "Approximately 3 to 5 weeks for foliage recovery; fruit damage remains.",
                  tips: "Inspect apple trees weekly in late spring for small yellow dots on leaves, especially if red cedars are within 100 meters.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Healthy Apple Leaf",
                  scientificName: "Malus domestica",
                  overview: "A healthy apple leaf is vibrant green, firm, and fully functional, supporting fruit production and photosynthesis.",
                  causes: [
                    "Optimal nutrition",
                    "Regular watering",
                    "Appropriate pruning",
                    "Protective management",
                  ],
                  symptoms: [
                    "Uniform green color",
                    "Smooth leaf edges",
                    "Sturdy petiole structure",
                    "No spots or insect damage",
                  ],
                  treatment: [
                    "Maintain routine pruning",
                    "Proper irrigation",
                    "Balanced nitrogen fertilization",
                  ],
                  organic: [
                    "Compost application",
                    "Mulching",
                    "Weekly foliar sprays of compost tea",
                  ],
                  prevention: [
                    "Visual checks",
                    "Regular pruning",
                    "Maintaining soil health",
                  ],
                  recoveryTime: "N/A",
                  tips: "Inspect leaves weekly to catch early warning signs of pests or nutrient deficiencies before they spread.",
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