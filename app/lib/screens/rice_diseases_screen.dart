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

                const SizedBox(height: 20),

                diseaseCard(
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

                const SizedBox(height: 20),

                diseaseCard(
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

                const SizedBox(height: 20),

                diseaseCard(
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