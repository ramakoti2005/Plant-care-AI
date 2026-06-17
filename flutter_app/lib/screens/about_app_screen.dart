import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "About App",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Center(
                  child: Icon(
                    Icons.eco,
                    size: 80,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 20),

                Center(
                  child: Text(
                    "Plant Care AI",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 10),

                Center(
                  child: Text(
                    "Version 1.0",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),

                SizedBox(height: 25),

                Text(
                  "About",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  "Plant Care AI is an AI-powered plant disease detection application that helps farmers and plant enthusiasts identify plant diseases and receive treatment recommendations instantly.",
                  style: TextStyle(fontSize: 16),
                ),

                SizedBox(height: 25),

                Text(
                  "Features",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10),

                Text("• Plant Disease Detection"),
                Text("• Treatment Recommendations"),
                Text("• Scan History Tracking"),
                Text("• Treatments Library"),
                Text("• User Profile Management"),

                SizedBox(height: 25),

                Text(
                  "Technologies Used",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10),

                Text("• Flutter"),
                Text("• FastAPI"),
                Text("• TensorFlow"),
                Text("• SQLite"),

                SizedBox(height: 30),

                Center(
                  child: Text(
                    "© 2026 Plant Care AI",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}