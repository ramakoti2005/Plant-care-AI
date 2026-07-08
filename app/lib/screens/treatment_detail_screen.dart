import 'package:flutter/material.dart';
import '../theme/responsive_theme.dart';

class TreatmentDetailScreen extends StatelessWidget {
  final String diseaseName;

  const TreatmentDetailScreen({
    super.key,
    required this.diseaseName,
  });

  // Repository matching disease names to their details
  static final Map<String, Map<String, dynamic>> diseaseDataRepository = {
    // APPLE
    'Apple Scab': {
      'scientificName': 'Venturia inaequalis',
      'overview': 'Apple scab is a major fungal disease affecting apple trees, causing olive-green to black velvety lesions on leaves and cracked surfaces on fruit, leading to defoliation.',
      'symptoms': '• Olive-green to black spots on leaves\n• Velvet-like texture on fruit lesions\n• Premature leaf drop',
      'treatment': '• Apply Captan or Mancozeb fungicide sprays\n• Prune lower branches to improve air circulation\n• Destroy fallen leaves in autumn',
    },
    'Black Rot': {
      'scientificName': 'Botryosphaeria obtusa',
      'overview': 'Black rot causes frogeye leaf spots, cankers on limbs, and a distinct sepia-colored rotting on the fruit that eventually turns completely dark and shriveled.',
      'symptoms': '• Purple margin spots with light centers on leaves\n• Sunken, reddish-brown bark cankers\n• Black, mummified fruit remaining on the tree',
      'treatment': '• Cut out infected cankers during winter pruning\n• Apply fixed copper sprays early in the season\n• Remove all infected fruit debris immediately',
    },
    'Cedar Apple Rust': {
      'scientificName': 'Gymnosporangium juniperi-virginianae',
      'overview': 'A destructive dual-host fungal infection that creates brilliant, fiery orange-yellow circular spots on apple foliage and fruit, heavily reducing tree vigor.',
      'symptoms': '• Bright yellow-orange spots on upper leaf surfaces\n• Small black fruiting bodies inside the orange rings\n• Tube-like structures on the leaf undersides',
      'treatment': '• Plant rust-resistant apple cultivars\n• Apply Myclobutanil fungicides as buds break\n• Remove nearby ornamental cedar/juniper hosts if possible',
    },
    'Healthy Apple Leaf': {
      'scientificName': 'Malus domestica (Healthy)',
      'overview': 'The foliage displays optimal vigor with no active signs of pathogenic fungal spotting, bacterial lesions, or insect vector damage.',
      'symptoms': '• Consistent rich green coloration\n• Smooth, unbroken leaf margins\n• Firm, uniform leaf tissue structure',
      'treatment': '• Maintain standard seasonal watering schedules\n• Apply balanced organic nitrogen fertilizer in spring\n• Monitor routinely for early pest indicators',
    },
    // CORN
    'Common Rust': {
      'scientificName': 'Puccinia sorghi',
      'overview': 'Common rust is a fungal disease that affects corn leaves, producing powdery golden-brown pustules. It thrives in moderate temperatures and high humidity, spreading via windborne spores.',
      'symptoms': '• Small, powdery cinnamon-brown pustules on both leaf surfaces\n• Leaf yellowing around pustules\n• Premature leaf death in severe cases',
      'treatment': '• Apply chlorothalonil or strobilurin fungicides\n• Remove and destroy crop residues after harvest',
    },
    'Gray Leaf Spot': {
      'scientificName': 'Cercospora zeae-maydis',
      'overview': 'Gray leaf spot is a persistent fungal disease characterized by rectangular, gray-to-brown spots on corn leaves. It overwinters in crop residues and can cause severe blighting under warm, moist conditions.',
      'symptoms': '• Rectangular brown/gray lesions bounded by leaf veins\n• Pale green halos around young spots\n• Extensive leaf blighting',
      'treatment': '• Apply triazole or strobilurin fungicides\n• Practice crop rotation (non-host crops for 2 years)',
    },
    'Northern Leaf Blight': {
      'scientificName': 'Exserohilum turcicum',
      'overview': 'Northern leaf blight produces large, cigar-shaped grayish-green lesions on corn leaves. It causes rapid tissue death under moderate, humid conditions and is highly damaging during the grain-fill stage.',
      'symptoms': '• Long, elliptical cigar-shaped grayish-green lesions\n• Pale green halos around mature spots\n• Defoliation and premature leaf death',
      'treatment': '• Apply Tricyclazole or Azoxystrobin fungicides\n• Rotate crops and reduce crop residue',
    },
    'Healthy Corn Leaf': {
      'scientificName': 'Zea mays (Healthy)',
      'overview': 'A healthy corn leaf is wide, vibrant green, and fully functional, supporting carbohydrate storage and photosynthesis.',
      'symptoms': '• Uniform green coloration\n• Clean leaf surfaces with no spots\n• Strong, thick midrib',
      'treatment': '• Apply nitrogen fertilizers at key development stages\n• Ensure consistent field watering\n• Clean fields after crop cycles',
    },
    // GRAPE
    'Grape Black Rot': {
      'scientificName': 'Guignardia bidwellii',
      'overview': 'Black rot is a highly destructive fungal disease affecting all green parts of grapevines, turning berries into hard, shriveled black mummies. It thrives in warm, wet conditions during early shoot growth.',
      'symptoms': '• Small brown circular leaf lesions with dark borders\n• Black dots (pycnidia) inside spots\n• Shriveled rotting berries covered in black pimples',
      'treatment': '• Apply Mancozeb, Captan, or Myclobutanil fungicides\n• Prune out mummified berries and cankered canes',
    },
    'Esca (Black Measles)': {
      'scientificName': 'Phaeomoniella chlamydospora',
      'overview': 'Esca is a complex wood-rotting disease affecting grapevine vascular tissue, causing distinctive "tiger-stripe" leaf patterns and dark spots on berries. It enters via winter pruning wounds.',
      'symptoms': '• Tiger-stripe leaf yellowing and necrosis\n• Small dark purple spots on fruit ("measles")\n• Vascular streaking in vine wood',
      'treatment': '• Apply protective wound paint after winter pruning\n• Prune out dead cordons and trunks\n• Replace severely affected vines',
    },
    'Leaf Blight': {
      'scientificName': 'Pseudocercospora vitis',
      'overview': 'Leaf blight causes dark brown, angular necrotic lesions on grapevine leaves, leading to premature yellowing and defoliation. It spreads via wind and rain splash in late summer.',
      'symptoms': '• Dark brown angular leaf spots\n• premature yellowing and leaf fall\n• Shriveled leaf margins',
      'treatment': '• Apply copper-based fungicides\n• Prune lower leaves to reduce moisture levels',
    },
    'Healthy Grape Leaf': {
      'scientificName': 'Vitis vinifera (Healthy)',
      'overview': 'Foliage is broad, vibrant green, and robust with active photosynthesis supporting high-quality grape clusters.',
      'symptoms': '• Flat, wide leaves with no curling\n• Consistent green veins\n• Clean leaf margins',
      'treatment': '• Maintain trellis pruning structures\n• Spray preventive organic solutions like compost tea\n• Keep canopy open to direct sunlight',
    },
    // PEACH
    'Bacterial Spot': {
      'scientificName': 'Xanthomonas arboricola pv. pruni',
      'overview': 'Bacterial Spot is a bacterial disease that affects peach leaves and fruits. It spreads rapidly during warm and wet weather and can reduce both fruit quality and yield.',
      'symptoms': '• Small dark spots on leaves\n• Yellowing around lesions\n• Holes in leaves\n• Sunken spots on fruits',
      'treatment': '• Remove infected leaves and fruits\n• Avoid overhead irrigation\n• Apply copper-based bactericides',
    },
    'Healthy Peach Leaf': {
      'scientificName': 'Prunus persica (Healthy)',
      'overview': 'A healthy peach leaf is vibrant green, firm, and free of spots or holes.',
      'symptoms': '• Smooth green surface\n• No spots or margin necrosis\n• Sturdy petiole',
      'treatment': '• Maintain standard watering and pruning\n• Apply compost and mulch around base',
    },
    // POTATO
    'Early Blight': {
      'scientificName': 'Alternaria solani',
      'overview': 'Early blight is a fungal disease that targets leaves, creating concentric dark brown circular targets ("bullseye" pattern). It spreads rapidly in alternating wet and dry conditions in summer.',
      'symptoms': '• Concentric ring brown spots on older leaves\n• Yellowing tissue surrounding spots\n• Early leaf defoliation',
      'treatment': '• Apply chlorothalonil, mancozeb, or strobilurin fungicides\n• Practice crop rotation (avoid Solanaceous crops for 3 years)',
    },
    'Late Blight': {
      'scientificName': 'Phytophthora infestans',
      'overview': 'Late blight is a highly destructive oomycete disease that destroys potato leaves and rots tubers. It spreads extremely rapidly in cool, wet weather.',
      'symptoms': '• Outer leaf spots turning dark brown to black\n• White fuzzy growth underneath leaves in wet weather\n• Smelly dark rotting stems and tubers',
      'treatment': '• Apply protective chlorothalonil or copper fungicides immediately\n• Kill vines if disease is severe to protect tubers',
    },
    'Healthy Potato Leaf': {
      'scientificName': 'Solanum tuberosum (Healthy)',
      'overview': 'A healthy potato leaf is wide, compound, and lush green, providing the energetic resources to form starch-filled tubers underground.',
      'symptoms': '• Flat, broad dark green leaves\n• Clean green stems\n• Firm leaf texture',
      'treatment': '• Provide deep weekly watering\n• Inspect leaves regularly for early blight targets',
    },
    // RICE
    'Brown Spot': {
      'scientificName': 'Cochliobolus miyabeanus',
      'overview': 'Brown spot is a fungal disease affecting rice leaves, glumes, and grains, characterized by small oval-to-circular brown lesions. It is highly associated with nutrient-deficient, poorly drained soil.',
      'symptoms': '• Small brown circular/oval spots on leaves\n• Gray or light brown centers in mature spots\n• Black spots on grains',
      'treatment': '• Apply silicon-containing fertilizers\n• Apply triazole or strobilurin fungicides\n• Improve soil fertility and nutrient balance',
    },
    'Leaf Blast': {
      'scientificName': 'Magnaporthe oryzae',
      'overview': 'Leaf blast is a devastating fungal disease of rice that produces spindle-shaped lesions with gray centers on foliage. It spreads quickly during warm, humid conditions with cool nights.',
      'symptoms': '• Spindle-shaped (diamond-shaped) leaf lesions\n• Gray/white centers with reddish-brown borders\n• Leaf drying and premature death',
      'treatment': '• Apply Tricyclazole or Azoxystrobin fungicides\n• Reduce nitrogen fertilizer application\n• Keep fields properly flooded',
    },
    'Neck Blast': {
      'scientificName': 'Magnaporthe oryzae (Neck)',
      'overview': 'Neck blast occurs when the blast fungus attacks the neck node at the base of the rice panicle, causing the panicle to fall over and turn gray. This phase of blast is highly destructive, causing complete grain loss.',
      'symptoms': '• Greyish-brown discoloration at the neck node\n• Rotting of the node structure\n• Panicle falls over (lodging) and grains remain empty',
      'treatment': '• Apply systemic fungicides like Tricyclazole at early panicle emergence\n• Avoid late nitrogen applications',
    },
    'Healthy Rice Leaf': {
      'scientificName': 'Oryza sativa (Healthy)',
      'overview': 'A healthy rice leaf is long, upright, and green, absorbing sunlight efficiently to yield full, healthy panicles.',
      'symptoms': '• Straight, clean green blades\n• No spots, streaks or discoloration\n• Firm structure',
      'treatment': '• Manage water level based on growth stages\n• Ensure balanced nitrogen and potassium fertilization',
    },
    // TOMATO
    'Tomato Bacterial Spot': {
      'scientificName': 'Xanthomonas campestris pv. vesicatoria',
      'overview': 'Bacterial spot is a common disease of tomatoes causing dark, water-soaked spots on leaves and fruit. It is highly contagious during humid, warm rainy seasons.',
      'symptoms': '• Small, water-soaked dark spots on leaves\n• Spots expand and turn brown/black\n• Fruit lesions with scabby centers',
      'treatment': '• Spray copper fungicides mixed with mancozeb\n• Remove and destroy infected plant parts',
    },
    'Tomato Early Blight': {
      'scientificName': 'Alternaria solani',
      'overview': 'Early blight is a fungal disease targeting tomato leaves and stems, forming dark concentric targets that progress from bottom to top.',
      'symptoms': '• Concentric ring spots on lower leaves\n• Leaf yellowing and defoliation\n• Canker lesions on stems',
      'treatment': '• Apply chlorothalonil or copper-based sprays\n• Prune lower branches to keep foliage dry',
    },
    'Tomato Late Blight': {
      'scientificName': 'Phytophthora infestans',
      'overview': 'A highly destructive oomycete that attacks tomatoes in cool, wet weather, causing large greasy spots and fuzzy mold.',
      'symptoms': '• Large dark greasy lesions on leaves\n• White fuzzy mold under leaves in high humidity\n• Brown leathery spots on green fruit',
      'treatment': '• Apply copper-based fungicides immediately\n• Clear and burn all crop residue',
    },
    'Leaf Mold': {
      'scientificName': 'Passalora fulva',
      'overview': 'Leaf mold affects tomato foliage grown in high humidity environments, causing olive-green velvety mold on leaf undersides.',
      'symptoms': '• Pale green/yellow spots on upper leaf surface\n• Olive-green velvety mold growth underneath\n• Premature leaf drop',
      'treatment': '• Apply copper or chlorothalonil fungicides\n• Improve ventilation and keep humidity low',
    },
    'Septoria Leaf Spot': {
      'scientificName': 'Septoria lycopersici',
      'overview': 'Septoria leaf spot is a fungal disease producing numerous small circular spots with grey centers on tomato leaves.',
      'symptoms': '• Numerous small spots with dark margins and grey centers\n• Yellowing around lesions\n• Leaf defoliation starting at base',
      'treatment': '• Apply copper fungicides weekly\n• Mulch around plant base to prevent soil splash',
    },
    'Spider Mites (Two-spotted spider mite)': {
      'scientificName': 'Tetranychus urticae',
      'overview': 'Spider mites are tiny pests that suck leaf sap from tomatoes, producing fine webbing and leaf stippling.',
      'symptoms': '• Yellow/white stippling dots on leaf surfaces\n• Fine webbing on leaf undersides and stems\n• Leaves turn bronze and dry up',
      'treatment': '• Spray with insecticidal soaps or neem oil\n• Introduce predatory mites (phytoseiulus)',
    },
    'Target Spot': {
      'scientificName': 'Corynespora cassiicola',
      'overview': 'Target spot is a fungal disease causing circular spots with target-like rings on tomato leaves and fruit.',
      'symptoms': '• Circular spots with distinct concentric rings\n• Spots merge causing large dead patches\n• Sunken spots on fruit',
      'treatment': '• Apply mancozeb or chlorothalonil sprays\n• Maintain weed-free fields to improve air flow',
    },
    'Tomato Yellow Leaf Curl Virus': {
      'scientificName': 'Tomato yellow leaf curl virus (TYLCV)',
      'overview': 'A viral disease transmitted by silverleaf whiteflies, causing severe stunting and leaf cupping.',
      'symptoms': '• Leaves cup upwards and turn pale yellow\n• Severe stunting of new growth\n• Complete failure to set fruit',
      'treatment': '• Control whitefly vector using insecticidal soaps\n• Remove and destroy infected plants',
    },
    'Tomato Mosaic Virus': {
      'scientificName': 'Tomato mosaic virus (ToMV)',
      'overview': 'A highly contagious viral pathogen causing mosaic patterns and leaf distortion.',
      'symptoms': '• Light and dark green mottled mosaic leaf pattern\n• Fern-like leaf distortion ("shoestringing")\n• Internal brown necrosis in fruit',
      'treatment': '• Strictly remove and destroy infected plants\n• Disinfect tools with milk or trisodium phosphate',
    },
    'Healthy Tomato Leaf': {
      'scientificName': 'Solanum lycopersicum (Healthy)',
      'overview': 'Foliage shows excellent color and turgidity, with active growth supporting heavy fruit production.',
      'symptoms': '• Consistent green compound leaves\n• No spots, pests, or webbing\n• Sturdy stems',
      'treatment': '• Provide deep consistent watering\n• Apply balanced organic fertilizers\n• Monitor for early pest indicators',
    },
  };

  Widget _buildDetailRow(BuildContext context, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3324) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, String title, String content, IconData icon, Color accentColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3324) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFA5D6A7) : const Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentDisease = diseaseDataRepository[diseaseName] ?? diseaseDataRepository['Apple Scab']!;

    return ResponsiveScaffold(
      appBar: AppBar(
        title: Text(diseaseName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDetailRow(context, "Scientific Name", currentDisease['scientificName'] ?? 'N/A', isDark),
            const SizedBox(height: 16),
            _buildContentCard(context, "Overview", currentDisease['overview'] ?? 'N/A', Icons.info_outline, Colors.blue, isDark),
            _buildContentCard(context, "Symptoms", currentDisease['symptoms'] ?? 'N/A', Icons.healing, Colors.orange, isDark),
            _buildContentCard(context, "Treatment & Action Plan", currentDisease['treatment'] ?? 'N/A', Icons.eco, Colors.green, isDark),
          ],
        ),
      ),
    );
  }
}
