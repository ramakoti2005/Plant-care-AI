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
  // State variables for preferences
  bool _outbreakAlerts = true;
  bool _careReminders = false;
  String _selectedTheme = 'Nature Gradient (Light)';
  String _selectedUnit = 'Celsius (°C)';
  double _cacheSizeMB = 14.2;

  // Clear cache confirmation dialog
  void _showClearCacheDialog() {
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
            "Are you sure you want to clear ${_cacheSizeMB.toStringAsFixed(1)} MB of temporary image cache? This cannot be undone.",
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _cacheSizeMB = 0.0;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Cache successfully cleared!"),
                    backgroundColor: Colors.green,
                  ),
                );
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
    final Color textColor = web ? Colors.black87 : Colors.white;
    final Color subtitleColor = web ? Colors.black54 : Colors.white70;

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
                      value: _outbreakAlerts,
                      activeColor: const Color(0xFF2E7D32),
                      onChanged: (value) {
                        setState(() {
                          _outbreakAlerts = value;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Outbreak alerts ${_outbreakAlerts ? 'enabled' : 'disabled'}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    SwitchListTile(
                      title: Text(
                        "Watering & Care Reminders",
                        style: TextStyle(color: textColor, fontSize: 14),
                      ),
                      subtitle: const Text("Get updates on plant schedule suggestions", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      value: _careReminders,
                      activeColor: const Color(0xFF2E7D32),
                      onChanged: (value) {
                        setState(() {
                          _careReminders = value;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Watering reminders ${_careReminders ? 'enabled' : 'disabled'}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
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
                      value: _selectedTheme,
                      decoration: InputDecoration(
                        labelText: "App Theme",
                        labelStyle: TextStyle(color: subtitleColor),
                        prefixIcon: Icon(Icons.palette_outlined, color: ResponsiveTheme.getIconColor(context)),
                        border: InputBorder.none,
                      ),
                      dropdownColor: web ? Colors.white : const Color(0xFF2C3E2F),
                      style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
                      items: <String>['Nature Gradient (Light)', 'Midnight Forest (Dark)']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedTheme = newValue;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Theme updated to $_selectedTheme')),
                          );
                        }
                      },
                    ),
                    const Divider(height: 20, color: Colors.black12),
                    // Measurement Units Selector
                    DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: InputDecoration(
                        labelText: "Temperature Units",
                        labelStyle: TextStyle(color: subtitleColor),
                        prefixIcon: Icon(Icons.thermostat_outlined, color: ResponsiveTheme.getIconColor(context)),
                        border: InputBorder.none,
                      ),
                      dropdownColor: web ? Colors.white : const Color(0xFF2C3E2F),
                      style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
                      items: <String>['Celsius (°C)', 'Fahrenheit (°F)']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedUnit = newValue;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Measurement unit changed to $_selectedUnit')),
                          );
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
                    "Cache Size: ${_cacheSizeMB.toStringAsFixed(1)} MB",
                    style: TextStyle(color: subtitleColor, fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                    tooltip: "Clear Cache",
                    onPressed: _cacheSizeMB > 0 ? _showClearCacheDialog : null,
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
                  leading: Icon(Icons.language, color: ResponsiveTheme.getIconColor(context)),
                  title: Text(
                    "Language",
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