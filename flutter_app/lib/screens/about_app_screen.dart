import 'package:flutter/material.dart';
import '../theme/responsive_theme.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool web = ResponsiveTheme.isWebLayout(context);

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text(
          "About App",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: web ? const BoxConstraints(maxWidth: 800) : null,
            child: ResponsiveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(
                      Icons.eco,
                      size: 80,
                      color: ResponsiveTheme.getIconColor(context),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      "Plant Care AI",
                      style: ResponsiveTheme.getHeaderStyle(context, fontSize: 28),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Text(
                      "Version 1.0",
                      style: ResponsiveTheme.getSubHeaderStyle(context, fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "About",
                    style: ResponsiveTheme.getHeaderStyle(context, fontSize: 22),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Plant Care AI is an AI-powered plant disease detection application that helps farmers and plant enthusiasts identify plant diseases and receive treatment recommendations instantly.",
                    style: ResponsiveTheme.getBodyStyle(context, fontSize: 16),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Features",
                    style: ResponsiveTheme.getHeaderStyle(context, fontSize: 22),
                  ),

                  const SizedBox(height: 10),

                  Text("• Plant Disease Detection", style: ResponsiveTheme.getBodyStyle(context)),
                  Text("• Treatment Recommendations", style: ResponsiveTheme.getBodyStyle(context)),
                  Text("• Scan History Tracking", style: ResponsiveTheme.getBodyStyle(context)),
                  Text("• Treatments Library", style: ResponsiveTheme.getBodyStyle(context)),
                  Text("• User Profile Management", style: ResponsiveTheme.getBodyStyle(context)),

                  const SizedBox(height: 25),

                  Text(
                    "Technologies Used",
                    style: ResponsiveTheme.getHeaderStyle(context, fontSize: 22),
                  ),

                  const SizedBox(height: 10),

                  Text("• Flutter", style: ResponsiveTheme.getBodyStyle(context)),
                  Text("• FastAPI", style: ResponsiveTheme.getBodyStyle(context)),
                  Text("• TensorFlow", style: ResponsiveTheme.getBodyStyle(context)),
                  Text("• SQLite", style: ResponsiveTheme.getBodyStyle(context)),

                  const SizedBox(height: 30),

                  Center(
                    child: Text(
                      "© 2026 Plant Care AI",
                      style: ResponsiveTheme.getSubHeaderStyle(context, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}