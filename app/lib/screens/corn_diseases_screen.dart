import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CornDiseasesScreen extends StatelessWidget {
  const CornDiseasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Corn Diseases"),
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
                  title: "Common Rust",
                  scientificName: "Puccinia sorghi",
                  overview: "Common rust is a fungal disease that affects corn leaves, producing powdery golden-brown pustules. It thrives in moderate temperatures and high humidity, spreading via windborne spores.",
                  causes: [
                    "Puccinia sorghi fungal pathogen",
                    "Cool to moderate temperatures (16-24°C)",
                    "High relative humidity or prolonged dew",
                  ],
                  symptoms: [
                    "Small, powdery cinnamon-brown pustules on both leaf surfaces",
                    "Leaf yellowing around pustules",
                    "Premature leaf death in severe cases",
                  ],
                  treatment: [
                    "Apply chlorothalonil or strobulurin fungicides",
                    "Remove and destroy crop residues after harvest",
                  ],
                  organic: [
                    "Sulfur dusts",
                    "Copper-based fungicides",
                    "Compost tea sprays",
                  ],
                  prevention: [
                    "Plant rust-resistant corn hybrids",
                    "Maintain adequate plant spacing",
                    "Avoid overhead watering",
                  ],
                  recoveryTime: "Approximately 2 to 3 weeks if treatment starts early.",
                  tips: "Inspect upper and lower leaf surfaces weekly during humid summer conditions to spot early rust spots.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Gray Leaf Spot",
                  scientificName: "Cercospora zeae-maydis",
                  overview: "Gray leaf spot is a persistent fungal disease characterized by rectangular, gray-to-brown spots on corn leaves. It overwinters in crop residues and can cause severe blighting under warm, moist conditions.",
                  causes: [
                    "Cercospora zeae-maydis fungus",
                    "Warm temperatures (24-30°C)",
                    "Prolonged leaf wetness",
                    "Minimum tillage systems leaving residue",
                  ],
                  symptoms: [
                    "Rectangular brown/gray lesions bounded by leaf veins",
                    "Pale green halos around young spots",
                    "Extensive leaf blighting",
                  ],
                  treatment: [
                    "Apply triazole or strobilurin fungicides",
                    "Practice crop rotation (non-host crops for 2 years)",
                  ],
                  organic: [
                    "Liquid copper soaps",
                    "Neem oil sprays",
                    "Foliar sprays of beneficial microbe mixtures",
                  ],
                  prevention: [
                    "Select resistant hybrids",
                    "Deep-plow crop residues to accelerate breakdown",
                    "Ensure proper field drainage",
                  ],
                  recoveryTime: "Approximately 3 to 4 weeks depending on severity.",
                  tips: "Walk fields weekly after silking and check lower leaves for vein-bounded gray rectangular spots.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Northern Leaf Blight",
                  scientificName: "Exserohilum turcicum",
                  overview: "Northern leaf blight produces large, cigar-shaped grayish-green lesions on corn leaves. It causes rapid tissue death under moderate, humid conditions and is highly damaging during the grain-fill stage.",
                  causes: [
                    "Exserohilum turcicum fungus",
                    "Moderate temperatures (18-27°C)",
                    "Prolonged moisture (heavy dew or rain)",
                  ],
                  symptoms: [
                    "Long, elliptical cigar-shaped grayish-green lesions",
                    "Dusty dark spores in centers of spots during humid spells",
                    "Premature leaf death",
                  ],
                  treatment: [
                    "Apply strobulurin or triazole fungicides",
                    "Rotate with non-grass crops",
                    "Plow crop residue down",
                  ],
                  organic: [
                    "Copper hydroxide sprays",
                    "Neem oil formulations",
                    "Regular compost tea foliar sprays",
                  ],
                  prevention: [
                    "Choose resistant hybrids",
                    "Space plants properly",
                    "Destroy infected crop residues",
                  ],
                  recoveryTime: "Approximately 3 to 5 weeks for foliage protection; existing spots do not heal.",
                  tips: "Check lower leaves weekly during warm, moist weather. Catching cigar-shaped lesions early protects the ears.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Healthy Corn Leaf",
                  scientificName: "Zea mays",
                  overview: "A healthy corn leaf is long, rich green, and erect, maximizing light capture for robust stalk and ear development.",
                  causes: [
                    "Balanced nitrogen-phosphorus-potassium fertilizing",
                    "Deep watering",
                    "Proper soil pH",
                    "Adequate sunlight",
                  ],
                  symptoms: [
                    "Dark green uniform coloration",
                    "Smooth edges",
                    "Sturdy upright leaf angle",
                    "No powdery rust or leaf lesions",
                  ],
                  treatment: [
                    "Continue standard weeding",
                    "Side-dress nitrogen",
                    "Monitor water schedules",
                  ],
                  organic: [
                    "Add well-composted organic matter",
                    "Cover cropping",
                    "Applications of fish emulsion",
                  ],
                  prevention: [
                    "Regular field walks",
                    "Crop rotation",
                    "Test soil nutrients annually",
                  ],
                  recoveryTime: "N/A",
                  tips: "Keep soil well-aerated and watered during tassel stage. Weekly leaf checks ensure early defense.",
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