import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'apple_diseases_screen.dart';
import 'corn_diseases_screen.dart';
import 'grape_diseases_screen.dart';
import 'peach_diseases_screen.dart';
import 'potato_diseases_screen.dart';
import 'rice_diseases_screen.dart';
import 'tomato_diseases_screen.dart';

class TreatmentsScreen extends StatelessWidget {
  const TreatmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final diseases = [
      {
        'name': 'Apple Diseases',
        'icon': Icons.apple,
      },
      {
        'name': 'Corn Diseases',
        'icon': Icons.grass,
      },
      {
        'name': 'Grape Diseases',
        'icon': Icons.local_florist,
      },
      {
        'name': 'Peach Diseases',
        'icon': Icons.eco,
      },
      {
        'name': 'Potato Diseases',
        'icon': Icons.eco,
      },
      {
        'name': 'Rice Diseases',
        'icon': Icons.agriculture,
      },
      {
        'name': 'Tomato Diseases',
        'icon': Icons.energy_savings_leaf,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Treatments Library",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          constraints: kIsWeb ? const BoxConstraints(maxWidth: 900) : null,
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: diseases.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    diseases[index]['icon'] as IconData,
                    color: Colors.green,
                    size: 35,
                  ),
                  title: Text(
                    diseases[index]['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                  ),
                  onTap: () {
                    if (index == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AppleDiseasesScreen(),
                        ),
                      );
                    }
    
                    if (index == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CornDiseasesScreen(),
                        ),
                      );
                    }
    
                    if (index == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GrapeDiseasesScreen(),
                        ),
                      );
                    }
    
                    if (index == 3) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PeachDiseasesScreen(),
                        ),
                      );
                    }
    
                    if (index == 4) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PotatoDiseasesScreen(),
                        ),
                      );
                    }
    
                    if (index == 5) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RiceDiseasesScreen(),
                        ),
                      );
                    }
    
                    if (index == 6) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TomatoDiseasesScreen(),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
