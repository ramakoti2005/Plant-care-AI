import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = "English";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Language",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          RadioListTile(
            title: const Text("English"),
            value: "English",
            groupValue: selectedLanguage,
            onChanged: (value) {
              setState(() {
                selectedLanguage = value.toString();
              });
            },
          ),
          RadioListTile(
            title: const Text("Hindi"),
            value: "Hindi",
            groupValue: selectedLanguage,
            onChanged: (value) {
              setState(() {
                selectedLanguage = value.toString();
              });
            },
          ),
          RadioListTile(
            title: const Text("Telugu"),
            value: "Telugu",
            groupValue: selectedLanguage,
            onChanged: (value) {
              setState(() {
                selectedLanguage = value.toString();
              });
            },
          ),
          RadioListTile(
            title: const Text("Tamil"),
            value: "Tamil",
            groupValue: selectedLanguage,
            onChanged: (value) {
              setState(() {
                selectedLanguage = value.toString();
              });
            },
          ),
          RadioListTile(
            title: const Text("Kannada"),
            value: "Kannada",
            groupValue: selectedLanguage,
            onChanged: (value) {
              setState(() {
                selectedLanguage = value.toString();
              });
            },
          ),
          RadioListTile(
            title: const Text("Malayalam"),
            value: "Malayalam",
            groupValue: selectedLanguage,
            onChanged: (value) {
              setState(() {
                selectedLanguage = value.toString();
              });
            },
          ),
        ],
      ),
    );
  }
}