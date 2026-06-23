import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PotatoDiseasesScreen extends StatelessWidget {
  const PotatoDiseasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Potato Diseases"),
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
                  title: "Early Blight",
                  scientificName: "Alternaria solani",
                  overview: "Early blight is a fungal disease that targets leaves, creating concentric dark brown circular targets ('bullseye' pattern). It spreads rapidly in alternating wet and dry conditions in summer.",
                  causes: [
                    "Alternaria solani fungus",
                    "High temperatures combined with humid or wet foliage",
                    "Poor soil fertility and plant stress",
                  ],
                  symptoms: [
                    "Concentric ring brown spots on older leaves",
                    "Yellowing tissue surrounding spots",
                    "Early leaf defoliation",
                  ],
                  treatment: [
                    "Apply chlorothalonil, mancozeb, or strobilurin fungicides",
                    "Remove and destroy infected crop residues",
                  ],
                  organic: [
                    "Copper hydroxide fungicides",
                    "Sulfur sprays",
                    "Compost teas to strengthen leaves",
                  ],
                  prevention: [
                    "Practice crop rotation (avoid Solanaceous crops for 3 years)",
                    "Purchase certified disease-free seed tubers",
                    "Avoid overhead irrigation",
                    "Maintain proper plant spacing",
                  ],
                  recoveryTime: "Approximately 2 to 4 weeks if managed early.",
                  tips: "Inspect lower leaves weekly for brown targets with concentric rings. Early control protects tuber sizing.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Late Blight",
                  scientificName: "Phytophthora infestans",
                  overview: "Late blight is a highly destructive oomycete disease that destroys potato leaves and rots tubers. It spreads extremely rapidly in cool, wet weather and is infamous for causing the Irish Potato Famine.",
                  causes: [
                    "Phytophthora infestans water mold",
                    "Cool and wet weather conditions",
                    "Contaminated seed tubers",
                  ],
                  symptoms: [
                    "Large dark water-soaked leaf spots",
                    "White fuzzy fungal growth underneath leaves in wet weather",
                    "Smelly dark rotting stems and tubers",
                  ],
                  treatment: [
                    "Apply protective chlorothalonil or copper fungicides immediately",
                    "Kill vines if disease is severe to protect tubers",
                  ],
                  organic: [
                    "Frequent copper-based sprays",
                    "Bio-fungicides containing Bacillus subtilis",
                    "Strictly removing and burying infected plants",
                  ],
                  prevention: [
                    "Plant certified resistant tubers",
                    "Rotate crops annually",
                    "Maintain wide spacing to enhance foliage drying",
                    "Monitor weather alerts for cool wet periods",
                  ],
                  recoveryTime: "Irreversible in severe outbreaks; protective sprays must be active before infection.",
                  tips: "Inspect fields daily during cool, rainy summer spells. Remove and bury single infected plants immediately to prevent field-wide devastation.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Healthy Potato Leaf",
                  scientificName: "Solanum tuberosum",
                  overview: "A healthy potato leaf is wide, compound, and lush green, providing the energetic resources to form starch-filled tubers underground.",
                  causes: [
                    "Balanced nitrogen feeding",
                    "Deep and regular watering",
                    "Clean soil",
                    "Preventive disease monitoring",
                  ],
                  symptoms: [
                    "Lush dark green compound leaves",
                    "Firm upright posture",
                    "Absence of spots, lesions, or insect chewing",
                  ],
                  treatment: [
                    "Perform hilling around plants",
                    "Keep soil consistently moist",
                    "Monitor for potato beetles",
                  ],
                  organic: [
                    "Mulching with clean straw",
                    "Watering with compost tea",
                    "Applying diatomaceous earth for beetle control",
                  ],
                  prevention: [
                    "Routine checks",
                    "Rotate Solanaceous crops",
                    "Maintain soil organic matter",
                  ],
                  recoveryTime: "N/A",
                  tips: "Keep potato tubers fully covered with soil (hilling) to prevent greening and pests while keeping leaves healthy.",
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