import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  double _currentTempC = 28.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentTemperature();
  }

  Future<void> _loadCurrentTemperature() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _currentTempC = prefs.getDouble('current_temperature_c') ?? 28.0;
        });
      }
    } catch (_) {}
  }

  void _showClearCacheDialog() {
    final settings = Provider.of<SettingsService>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Clear Local App Cache?"),
          content: Text("Are you sure you want to delete ${settings.cacheSizeMB.toStringAsFixed(1)} MB of temporary scanned leaf storage? This action cannot be undone."),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Yes, Clear Data"),
              onPressed: () {
                Provider.of<SettingsService>(context, listen: false).clearCache();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("App cache successfully cleared! 🧹")),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final bool web = ResponsiveTheme.isWebLayout(context);
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
              // --- A. Notification Sub-Menu Splitter ---
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
                      onChanged: (value) {
                        Provider.of<SettingsService>(context, listen: false).setOutbreakAlerts(value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Alert preference updated!")),
                        );
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
                      onChanged: (value) {
                        Provider.of<SettingsService>(context, listen: false).setCareReminders(value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Alert preference updated!")),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // --- B. Premium Theme Dropdown & C. Regional Measurement Units Toggle ---
              _buildSectionHeader("System Configuration"),
              ResponsiveCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    // Theme Selector Dropdown
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
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          Provider.of<SettingsService>(context, listen: false).setSelectedTheme(newValue);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Theme changed to $newValue!")),
                          );
                        }
                      },
                    ),
                    const Divider(height: 20, color: Colors.black12),
                    // Measurement Units Selector Dropdown
                    DropdownButtonFormField<String>(
                      value: settings.selectedUnit,
                      decoration: InputDecoration(
                        labelText: "Temperature Units",
                        labelStyle: TextStyle(color: subtitleColor),
                        prefixIcon: Icon(Icons.thermostat_outlined, color: ResponsiveTheme.getIconColor(context)),
                        border: InputBorder.none,
                        helperText: settings.selectedUnit == 'Fahrenheit (°F)' 
                            ? "Current Garden Temperature: ${((_currentTempC * 9 / 5) + 32).toStringAsFixed(1)}°F" 
                            : "Current Garden Temperature: ${_currentTempC.toStringAsFixed(1)}°C",
                        helperStyle: TextStyle(color: subtitleColor, fontSize: 12),
                      ),
                      dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C2D22) : Colors.white,
                      style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
                      items: <String>['Celsius (°C)', 'Fahrenheit (°F)']
                          .map<DropdownMenuItem<String>>((String value) {
                        final displayVal = value == 'Celsius (°C)' 
                            ? 'Celsius (°C) [${_currentTempC.toStringAsFixed(1)}°C]' 
                            : 'Fahrenheit (°F) [${((_currentTempC * 9 / 5) + 32).toStringAsFixed(1)}°F]';
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(displayVal),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          Provider.of<SettingsService>(context, listen: false).setSelectedUnit(newValue);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Measurement unit changed to $newValue')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              // --- D. Cache Cleaner (App Cache & Storage Data) ---
              _buildSectionHeader("Storage Management"),
              ResponsiveCard(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(bottom: 20),
                child: ListTile(
                  leading: Icon(Icons.storage_outlined, color: ResponsiveTheme.getIconColor(context)),
                  title: const Text(
                    "App Cache & Storage Data",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Local Storage Cache: ${settings.cacheSizeMB.toStringAsFixed(1)} MB",
                    style: TextStyle(color: subtitleColor, fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                    tooltip: "Clear Cache",
                    onPressed: settings.cacheSizeMB > 0 ? _showClearCacheDialog : null,
                  ),
                ),
              ),

              // --- ACCOUNT & ABOUT ---
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