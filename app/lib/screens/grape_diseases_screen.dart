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
                  title: "Black Rot",
                  scientificName: "Guignardia bidwellii",
                  overview: "Black rot is a highly destructive fungal disease affecting all green parts of grapevines, turning berries into hard, shriveled black mummies. It thrives in warm, wet conditions during early shoot growth.",
                  causes: [
                    "Guignardia bidwellii fungus",
                    "Warm and humid weather",
                    "Spores overwintering in mummified berries and cane cankers",
                  ],
                  symptoms: [
                    "Small brown circular leaf lesions with dark borders",
                    "Black dots (pycnidia) inside spots",
                    "Shriveled rotting berries covered in black pimples",
                  ],
                  treatment: [
                    "Apply Mancozeb, Captan, or Myclobutanil fungicides",
                    "Prune out mummified berries and cankered canes",
                  ],
                  organic: [
                    "Copper-based fungicides",
                    "Liquid sulfur sprays",
                    "Compost teas to encourage healthy competition on leaf surface",
                  ],
                  prevention: [
                    "Rake and burn fallen debris",
                    "Destroy all fruit mummies on trellis and ground",
                    "Ensure open canopy for fast drying",
                  ],
                  recoveryTime: "Approximately 3 to 6 weeks for canopy health; affected fruit is lost.",
                  tips: "Inspect leaves and berry clusters weekly from bud break through bloom. Wet springs are high-risk periods.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Esca (Black Measles)",
                  scientificName: "Phaeomoniella chlamydospora",
                  overview: "Esca is a complex wood-rotting disease affecting grapevine vascular tissue, causing distinctive 'tiger-stripe' leaf patterns and dark spots on berries. It enters via winter pruning wounds.",
                  causes: [
                    "Wood-inhabiting fungi complex",
                    "Older vines",
                    "Winter pruning wounds left unprotected",
                    "Warm dry summer conditions",
                  ],
                  symptoms: [
                    "Tiger-stripe leaf yellowing and necrosis",
                    "Small dark purple spots on fruit ('measles')",
                    "Vascular streaking in vine wood",
                  ],
                  treatment: [
                    "Apply protective wound paint after winter pruning",
                    "Prune out dead cordons and trunks",
                    "Replace severely affected vines",
                  ],
                  organic: [
                    "Trichoderma-based bio-fungicide pruning wound protectants",
                    "Maintain vine vigor through balanced organic nutrition",
                  ],
                  prevention: [
                    "Clean tools with alcohol between vines",
                    "Prune during dry weather",
                    "Apply sealants to large pruning cuts immediately",
                  ],
                  recoveryTime: "Chronic disease; management takes multiple seasons to stabilize vine productivity.",
                  tips: "Mark symptomatic vines during late summer to prune them last in winter, minimizing pathogen spread to healthy vines.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Leaf Blight",
                  scientificName: "Pseudocercospora vitis",
                  overview: "Leaf blight causes dark brown, angular necrotic lesions on grapevine leaves, leading to premature yellowing and defoliation. It spreads via wind and rain splash in late summer.",
                  causes: [
                    "Pseudocercospora vitis fungus",
                    "Warm wet conditions in late summer/early autumn",
                    "Poor vineyard sanitation",
                  ],
                  symptoms: [
                    "Dark brown angular leaf spots",
                    "Yellowing borders around spots",
                    "Premature leaf drying and drop",
                  ],
                  treatment: [
                    "Apply copper hydroxide sprays or protective fungicides",
                    "Clear fallen leaves from vineyard floor",
                  ],
                  organic: [
                    "Copper hydroxide formulations",
                    "Sulfur sprays",
                    "Horsetail extract or compost tea sprays",
                  ],
                  prevention: [
                    "Maintain vine vigor with balanced composting",
                    "Prune cordons to keep canopy thin and dry",
                    "Use cover crops",
                  ],
                  recoveryTime: "Approximately 3 to 5 weeks for vegetative recovery.",
                  tips: "Inspect lower inner leaves weekly in mid-to-late summer, checking for dark angular spots that lead to leaf yellowing.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Healthy Grape Leaf",
                  scientificName: "Vitis vinifera",
                  overview: "A healthy grape leaf is broad, dark green, and vibrant, driving photosynthesis to support sugar synthesis in sweet berry clusters.",
                  causes: [
                    "Balanced micronutrients",
                    "Deep roots",
                    "Moderate canopy pruning",
                    "Protective mildew control",
                  ],
                  symptoms: [
                    "Rich green uniform coloring",
                    "Clean defined leaf margins",
                    "Firm texture",
                    "No powdery mildew or spot lesions",
                  ],
                  treatment: [
                    "Maintain weed control",
                    "Perform leaf pulling around fruit zones",
                    "Irrigate deeply",
                  ],
                  organic: [
                    "Well-aged compost",
                    "Kelp meal soil amendments",
                    "Preventive compost tea sprays",
                  ],
                  prevention: [
                    "Annual soil testing",
                    "Strategic pruning",
                    "Routine canopy thinning",
                  ],
                  recoveryTime: "N/A",
                  tips: "Perform leaf pulling in the cluster zone weekly to allow air flow and sunlight, keeping leaves clean and dry.",
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