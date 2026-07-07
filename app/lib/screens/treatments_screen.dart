import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/responsive_theme.dart';
import 'dashboard_screen.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFA5D6A7) : const Color(0xFF1B5E20);
    final iconColor = isDark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32);
    final textColor = isDark ? Colors.white : Colors.black87;
    final trailingColor = isDark ? Colors.white70 : Colors.black54;

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

    return ResponsiveScaffold(
      appBar: AppBar(
        title: Text(
          "Treatments Library",
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Container(
          constraints: ResponsiveTheme.isWebLayout(context) ? const BoxConstraints(maxWidth: 900) : null,
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: diseases.length,
            itemBuilder: (context, index) {
              return ResponsiveCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.zero,
                onTap: () {
                  if (index == 0) {
                    DashboardScreen.navigate(
                      context,
                      'apple_diseases',
                      fallbackWidget: const AppleDiseasesScreen(),
                    );
                  }
  
                  if (index == 1) {
                    DashboardScreen.navigate(
                      context,
                      'corn_diseases',
                      fallbackWidget: const CornDiseasesScreen(),
                    );
                  }
  
                  if (index == 2) {
                    DashboardScreen.navigate(
                      context,
                      'grape_diseases',
                      fallbackWidget: const GrapeDiseasesScreen(),
                    );
                  }
  
                  if (index == 3) {
                    DashboardScreen.navigate(
                      context,
                      'peach_diseases',
                      fallbackWidget: const PeachDiseasesScreen(),
                    );
                  }
  
                  if (index == 4) {
                    DashboardScreen.navigate(
                      context,
                      'potato_diseases',
                      fallbackWidget: const PotatoDiseasesScreen(),
                    );
                  }
  
                  if (index == 5) {
                    DashboardScreen.navigate(
                      context,
                      'rice_diseases',
                      fallbackWidget: const RiceDiseasesScreen(),
                    );
                  }
  
                  if (index == 6) {
                    DashboardScreen.navigate(
                      context,
                      'tomato_diseases',
                      fallbackWidget: const TomatoDiseasesScreen(),
                    );
                  }
                },
                child: ListTile(
                  leading: Icon(
                    diseases[index]['icon'] as IconData,
                    color: iconColor,
                    size: 35,
                  ),
                  title: Text(
                    diseases[index]['name'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: trailingColor,
                    size: 16,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
