import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../theme/responsive_theme.dart';
import 'dashboard_screen.dart';
import 'about_app_screen.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Clear cache confirmation dialog
  void _showClearCacheDialog(SettingsService settings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text("Clear Cache Request", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            "Are you sure you want to clear ${settings.cacheSizeMB.toStringAsFixed(1)} MB of temporary image cache? This cannot be undone.",
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () async {
                await settings.clearCache();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Cache successfully cleared!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Confirm Clear", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool web = ResponsiveTheme.isWebLayout(context);
    final settings = Provider.of<SettingsService>(context);

    final Color textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87;
    final Color subtitleColor = Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.black54;

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
              // --- SECTION: PREFERENCES ---
              _buildSectionHeader("Notification Preferences"),
              ResponsiveCard(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(bottom: 20),
                child: ExpansionTile(
                  leading: Icon(Icons.notifications_active_outlined, color: ResponsiveTheme.getIconColor(context)),
                  title: Text(
                    "Notification Controls",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    "Configure outbreak alerts and care reminders",
                    style: TextStyle(color: subtitleColor, fontSize: 12),
                  ),
                  iconColor: ResponsiveTheme.getIconColor(context),
                  collapsedIconColor: ResponsiveTheme.getIconColor(context),
                  children: [
                    SwitchListTile(
                      title: Text(
                        "Pest & Disease Outbreak Alerts",
                        style: TextStyle(color: textColor, fontSize: 14),
                      ),
                      subtitle: const Text("Get notified of local disease spikes", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      value: settings.outbreakAlerts,
                      activeColor: const Color(0xFF2E7D32),
                      onChanged: (value) async {
                        await settings.setOutbreakAlerts(value);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Outbreak alerts ${value ? 'enabled' : 'disabled'}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                    SwitchListTile(
                      title: Text(
                        "Watering & Care Reminders",
                        style: TextStyle(color: textColor, fontSize: 14),
                      ),
                      subtitle: const Text("Get updates on plant schedule suggestions", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      value: settings.careReminders,
                      activeColor: const Color(0xFF2E7D32),
                      onChanged: (value) async {
                        await settings.setCareReminders(value);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Watering reminders ${value ? 'enabled' : 'disabled'}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              // --- SECTION: SYSTEM THEME & UNITS ---
              _buildSectionHeader("System Configuration"),
              ResponsiveCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    // Theme Selector
                    DropdownButtonFormField<String>(
                      value: settings.selectedTheme,
                      decoration: InputDecoration(
                        labelText: "App Theme",
                        labelStyle: TextStyle(color: subtitleColor),
                        prefixIcon: Icon(Icons.palette_outlined, color: ResponsiveTheme.getIconColor(context)),
                        border: InputBorder.none,
                      ),
                      dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C2D22) : Colors.white,
                      style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
                      items: <String>['Nature Gradient (Light)', 'Midnight Forest (Dark)']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
                        if (newValue != null) {
                          await settings.setSelectedTheme(newValue);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Theme updated to $newValue')),
                            );
                          }
                        }
                      },
                    ),
                    const Divider(height: 20, color: Colors.black12),
                    // Measurement Units Selector
                    DropdownButtonFormField<String>(
                      value: settings.selectedUnit,
                      decoration: InputDecoration(
                        labelText: "Temperature Units",
                        labelStyle: TextStyle(color: subtitleColor),
                        prefixIcon: Icon(Icons.thermostat_outlined, color: ResponsiveTheme.getIconColor(context)),
                        border: InputBorder.none,
                      ),
                      dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C2D22) : Colors.white,
                      style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
                      items: <String>['Celsius (°C)', 'Fahrenheit (°F)']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
                        if (newValue != null) {
                          await settings.setSelectedUnit(newValue);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Measurement unit changed to $newValue')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),

              // --- SECTION: STORAGE & LOCAL DATA ---
              _buildSectionHeader("Storage Management"),
              ResponsiveCard(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(bottom: 20),
                child: ListTile(
                  leading: Icon(Icons.storage_outlined, color: ResponsiveTheme.getIconColor(context)),
                  title: Text(
                    "Local Data Cache",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    "Cache Size: ${settings.cacheSizeMB.toStringAsFixed(1)} MB",
                    style: TextStyle(color: subtitleColor, fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                    tooltip: "Clear Cache",
                    onPressed: settings.cacheSizeMB > 0 ? () => _showClearCacheDialog(settings) : null,
                  ),
                ),
              ),

              // --- SECTION: ACCOUNT & INFO ---
              _buildSectionHeader("Account & About"),
              ResponsiveCard(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(Icons.lock_reset, color: ResponsiveTheme.getIconColor(context)),
                  title: Text(
                    "Change Password",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
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
              ResponsiveCard(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(Icons.info_outline, color: ResponsiveTheme.getIconColor(context)),
                  title: Text(
                    "About App",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D32),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}