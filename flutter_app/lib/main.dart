import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'screens/screens.dart';

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
        // Add other providers here (e.g., DashboardProvider, SettingsProvider)
      ],
      child: MaterialApp(
        title: 'My Flutter App',
        theme: ThemeData(
          // Define your color scheme here to match web branding
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          // Add other routes as needed
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
