import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'services/settings_service.dart';
import 'screens/screens.dart';
import 'theme/responsive_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SettingsService()),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'My Flutter App',
            theme: settings.isDarkMode ? ResponsiveTheme.darkTheme : ResponsiveTheme.lightTheme,
            initialRoute: '/',
            routes: {
              '/': (context) => const LoginScreen(),
              '/register': (context) => const RegistrationScreen(),
              '/dashboard': (context) => const DashboardScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
