import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/responsive_theme.dart';

class PotatoDiseasesScreen extends StatelessWidget {
  const PotatoDiseasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text("Potato Diseases"),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              children: const [
                DiseaseCard(
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

                SizedBox(height: 20),

                DiseaseCard(
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

                SizedBox(height: 20),

                DiseaseCard(
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
}