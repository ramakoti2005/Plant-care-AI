import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/responsive_theme.dart';
import 'treatment_detail_screen.dart';

class RiceDiseasesScreen extends StatelessWidget {
  const RiceDiseasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool web = ResponsiveTheme.isWebLayout(context);

    if (!web) {
      final diseases = [
        'Brown Spot',
        'Leaf Blast',
        'Neck Blast',
        'Healthy Rice Leaf',
      ];

      return ResponsiveScaffold(
        appBar: AppBar(
          title: const Text("Rice Diseases"),
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
        title: const Text("Rice Diseases"),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              children: const [
                DiseaseCard(
                  title: "Brown Spot",
                  scientificName: "Cochliobolus miyabeanus",
                  overview: "Brown spot is a fungal disease affecting rice leaves, glumes, and grains, characterized by small oval-to-circular brown lesions. It is highly associated with nutrient-deficient, poorly drained soil.",
                  causes: [
                    "Cochliobolus miyabeanus fungal pathogen",
                    "Poorly fertilized soil (specifically low nitrogen and potassium)",
                    "Water stress and poor field management",
                  ],
                  symptoms: [
                    "Small brown circular/oval spots on leaves",
                    "Gray or light brown centers in mature spots",
                    "Black spots on grains",
                  ],
                  treatment: [
                    "Apply silicon-containing fertilizers",
                    "Apply triazole or strobilurin fungicides",
                    "Improve soil fertility and nutrient balance",
                  ],
                  organic: [
                    "Foliar sprays of neem oil",
                    "Copper hydroxide soap solutions",
                    "Foliar compost tea",
                    "Adding well-decomposed manure to soil",
                  ],
                  prevention: [
                    "Practice balanced fertilizer application (NPK + Silicon)",
                    "Use clean certified seeds",
                    "Optimize field drainage and water supply",
                  ],
                  recoveryTime: "Approximately 3 to 5 weeks with soil nutrient correction.",
                  tips: "Inspect leaves weekly. If small brown spots appear, check soil potassium levels and address nutrient deficits immediately.",
                ),

                SizedBox(height: 20),

                DiseaseCard(
                  title: "Leaf Blast",
                  scientificName: "Magnaporthe oryzae",
                  overview: "Leaf blast is a devastating fungal disease of rice that produces spindle-shaped lesions with gray centers on foliage. It spreads quickly during warm, humid conditions with cool nights.",
                  causes: [
                    "Magnaporthe oryzae fungus",
                    "Excessive nitrogen fertilizer",
                    "Warm and wet weather with cool nights",
                    "High relative humidity",
                  ],
                  symptoms: [
                    "Spindle-shaped (diamond-shaped) leaf lesions",
                    "Gray/white centers with reddish-brown borders",
                    "Leaf drying and premature death",
                  ],
                  treatment: [
                    "Apply Tricyclazole or Azoxystrobin fungicides",
                    "Reduce nitrogen fertilizer application",
                    "Flood fields immediately to suppress disease",
                  ],
                  organic: [
                    "Copper-based sprays",
                    "Bio-fungicides containing Bacillus subtilis",
                    "Preventive compost tea foliar sprays",
                  ],
                  prevention: [
                    "Plant blast-resistant cultivars",
                    "Avoid excessive nitrogen fertilization",
                    "Synchronize planting dates in the district",
                    "Keep fields properly flooded",
                  ],
                  recoveryTime: "Approximately 2 to 4 weeks depending on weather conditions.",
                  tips: "Inspect leaf blades weekly in early vegetative stages. Catching diamond-shaped spots early prevents transition to neck blast.",
                ),

                SizedBox(height: 20),

                DiseaseCard(
                  title: "Neck Blast",
                  scientificName: "Magnaporthe oryzae",
                  overview: "Neck blast occurs when the blast fungus attacks the neck node at the base of the rice panicle, causing the panicle to fall over and turn gray. This phase of blast is highly destructive, causing complete grain loss.",
                  causes: [
                    "Magnaporthe oryzae fungal spores",
                    "High relative humidity and dew",
                    "Warm daytime temperatures followed by cool nights",
                    "High nitrogen levels in soil",
                  ],
                  symptoms: [
                    "Dark brown neck node rot",
                    "Panicle falling over (neck rot)",
                    "Blanked light-gray grain heads",
                  ],
                  treatment: [
                    "Spray systemic fungicides like Tricyclazole at late booting/early heading stage",
                    "Harvest early if possible to save remaining grain",
                  ],
                  organic: [
                    "Copper soaps sprayed preemptively before panicle emergence",
                    "Boosting plant immunity with organic silicon sprays",
                  ],
                  prevention: [
                    "Grow resistant rice varieties",
                    "Avoid late nitrogen top-dressing",
                    "Maintain consistent flooding",
                    "Prune surrounding vegetation to improve air flow",
                  ],
                  recoveryTime: "Irreversible; direct panicle neck rot results in permanent crop loss for the affected head.",
                  tips: "Inspect panicle neck nodes weekly during heading. Preemptive spraying is critical since neck blast cannot be cured once visible.",
                ),

                SizedBox(height: 20),

                DiseaseCard(
                  title: "Healthy Rice Leaf",
                  scientificName: "Oryza sativa",
                  overview: "A healthy rice leaf is erect, long, and vibrant green, supporting clean grain filling and robust panicle weight.",
                  causes: [
                    "Consistent flooding",
                    "Balanced NPK fertilizing",
                    "Ample sunlight",
                    "Preventive pest and disease management",
                  ],
                  symptoms: [
                    "Flat, erect leaf blades of uniform green color",
                    "Clean leaf margins without yellowing",
                    "Sturdy ligule/auricle joints",
                  ],
                  treatment: [
                    "Maintain weed control",
                    "Clean flood water supply",
                    "Follow seasonal fertilization guidelines",
                  ],
                  organic: [
                    "Green manuring",
                    "Application of organic compost",
                    "Weekly foliar spraying of seaweed extract",
                  ],
                  prevention: [
                    "Crop rotation",
                    "Visual field scouting",
                    "Testing irrigation water regularly",
                  ],
                  recoveryTime: "N/A",
                  tips: "Walk fields weekly checking auricle zones. Sturdy, clean leaves are the key to high-yielding panicles.",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}