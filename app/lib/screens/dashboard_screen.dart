import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'screens.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();

  // Static navigation helper method for embedded view switching
  static void navigate(BuildContext context, String page, {Widget? fallbackWidget, Widget? customWidget}) {
    final state = context.findAncestorStateOfType<_DashboardScreenState>();
    if (state != null) {
      state.setPage(page, customWidget: customWidget);
    } else if (fallbackWidget != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => fallbackWidget));
    }
  }
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _activePage = 'dashboard';
  Widget? _customWidget;

  void setPage(String page, {Widget? customWidget}) {
    setState(() {
      _activePage = page;
      _customWidget = customWidget;
    });
  }

  void _onPageSelected(String page) {
    setState(() {
      _activePage = page;
      _customWidget = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = kIsWeb || MediaQuery.of(context).size.width >= 900;

    // Resolve current selected page body
    Widget currentSelectedPage;
    String pageTitle;

    switch (_activePage) {
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
        currentSelectedPage = _customWidget ?? const SizedBox.shrink();
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
        backgroundColor: const Color(0xFFF4FAF4),
        body: Row(
          children: [
            // Left Sidebar
            SizedBox(
              width: 260,
              child: Drawer(
                child: _buildCustomNavigationDrawerContent(context, isMobile: false),
              ),
            ),
            // Right Content Area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/image_290c76.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.05),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: _activePage == 'dashboard'
                      ? AppBar(
                          backgroundColor: const Color(0xFF2E7D32),
                          elevation: 0,
                          iconTheme: const IconThemeData(color: Colors.white),
                          title: Text(
                            pageTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          centerTitle: true,
                        )
                      : null, // Sub-pages render their own app bar inside the viewport
                  body: Theme(
                    data: Theme.of(context).copyWith(
                      scaffoldBackgroundColor: Colors.transparent,
                    ),
                    child: currentSelectedPage,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // 📱 Mobile layout with hamburger menu and sliding drawer
      return Scaffold(
        backgroundColor: const Color(0xFFF4FAF4),
        appBar: _activePage == 'dashboard'
            ? AppBar(
                backgroundColor: const Color(0xFF2E7D32),
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  pageTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              )
            : null, // Sub-pages render their own app bar inside the viewport
        drawer: _activePage == 'dashboard'
            ? Drawer(
                child: _buildCustomNavigationDrawerContent(context, isMobile: true),
              )
            : null,
        body: currentSelectedPage,
      );
    }
  }

  Widget _buildDashboardBodyContent(BuildContext context) {
    return Center(
      child: Container(
        constraints: kIsWeb ? const BoxConstraints(maxWidth: 1100) : null,
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

              const Text(
                "Welcome to Plant Care AI",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "AI Powered Plant Disease Detection",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 40),

              // Dashboard Cards Grid/List Selection
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: kIsWeb || MediaQuery.of(context).size.width >= 900 ? 2 : 1,
                childAspectRatio: kIsWeb || MediaQuery.of(context).size.width >= 900 ? 3.0 : 3.5,
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
    final double radius = kIsWeb || MediaQuery.of(context).size.width >= 900 ? 16.0 : 20.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Leading Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF2E7D32),
                    size: 32,
                  ),
                ),
                
                const SizedBox(width: 20),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Trailing Arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomNavigationDrawerContent(BuildContext context, {required bool isMobile}) {
    return Container(
      color: const Color(0xFF0F3A20), // Sleek deep dark-forest matte color layout
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32), // Solid green header
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.eco, color: Color(0xFF2E7D32), size: 40),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Plant Care AI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
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
                    // Top Level Actions (Always Visible)
                    ListTile(
                      leading: const Text("🏠", style: TextStyle(fontSize: 20)),
                      title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        if (isMobile) {
                          Navigator.pop(context);
                        }
                        _onPageSelected('dashboard');
                      },
                    ),
                    ListTile(
                      leading: const Text("📸", style: TextStyle(fontSize: 20)),
                      title: const Text("Scan Plant", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        if (isMobile) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ScanPlantScreen()),
                          );
                        } else {
                          _onPageSelected('scan_plant');
                        }
                      },
                    ),

                    const Divider(color: Colors.white24, height: 1),

                    // Section 1: "Subscriptions" Style Dropdown Block
                    ExpansionTile(
                      title: const Text(
                        "Treatments",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white70,
                      childrenPadding: const EdgeInsets.only(left: 12),
                      children: [
                        _buildSubMenuItem(
                          context,
                          leading: const Text("🍎", style: TextStyle(fontSize: 18)),
                          title: "Apple Diseases",
                          onTap: () {
                            if (isMobile) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AppleDiseasesScreen()));
                            } else {
                              _onPageSelected('apple_diseases');
                            }
                          },
                        ),
                        _buildSubMenuItem(
                          context,
                          leading: const Text("🌽", style: TextStyle(fontSize: 18)),
                          title: "Corn Diseases",
                          onTap: () {
                            if (isMobile) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CornDiseasesScreen()));
                            } else {
                              _onPageSelected('corn_diseases');
                            }
                          },
                        ),
                        _buildSubMenuItem(
                          context,
                          leading: const Text("🍇", style: TextStyle(fontSize: 18)),
                          title: "Grape Diseases",
                          onTap: () {
                            if (isMobile) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const GrapeDiseasesScreen()));
                            } else {
                              _onPageSelected('grape_diseases');
                            }
                          },
                        ),
                        _buildSubMenuItem(
                          context,
                          leading: const Text("🍑", style: TextStyle(fontSize: 18)),
                          title: "Peach Diseases",
                          onTap: () {
                            if (isMobile) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const PeachDiseasesScreen()));
                            } else {
                              _onPageSelected('peach_diseases');
                            }
                          },
                        ),
                        _buildSubMenuItem(
                          context,
                          leading: const Text("🥔", style: TextStyle(fontSize: 18)),
                          title: "Potato Diseases",
                          onTap: () {
                            if (isMobile) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const PotatoDiseasesScreen()));
                            } else {
                              _onPageSelected('potato_diseases');
                            }
                          },
                        ),
                        _buildSubMenuItem(
                          context,
                          leading: const Text("🌾", style: TextStyle(fontSize: 18)),
                          title: "Rice Diseases",
                          onTap: () {
                            if (isMobile) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const RiceDiseasesScreen()));
                            } else {
                              _onPageSelected('rice_diseases');
                            }
                          },
                        ),
                        _buildSubMenuItem(
                          context,
                          leading: const Text("🍅", style: TextStyle(fontSize: 18)),
                          title: "Tomato Diseases",
                          onTap: () {
                            if (isMobile) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const TomatoDiseasesScreen()));
                            } else {
                              _onPageSelected('tomato_diseases');
                            }
                          },
                        ),
                      ],
                    ),

                    const Divider(color: Colors.white24, height: 1),

                    // Section 2: "You" Style Dropdown Block
                    ExpansionTile(
                      title: const Text(
                        "User Space",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white70,
                      childrenPadding: const EdgeInsets.only(left: 12),
                      children: [
                        _buildSubMenuItem(
                          context,
                          leading: const Text("🕒", style: TextStyle(fontSize: 18)),
                          title: "History",
                          onTap: () {
                            if (isMobile) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                            } else {
                              _onPageSelected('history');
                            }
                          },
                        ),
                        _buildSubMenuItem(
                          context,
                          leading: const Text("👤", style: TextStyle(fontSize: 18)),
                          title: "Profile",
                          onTap: () {
                            if (isMobile) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                            } else {
                              _onPageSelected('profile');
                            }
                          },
                        ),
                      ],
                    ),

                    const Divider(color: Colors.white24, height: 1),

                    // Section 3: Utilities & System Context
                    ListTile(
                      leading: const Text("⚙️", style: TextStyle(fontSize: 20)),
                      title: const Text("Settings", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        if (isMobile) {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                        } else {
                          _onPageSelected('settings');
                        }
                      },
                    ),
                    ListTile(
                      leading: const Text("🚪", style: TextStyle(fontSize: 20)),
                      title: const Text("Log Out", style: TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.logout, color: Colors.white70, size: 20),
                      onTap: () async {
                        if (isMobile) {
                          Navigator.pop(context);
                        }
                        try {
                          await Provider.of<AuthService>(context, listen: false).logout();
                        } catch (_) {}
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Pinned bottom plant decorative graphic
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_florist,
                  size: 60,
                  color: Colors.green[200],
                ),
                const SizedBox(height: 4),
                Container(
                  width: 30,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.brown[300],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Keep your plants healthy!",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMenuItem(
    BuildContext context, {
    Widget? leading,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      onTap: () {
        final bool isDesktop = kIsWeb || MediaQuery.of(context).size.width >= 900;
        if (!isDesktop) {
          Navigator.pop(context); // Close drawer
        }
        onTap();
      },
    );
  }
}
