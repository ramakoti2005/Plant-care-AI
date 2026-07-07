import 'package:flutter/material.dart';
import '../theme/responsive_theme.dart';
import 'dashboard_screen.dart';
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
    final bool web = ResponsiveTheme.isWebLayout(context);

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Center(
        child: Container(
          constraints: web ? const BoxConstraints(maxWidth: 800) : null,
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              ResponsiveCard(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(bottom: 12),
                child: SwitchListTile(
                  title: Text(
                    "Notifications",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: web ? Colors.black87 : Colors.white,
                    ),
                  ),
                  value: notifications,
                  activeColor: ResponsiveTheme.getIconColor(context),
                  onChanged: (value) {
                    setState(() {
                      notifications = value;
                    });
                  },
                ),
              ),
              ResponsiveCard(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(Icons.info, color: ResponsiveTheme.getIconColor(context)),
                  title: Text(
                    "About App",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: web ? Colors.black87 : Colors.white,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right, color: ResponsiveTheme.getIconColor(context)),
                  onTap: () {
                    DashboardScreen.navigate(
                      context,
                      'custom',
                      fallbackWidget: const AboutAppScreen(),
                      customWidget: const AboutAppScreen(),
                    );
                  },
                ),
              ),
              ResponsiveCard(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(Icons.language, color: ResponsiveTheme.getIconColor(context)),
                  title: Text(
                    "Language",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: web ? Colors.black87 : Colors.white,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right, color: ResponsiveTheme.getIconColor(context)),
                  onTap: () {
                    DashboardScreen.navigate(
                      context,
                      'custom',
                      fallbackWidget: const LanguageScreen(),
                      customWidget: const LanguageScreen(),
                    );
                  },
                ),
              ),
              ResponsiveCard(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(Icons.lock_reset, color: ResponsiveTheme.getIconColor(context)),
                  title: Text(
                    "Change Password",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: web ? Colors.black87 : Colors.white,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right, color: ResponsiveTheme.getIconColor(context)),
                  onTap: () {
                    DashboardScreen.navigate(
                      context,
                      'change_password',
                      fallbackWidget: const ChangePasswordScreen(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}