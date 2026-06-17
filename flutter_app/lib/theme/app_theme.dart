import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0A73FF); // Vibrant blue
  static const Color secondaryColor = Color(0xFF00C897); // Teal accent
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light gray background
  static const Color scaffoldBackground = Colors.white;

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    scaffoldBackgroundColor: scaffoldBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headline1: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
      headline6: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
      bodyText1: TextStyle(fontSize: 16, color: Colors.black87),
      bodyText2: TextStyle(fontSize: 14, color: Colors.black54),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
