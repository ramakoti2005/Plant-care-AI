import 'package:flutter/material.dart';
import 'about_app_screen.dart';
import 'language_screen.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: [

          SwitchListTile(
            title: const Text("Notifications"),
            value: notifications,
            onChanged: (value){
              setState(() {
                notifications = value;
              });
            },
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About App"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AboutAppScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Language"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LanguageScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text("Change Password"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChangePasswordScreen(),
                ),
              );
            },
          ),

        ],
      ),
    );
  }
}