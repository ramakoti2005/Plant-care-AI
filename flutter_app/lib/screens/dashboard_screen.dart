import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/responsive_theme.dart';
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
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveTheme.isWebLayout(context);

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
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: ResponsiveTheme.getAppBackgroundDecoration(context),
          child: Row(
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
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: _activePage == 'dashboard'
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
        appBar: _activePage == 'dashboard'
            ? AppBar(
                title: Text(pageTitle),
              )
            : null,
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

              const SizedBox(height: 40),

              // Dashboard Cards Grid/List Selection
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: ResponsiveTheme.isWebLayout(context) ? 2 : 1,
                childAspectRatio: ResponsiveTheme.isWebLayout(context) ? 3.0 : 3.5,
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
    return ResponsiveCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
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
    required Widget leading,
    required String title,
    required bool isMobile,
  }) {
    final bool isActive = _activePage == page;
    final bool isDesktop = !isMobile;

    Widget listTile = ListTile(
      leading: leading,
      title: Text(
        title,
        style: TextStyle(
          color: isActive
              ? (isDesktop ? const Color(0xFF1B3B22) : Colors.white)
              : Colors.white70,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
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

    if (isActive && isDesktop) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: listTile,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: listTile,
    );
  }

  Widget _buildSubMenuItem(
    BuildContext context, {
    required String page,
    Widget? leading,
    required String title,
    required bool isMobile,
    required VoidCallback onTap,
  }) {
    final bool isActive = _activePage == page;
    final bool isDesktop = !isMobile;

    Widget listTile = ListTile(
      leading: leading,
      title: Text(
        title,
        style: TextStyle(
          color: isActive
              ? (isDesktop ? const Color(0xFF1B3B22) : Colors.white)
              : Colors.white70,
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        if (isMobile) {
          Navigator.pop(context);
        }
        onTap();
      },
    );

    if (isActive && isDesktop) {
      return Container(
        margin: const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: listTile,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: listTile,
    );
  }

  Widget _buildCustomNavigationDrawerContent(BuildContext context, {required bool isMobile}) {
    return Container(
      color: ResponsiveTheme.getSidebarColor(),
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF2E5A36), // Deep green header background
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.eco, color: Color(0xFF2E5A36), size: 40),
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
                    _buildMenuItem(
                      context,
                      page: 'dashboard',
                      leading: const Text("🏠", style: TextStyle(fontSize: 20)),
                      title: "Dashboard",
                      isMobile: isMobile,
                    ),
                    _buildMenuItem(
                      context,
                      page: 'scan_plant',
                      leading: const Text("📸", style: TextStyle(fontSize: 20)),
                      title: "Scan Plant",
                      isMobile: isMobile,
                    ),

                    const Divider(color: Colors.white24, height: 1),

                    // Section 1: Treatments Style Dropdown Block
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
                          page: 'apple_diseases',
                          leading: const Text("🍎", style: TextStyle(fontSize: 18)),
                          title: "Apple Diseases",
                          isMobile: isMobile,
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
                          page: 'corn_diseases',
                          leading: const Text("🌽", style: TextStyle(fontSize: 18)),
                          title: "Corn Diseases",
                          isMobile: isMobile,
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
                          page: 'grape_diseases',
                          leading: const Text("🍇", style: TextStyle(fontSize: 18)),
                          title: "Grape Diseases",
                          isMobile: isMobile,
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
                          page: 'peach_diseases',
                          leading: const Text("🍑", style: TextStyle(fontSize: 18)),
                          title: "Peach Diseases",
                          isMobile: isMobile,
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
                          page: 'potato_diseases',
                          leading: const Text("🥔", style: TextStyle(fontSize: 18)),
                          title: "Potato Diseases",
                          isMobile: isMobile,
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
                          page: 'rice_diseases',
                          leading: const Text("🌾", style: TextStyle(fontSize: 18)),
                          title: "Rice Diseases",
                          isMobile: isMobile,
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
                          page: 'tomato_diseases',
                          leading: const Text("🍅", style: TextStyle(fontSize: 18)),
                          title: "Tomato Diseases",
                          isMobile: isMobile,
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

                    // Section 2: User Space Style Dropdown Block
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
                          page: 'history',
                          leading: const Text("🕒", style: TextStyle(fontSize: 18)),
                          title: "History",
                          isMobile: isMobile,
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
                          page: 'profile',
                          leading: const Text("👤", style: TextStyle(fontSize: 18)),
                          title: "Profile",
                          isMobile: isMobile,
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
}
