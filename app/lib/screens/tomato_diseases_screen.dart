import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TomatoDiseasesScreen extends StatelessWidget {
  const TomatoDiseasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tomato Diseases"),
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
                  title: "Bacterial Spot",
                  scientificName: "Xanthomonas campestris pv. vesicatoria",
                  overview: "Bacterial spot causes dark, water-soaked circular lesions on tomato leaves and scab-like spots on developing fruit. It spreads extremely rapidly in warm, rainy conditions via splash vectors.",
                  causes: [
                    "Xanthomonas campestris pv. vesicatoria bacteria",
                    "High relative humidity",
                    "Rain splash and wind vectors",
                    "Overhead watering",
                  ],
                  symptoms: [
                    "Small dark water-soaked spots on foliage",
                    "Yellow halos around lesions",
                    "Scab-like raised spots on fruit",
                  ],
                  treatment: [
                    "Spray copper-based bactericides",
                    "Prune out lower inner branches",
                    "Destroy infected debris",
                  ],
                  organic: [
                    "Copper hydroxide spray",
                    "Bio-bactericide containing Bacillus subtilis",
                    "Neem oil prevention",
                  ],
                  prevention: [
                    "Grow certified disease-free seed",
                    "Rotate crops with non-solanaceous species",
                    "Avoid working in wet fields",
                  ],
                  recoveryTime: "Approximately 2 to 4 weeks with early treatment.",
                  tips: "Inspect inner leaves weekly during wet spells. Pruning branches within 12 inches of the ground prevents splash inoculations.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Early Blight",
                  scientificName: "Alternaria solani",
                  overview: "Early blight is a common fungal disease forming dark target-like concentric ring spots on tomato leaves, progressing from bottom foliage upward. It thrives in humid summer climates.",
                  causes: [
                    "Alternaria solani fungus",
                    "High temperatures",
                    "Frequent foliage wetting",
                    "Nutrient stress and plant age",
                  ],
                  symptoms: [
                    "Target-like concentric ring lesions on lower leaves",
                    "Yellow leaf tissue surrounding lesions",
                    "Leaf drop and stem lesions",
                  ],
                  treatment: [
                    "Apply chlorothalonil or copper fungicides",
                    "Clean up and destroy plant debris after harvest",
                  ],
                  organic: [
                    "Copper hydroxide sprays",
                    "Foliar compost teas",
                    "Thick mulching to prevent soil spore splash",
                  ],
                  prevention: [
                    "Practice crop rotation",
                    "Mulch the soil surface immediately after planting",
                    "Water only at the base of the plant",
                    "Space plants to allow airflow",
                  ],
                  recoveryTime: "Approximately 3 to 5 weeks for vegetative recovery.",
                  tips: "Check lower leaves weekly for brown target circles. Heavy mulching at planting is the best barrier against early blight.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Late Blight",
                  scientificName: "Phytophthora infestans",
                  overview: "Late blight is a highly destructive oomycete disease that collapses tomato leaves, blackens stems, and rots fruit in cool, wet summer weather. It can destroy whole fields in days.",
                  causes: [
                    "Phytophthora infestans water mold",
                    "Cool and wet weather conditions",
                    "Infected adjacent potato or tomato plantings",
                  ],
                  symptoms: [
                    "Large dark greasy water-soaked leaf spots",
                    "White fuzzy growth under leaves in humid weather",
                    "Dark rot on stems and fruit",
                  ],
                  treatment: [
                    "Apply protective chlorothalonil or copper fungicides immediately",
                    "Destroy and bury infected plants to halt spread",
                  ],
                  organic: [
                    "Weekly copper hydroxide sprays",
                    "Bio-fungicides containing Bacillus subtilis",
                    "Removing and destroying infected plants immediately",
                  ],
                  prevention: [
                    "Grow resistant cultivars",
                    "Check weather forecasts for wet cool spells",
                    "Maintain wide spacing between plants",
                  ],
                  recoveryTime: "Irreversible once stem rot establishes.",
                  tips: "Inspect fields daily during cool, rainy summer spells. Early destruction of infected vines is crucial to save the rest of the patch.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Leaf Mold",
                  scientificName: "Passalora fulva",
                  overview: "Leaf mold is a greenhouse-associated fungal disease that produces pale-green spots on upper leaf surfaces and olive-green velvety mold underneath. It thrives in high humidity and stagnant air.",
                  causes: [
                    "Passalora fulva fungus",
                    "Relative humidity above 85%",
                    "Moderate temperatures",
                    "Poor air circulation inside greenhouses",
                  ],
                  symptoms: [
                    "Pale yellow spots on upper leaf surfaces",
                    "Olive-green velvety spore masses on undersides of leaves",
                    "Leaf death and leaf drop",
                  ],
                  treatment: [
                    "Improve greenhouse ventilation and circulation",
                    "Apply chlorothalonil or copper fungicides",
                    "Prune lower branches",
                  ],
                  organic: [
                    "Copper-based fungicides",
                    "Potassium bicarbonate sprays",
                    "Enhancing ventilation with exhaust fans",
                  ],
                  prevention: [
                    "Maintain humidity below 80%",
                    "Plant resistant greenhouse varieties",
                    "Prune foliage to open up canopy",
                    "Clean and disinfect greenhouse structures annually",
                  ],
                  recoveryTime: "Approximately 2 to 4 weeks with humidity correction.",
                  tips: "Inspect the undersides of leaves weekly, especially in dense greenhouse stands. Good exhaust fans prevent mold.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Septoria Leaf Spot",
                  scientificName: "Septoria lycopersici",
                  overview: "Septoria leaf spot is a very common fungal disease producing numerous small brown spots with grey centers and dark borders on tomato foliage, starting from the lower leaves.",
                  causes: [
                    "Septoria lycopersici fungus",
                    "Warm temperatures",
                    "Wet leaf surfaces (rain or dew)",
                    "Spores splashing from soil",
                  ],
                  symptoms: [
                    "Tiny circular spots with dark margins and greyish-white centers",
                    "Black pin-point spots (pycnidia) in centers of spots",
                    "Rapid defoliation from the base upward",
                  ],
                  treatment: [
                    "Apply chlorothalonil or copper fungicides",
                    "Prune lower leaves",
                    "Clean up garden debris",
                  ],
                  organic: [
                    "Copper hydroxide sprays",
                    "Thick mulching",
                    "Compost tea foliar sprays",
                  ],
                  prevention: [
                    "Apply a thick layer of organic mulch",
                    "Prune lower branches",
                    "Avoid overhead watering",
                    "Rotate crops annually",
                  ],
                  recoveryTime: "Approximately 3 to 5 weeks for foliage regeneration.",
                  tips: "Inspect lower leaves weekly. Pruning the lowest leaves as the plant grows prevents soil-dwelling spores from splashing up.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Spider Mites (Two-spotted Spider Mite)",
                  scientificName: "Tetranychus urticae",
                  overview: "Two-spotted spider mites are tiny arachnids that suck cell sap from tomato leaves, causing yellow stippling and fine webbing. They thrive and multiply exponentially in hot, dry weather.",
                  causes: [
                    "Tetranychus urticae mites",
                    "Hot and dry weather conditions",
                    "Dusty environments",
                    "Insecticide overuse killing natural predators",
                  ],
                  symptoms: [
                    "Fine yellow stippling on leaves",
                    "Dusty bronze or yellow leaves",
                    "Fine webbing on stems and undersides of leaves",
                    "Leaf drop",
                  ],
                  treatment: [
                    "Apply abamectin or spiromesifen miticides",
                    "Spray leaves with high-pressure water to knock mites off",
                  ],
                  organic: [
                    "Insecticidal soaps",
                    "Neem oil sprays",
                    "Release predatory mites (Phytoseiulus persimilis)",
                    "Horticultural oils",
                  ],
                  prevention: [
                    "Keep plants well-watered to reduce stress",
                    "Control dust on paths",
                    "Preserve natural predatory insects",
                  ],
                  recoveryTime: "Approximately 2 to 3 weeks if mite population is suppressed early.",
                  tips: "Inspect leaf undersides weekly for tiny moving dots during hot, dry spells. A magnifying glass helps detect early webbing.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Target Spot",
                  scientificName: "Corynespora cassiicola",
                  overview: "Target spot is a fungal disease that causes circular spots with distinct concentric rings on leaves, stems, and fruit. It is favored by warm, humid weather and wet leaves.",
                  causes: [
                    "Corynespora cassiicola fungus",
                    "Warm and highly humid conditions",
                    "Leaves remaining wet for long periods",
                  ],
                  symptoms: [
                    "Circular dark brown spots with concentric ring targets",
                    "Leaf yellowing",
                    "Dark pitted circular spots on fruit",
                  ],
                  treatment: [
                    "Spray azoxystrobin or chlorothalonil fungicides",
                    "Prune density to allow drying",
                    "Destroy infected debris",
                  ],
                  organic: [
                    "Copper hydroxide fungicides",
                    "Potassium bicarbonate sprays",
                    "Preventive compost tea",
                  ],
                  prevention: [
                    "Choose resistant varieties",
                    "Rotate crops",
                    "Prune lower foliage",
                    "Ensure wide spacing",
                  ],
                  recoveryTime: "Approximately 3 to 5 weeks.",
                  tips: "Check lower leaves weekly during hot, humid summer spells. Fast drying leaves are key to control.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Tomato Yellow Leaf Curl Virus",
                  scientificName: "Tomato yellow leaf curl virus (TYLCV)",
                  overview: "Tomato yellow leaf curl virus is a destructive virus transmitted by silverleaf whiteflies, causing severe stunting, leaf cupping, and yellowing. It severely limits fruit setting if infected early.",
                  causes: [
                    "TYLCV virus",
                    "Silverleaf whiteflies (Bemisia tabaci) vector",
                    "Nearby infected weed hosts",
                  ],
                  symptoms: [
                    "Upward cupping of leaf margins",
                    "Yellowing between leaf veins",
                    "Very small, stunted leaves",
                    "Flower drop and stunted plant growth",
                  ],
                  treatment: [
                    "Remove and destroy infected plants immediately to prevent whitefly transmission",
                    "Use systemic whitefly insecticides on adjacent plants",
                  ],
                  organic: [
                    "Insecticidal soaps",
                    "Neem oil or horticultural oils to suppress whiteflies",
                    "Yellow sticky traps",
                  ],
                  prevention: [
                    "Grow resistant cultivars",
                    "Use reflective row covers",
                    "Control whiteflies from day one",
                    "Maintain weed-free borders",
                  ],
                  recoveryTime: "Irreversible; infected plants do not recover and must be destroyed.",
                  tips: "Monitor fields weekly for tiny whiteflies. Using yellow sticky cards helps catch vector activity early.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Tomato Mosaic Virus",
                  scientificName: "Tomato mosaic virus (ToMV)",
                  overview: "Mosaic virus is a highly stable, infectious virus causing mottled green-and-yellow mosaic patterns on tomato leaves and distorted fruit. It is easily spread by mechanical contact and contaminated tools.",
                  causes: [
                    "Tomato mosaic virus (ToMV) or Tobacco mosaic virus (TMV)",
                    "Mechanical transmission via hands, clothing, or tools",
                    "Infected seed or planting material",
                  ],
                  symptoms: [
                    "Mottled light and dark green mosaic leaf patterns",
                    "Distorted fern-like leaf growth",
                    "Brown internal fruit rot (mosaic blemishes)",
                  ],
                  treatment: [
                    "No chemical cure exists",
                    "Pull and burn infected plants immediately",
                    "Wash hands and tools in non-fat dry milk or disinfectant",
                  ],
                  organic: [
                    "None; strict sanitation and immediate disposal are the only defenses",
                  ],
                  prevention: [
                    "Use certified virus-free seed",
                    "Sanitize pruning tools between plants",
                    "Avoid smoking near tomato plants (TMV can survive in tobacco)",
                  ],
                  recoveryTime: "Irreversible; infected plants must be removed to protect the remaining crop.",
                  tips: "Dip hands and tools in a dry milk solution weekly during pruning. Cleanliness is the only wall against mosaic virus.",
                ),

                const SizedBox(height: 20),

                diseaseCard(
                  title: "Healthy Tomato Leaf",
                  scientificName: "Solanum lycopersicum",
                  overview: "A healthy tomato leaf is compound, deep green, and slightly fuzzy, optimizing gas exchange and sunlight absorption to feed ripening tomatoes.",
                  causes: [
                    "Deep soil watering",
                    "Balanced calcium-rich nutrition",
                    "Consistent pruning",
                    "Proactive insect defense",
                  ],
                  symptoms: [
                    "Sturdy deep green leaves",
                    "No spotting or margins yellowing",
                    "Fuzzy healthy trichomes",
                    "Balanced growth",
                  ],
                  treatment: [
                    "Prune suckers to maintain single-leader or two-leader systems",
                    "Continue watering base of plant",
                    "Apply calcium amendments",
                  ],
                  organic: [
                    "Mulch with organic straw",
                    "Feed with fish emulsion",
                    "Weekly foliar sprays of compost tea",
                  ],
                  prevention: [
                    "Inspect weekly",
                    "Follow strict crop rotation",
                    "Add organic compost to soil",
                  ],
                  recoveryTime: "N/A",
                  tips: "Pinch out small suckers in leaf axils weekly to focus plant energy on main stems and fruit development.",
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