import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../theme/responsive_theme.dart';
import 'screens.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();

  // Static navigation helper method for embedded view switching
  static void navigate(BuildContext context, String page, {Widget? fallbackWidget, Widget? customWidget}) {
    final state = context.findAncestorStateOfType<DashboardScreenState>();
    if (state != null) {
      state.setPage(page, customWidget: customWidget);
    } else if (fallbackWidget != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => fallbackWidget));
    }
  }
}

class DashboardScreenState extends State<DashboardScreen> {
  String activePage = 'dashboard';
  Widget? customWidget;

  String _locationName = "Thandalam, Tamil Nadu";
  double _temperatureC = 28.0;
  int _humidity = 65;
  bool _isClimateLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchLocationAndWeather();
  }

  Future<void> _fetchLocationAndWeather() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _loadFallbackProfileLocation();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      final Map<String, String> headers = {};
      if (!kIsWeb) {
        headers['User-Agent'] = 'PlantCareAI/1.0';
      }

      final geoResponse = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1'),
        headers: headers,
      );

      String resolvedLocation = _locationName;
      if (geoResponse.statusCode == 200) {
        final data = json.decode(geoResponse.body);
        final address = data['address'];
        if (address != null) {
          final String city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'] ?? address['suburb'] ?? "Unknown City";
          final String state = address['state'] ?? address['region'] ?? "";
          final String country = address['country'] ?? "";
          resolvedLocation = state.isNotEmpty ? "$city, $state" : "$city, $country";
        }
      }

      final weatherResponse = await http.get(
        Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,relative_humidity_2m'),
      );

      double resolvedTemp = _temperatureC;
      int resolvedHumidity = _humidity;
      if (weatherResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);
        final current = weatherData['current'];
        if (current != null) {
          resolvedTemp = (current['temperature_2m'] as num).toDouble();
          resolvedHumidity = (current['relative_humidity_2m'] as num).toInt();
        }
      }

      if (mounted) {
        setState(() {
          _locationName = resolvedLocation;
          _temperatureC = resolvedTemp;
          _humidity = resolvedHumidity;
          _isClimateLoaded = true;
        });
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('current_temperature_c', resolvedTemp);
      } catch (e) {
        debugPrint("Error saving current temperature to prefs: $e");
      }
    } catch (e) {
      debugPrint("Error fetching location/weather: $e");
      _loadFallbackProfileLocation();
    }
  }

  Future<void> _loadFallbackProfileLocation() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      String? token = authService.token;
      if (token != null && token.isNotEmpty) {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['location'] != null && data['location'].toString().isNotEmpty) {
            setState(() {
              _locationName = data['location'];
            });
          }
        }
      }
    } catch (_) {}
  }

  void setPage(String page, {Widget? customWidget}) {
    setState(() {
      activePage = page;
      this.customWidget = customWidget;
    });
  }

  void _onPageSelected(String page) {
    setState(() {
      activePage = page;
      customWidget = null;
    });
  }

  Widget _buildComingSoonPage(BuildContext context, String title, IconData icon) {
    return ResponsiveScaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          padding: const EdgeInsets.all(24),
          child: ResponsiveCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 64, color: ResponsiveTheme.getIconColor(context)),
                const SizedBox(height: 16),
                Text(
                  "$title Library",
                  style: ResponsiveTheme.getHeaderStyle(context, fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  "This section is currently under development. Check back soon for exciting new features!",
                  textAlign: TextAlign.center,
                  style: ResponsiveTheme.getSubHeaderStyle(context, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getScreenByPage(String page) {
    switch (page) {
      case 'scan_plant': return const ScanPlantScreen();
      case 'history': return const HistoryScreen();
      case 'treatments': return const TreatmentsScreen();
      case 'profile': return const ProfileScreen();
      case 'settings': return const SettingsScreen();
      case 'change_password': return const ChangePasswordScreen();
      case 'apple_diseases': return const AppleDiseasesScreen();
      case 'corn_diseases': return const CornDiseasesScreen();
      case 'grape_diseases': return const GrapeDiseasesScreen();
      case 'peach_diseases': return const PeachDiseasesScreen();
      case 'potato_diseases': return const PotatoDiseasesScreen();
      case 'rice_diseases': return const RiceDiseasesScreen();
      case 'tomato_diseases': return const TomatoDiseasesScreen();
      case 'my_plants': return _buildComingSoonPage(context, "My Plants", Icons.local_florist);
      case 'analytics': return _buildComingSoonPage(context, "Analytics", Icons.analytics);
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveTheme.isWebLayout(context);

    // Resolve current selected page body
    Widget currentSelectedPage;
    String pageTitle;

    switch (activePage) {
      case 'scan_plant':
        currentSelectedPage = const ScanPlantScreen();
        pageTitle = 'Scan Plant';
        break;
      case 'history':
        currentSelectedPage = const HistoryScreen();
        pageTitle = 'History';
        break;
      case 'treatments':
        currentSelectedPage = const TreatmentsScreen();
        pageTitle = 'Treatments';
        break;
      case 'profile':
        currentSelectedPage = const ProfileScreen();
        pageTitle = 'Profile';
        break;
      case 'settings':
        currentSelectedPage = const SettingsScreen();
        pageTitle = 'Settings';
        break;
      case 'my_plants':
        currentSelectedPage = _buildComingSoonPage(context, "My Plants", Icons.local_florist);
        pageTitle = 'My Plants';
        break;
      case 'analytics':
        currentSelectedPage = _buildComingSoonPage(context, "Analytics", Icons.analytics);
        pageTitle = 'Analytics';
        break;
      case 'change_password':
        currentSelectedPage = const ChangePasswordScreen();
        pageTitle = 'Change Password';
        break;
      case 'apple_diseases':
        currentSelectedPage = const AppleDiseasesScreen();
        pageTitle = 'Apple Diseases';
        break;
      case 'corn_diseases':
        currentSelectedPage = const CornDiseasesScreen();
        pageTitle = 'Corn Diseases';
        break;
      case 'grape_diseases':
        currentSelectedPage = const GrapeDiseasesScreen();
        pageTitle = 'Grape Diseases';
        break;
      case 'peach_diseases':
        currentSelectedPage = const PeachDiseasesScreen();
        pageTitle = 'Peach Diseases';
        break;
      case 'potato_diseases':
        currentSelectedPage = const PotatoDiseasesScreen();
        pageTitle = 'Potato Diseases';
        break;
      case 'rice_diseases':
        currentSelectedPage = const RiceDiseasesScreen();
        pageTitle = 'Rice Diseases';
        break;
      case 'tomato_diseases':
        currentSelectedPage = const TomatoDiseasesScreen();
        pageTitle = 'Tomato Diseases';
        break;
      case 'custom':
        currentSelectedPage = customWidget ?? const SizedBox.shrink();
        pageTitle = '';
        break;
      case 'dashboard':
      default:
        currentSelectedPage = _buildDashboardBodyContent(context);
        pageTitle = 'Plant Care AI';
        break;
    }

    if (isDesktop) {
      // 🖥️ Web / Desktop layout with persistent Left Sidebar
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: ResponsiveTheme.getAppBackgroundDecoration(context),
          child: Row(
            children: [
              // Left Sidebar
              SizedBox(
                width: 260,
                child: Drawer(
                  child: buildCustomNavigationDrawerContent(context, isMobile: false),
                ),
              ),
              // Right Content Area
              Expanded(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: activePage == 'dashboard'
                      ? AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
                          title: Text(
                            pageTitle,
                            style: const TextStyle(
                              color: Color(0xFF1B5E20),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          centerTitle: true,
                        )
                      : null, // Sub-pages render their own app bar inside the viewport
                  body: currentSelectedPage,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // 📱 Mobile layout with hamburger menu and sliding drawer
      return ResponsiveScaffold(
        appBar: activePage == 'dashboard'
            ? AppBar(
                title: Text(pageTitle),
              )
            : null,
        drawer: activePage == 'dashboard'
            ? Drawer(
                child: buildCustomNavigationDrawerContent(context, isMobile: true),
              )
            : null,
        body: currentSelectedPage,
      );
    }
  }

  Widget _buildClimateCard(BuildContext context) {
    bool isFahrenheit = false;
    try {
      final settings = Provider.of<SettingsService>(context);
      isFahrenheit = settings.selectedUnit == 'Fahrenheit (°F)';
    } catch (_) {}

    double tempValNum = _temperatureC;
    if (isFahrenheit) {
      tempValNum = (_temperatureC * 9 / 5) + 32;
    }
    final tempVal = isFahrenheit 
        ? "${tempValNum.toStringAsFixed(1)}°F" 
        : "${tempValNum.toStringAsFixed(1)}°C";

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return ResponsiveCard(
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E3525) : const Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.wb_sunny_outlined, color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Local Garden Climate",
                            style: ResponsiveTheme.getHeaderStyle(context, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: isDark ? Colors.white60 : Colors.black54),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _locationName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E3525) : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Optimal",
                        style: TextStyle(color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Temperature: $tempVal",
                        style: ResponsiveTheme.getBodyStyle(context, fontSize: 14).copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Humidity: $_humidity%",
                        style: ResponsiveTheme.getBodyStyle(context, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E3525) : const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.wb_sunny_outlined, color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Local Garden Climate",
                            style: ResponsiveTheme.getHeaderStyle(context, fontSize: 16),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.location_on, size: 14, color: isDark ? Colors.white60 : Colors.black54),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _locationName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "Temperature: $tempVal",
                            style: ResponsiveTheme.getBodyStyle(context, fontSize: 14).copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "Humidity: $_humidity%",
                            style: ResponsiveTheme.getBodyStyle(context, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E3525) : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Optimal",
                    style: TextStyle(color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDashboardBodyContent(BuildContext context) {
    return Center(
      child: Container(
        constraints: ResponsiveTheme.isWebLayout(context) ? const BoxConstraints(maxWidth: 1100) : null,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Leaf Logo Header
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF2E7D32),
                child: Icon(
                  Icons.eco,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Welcome to Plant Care AI",
                style: ResponsiveTheme.getHeaderStyle(context, fontSize: 26),
              ),

              const SizedBox(height: 8),

              Text(
                "AI Powered Plant Disease Detection",
                textAlign: TextAlign.center,
                style: ResponsiveTheme.getSubHeaderStyle(context, fontSize: 16),
              ),

              const SizedBox(height: 30),

              _buildClimateCard(context),

              const SizedBox(height: 25),

              // Dashboard Cards Grid/List Selection
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: ResponsiveTheme.isWebLayout(context) ? 2 : 1,
                childAspectRatio: ResponsiveTheme.isWebLayout(context) ? 3.0 : 2.7,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    icon: Icons.camera_alt,
                    title: "Scan Plant",
                    subtitle: "Upload leaf image for disease detection",
                    onTap: () {
                      DashboardScreen.navigate(
                        context,
                        'scan_plant',
                        fallbackWidget: const ScanPlantScreen(),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.history,
                    title: "History",
                    subtitle: "View previous diagnoses",
                    onTap: () {
                      DashboardScreen.navigate(
                        context,
                        'history',
                        fallbackWidget: const HistoryScreen(),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.medical_services,
                    title: "Treatments",
                    subtitle: "Recommended solutions",
                    onTap: () {
                      DashboardScreen.navigate(
                        context,
                        'treatments',
                        fallbackWidget: const TreatmentsScreen(),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.person,
                    title: "Profile",
                    subtitle: "Manage account settings",
                    onTap: () {
                      DashboardScreen.navigate(
                        context,
                        'profile',
                        fallbackWidget: const ProfileScreen(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final bool web = ResponsiveTheme.isWebLayout(context);
    return ResponsiveCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: web ? 20 : 12,
      ),
      child: Row(
        children: [
          // Leading Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ResponsiveTheme.getIconColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: ResponsiveTheme.getIconColor(context),
              size: 32,
            ),
          ),
          
          const SizedBox(width: 20),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: ResponsiveTheme.getHeaderStyle(context, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: ResponsiveTheme.getSubHeaderStyle(context, fontSize: 14),
                ),
              ],
            ),
          ),

          // Trailing Arrow
          Icon(
            Icons.arrow_forward_ios,
            color: ResponsiveTheme.getIconColor(context).withOpacity(0.7),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String page,
    required IconData icon,
    required String title,
    required bool isMobile,
  }) {
    final bool isActive = activePage == page;

    Widget listTile = ListTile(
      leading: Icon(
        icon,
        color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () async {
        if (page == 'logout') {
          if (isMobile) {
            Navigator.pop(context);
          }
          try {
            await Provider.of<AuthService>(context, listen: false).logout();
          } catch (_) {}
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          return;
        }
        if (isMobile) {
          Navigator.pop(context);
          if (page != 'dashboard') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => _getScreenByPage(page)),
            );
            return;
          }
        }
        _onPageSelected(page);
      },
    );

    if (isActive) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: listTile,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: listTile,
    );
  }

  Widget buildCustomNavigationDrawerContent(BuildContext context, {required bool isMobile}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: ResponsiveTheme.getSidebarColor(context),
      child: Column(
        children: [
          // Custom Header (Horizontal Layout matching the screenshot)
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.eco, color: ResponsiveTheme.getSidebarColor(context), size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "Plant Care AI",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "AI Powered Plant Disease Detection",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const Divider(color: Colors.white24, height: 1),
          
          // Scrollable Drawer Items
          Expanded(
            child: SingleChildScrollView(
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  unselectedWidgetColor: Colors.white70,
                  colorScheme: const ColorScheme.light(
                    primary: Colors.white,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context,
                      page: 'dashboard',
                      icon: Icons.dashboard_outlined,
                      title: "Dashboard",
                      isMobile: isMobile,
                    ),
                    _buildMenuItem(
                      context,
                      page: 'scan_plant',
                      icon: Icons.camera_alt_outlined,
                      title: "Scan Plant",
                      isMobile: isMobile,
                    ),
                    _buildMenuItem(
                      context,
                      page: 'treatments',
                      icon: Icons.medical_services_outlined,
                      title: "Treatments",
                      isMobile: isMobile,
                    ),
                    _buildMenuItem(
                      context,
                      page: 'history',
                      icon: Icons.history,
                      title: "History",
                      isMobile: isMobile,
                    ),
                    _buildMenuItem(
                      context,
                      page: 'settings',
                      icon: Icons.settings_outlined,
                      title: "Settings",
                      isMobile: isMobile,
                    ),
                    _buildMenuItem(
                      context,
                      page: 'profile',
                      icon: Icons.person_outline,
                      title: "Profile",
                      isMobile: isMobile,
                    ),
                    _buildMenuItem(
                      context,
                      page: 'logout',
                      icon: Icons.logout,
                      title: "Logout",
                      isMobile: isMobile,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Pinned bottom plant decorative graphic
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF14241A) : const Color(0xFF032213),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_florist,
                    size: 40,
                    color: Color(0xFF81C784),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Keep your\nplants healthy!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
