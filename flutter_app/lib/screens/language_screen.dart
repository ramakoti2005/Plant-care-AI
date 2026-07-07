import 'package:flutter/material.dart';
import '../theme/responsive_theme.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = "English";

  @override
  Widget build(BuildContext context) {
    final bool web = ResponsiveTheme.isWebLayout(context);
    final languages = ["English", "Hindi", "Telugu", "Tamil", "Kannada", "Malayalam"];

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text(
          "Language",
        ),
      ),
      body: Center(
        child: Container(
          constraints: web ? const BoxConstraints(maxWidth: 800) : null,
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final lang = languages[index];
              return ResponsiveCard(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(bottom: 12),
                child: RadioListTile(
                  title: Text(
                    lang,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: web ? Colors.black87 : Colors.white,
                    ),
                  ),
                  value: lang,
                  groupValue: selectedLanguage,
                  activeColor: ResponsiveTheme.getIconColor(context),
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value.toString();
                    });
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