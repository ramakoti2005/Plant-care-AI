import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class ResponsiveTheme {
  static bool isWebLayout(BuildContext context) {
    return kIsWeb || MediaQuery.of(context).size.width >= 900;
  }

  static Decoration getAppBackgroundDecoration(BuildContext context) {
    bool dark = false;
    try {
      final settings = Provider.of<SettingsService>(context, listen: true);
      dark = settings.isDarkMode;
    } catch (_) {}

    if (dark) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF142217), // Deep dark green gradient starting color
            Color(0xFF0F1A12), // Deeper forest dark background color
          ],
        ),
      );
    }

    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE8F2EA), // Extremely soft, pleasant mint/sage green tint
          Color(0xFFF9FBF9), // Soft off-white
        ],
      ),
    );
  }

  static Color getSidebarColor(BuildContext context) {
    bool dark = false;
    try {
      final settings = Provider.of<SettingsService>(context, listen: false);
      dark = settings.isDarkMode;
    } catch (_) {}
    return dark ? const Color(0xFF0C160E) : const Color(0xFF1B3B22); // Deep forest green solid color
  }

  static Decoration getCardDecoration(BuildContext context, {Color? webBgColor}) {
    bool dark = false;
    try {
      final settings = Provider.of<SettingsService>(context, listen: false);
      dark = settings.isDarkMode;
    } catch (_) {}

    final cardBg = webBgColor ?? (dark ? const Color(0xFF1C2D22) : Colors.white);
    final borderCol = dark ? const Color(0xFF2E4233) : const Color(0xFFE2EBE3);

    return BoxDecoration(
      color: cardBg, // Solid pure white card background or dark green
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: borderCol, // Soft matching green border line
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(dark ? 0.15 : 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static TextStyle getHeaderStyle(BuildContext context, {double fontSize = 22, FontWeight fontWeight = FontWeight.bold}) {
    bool dark = false;
    try {
      final settings = Provider.of<SettingsService>(context, listen: false);
      dark = settings.isDarkMode;
    } catch (_) {}
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: dark ? const Color(0xFF81C784) : const Color(0xFF1B5E20), // Always forest green for high contrast and readability
    );
  }

  static TextStyle getSubHeaderStyle(BuildContext context, {double fontSize = 16}) {
    bool dark = false;
    try {
      final settings = Provider.of<SettingsService>(context, listen: false);
      dark = settings.isDarkMode;
    } catch (_) {}
    return TextStyle(
      fontSize: fontSize,
      color: dark ? Colors.white70 : Colors.black54,
    );
  }

  static TextStyle getBodyStyle(BuildContext context, {double fontSize = 14}) {
    bool dark = false;
    try {
      final settings = Provider.of<SettingsService>(context, listen: false);
      dark = settings.isDarkMode;
    } catch (_) {}
    return TextStyle(
      fontSize: fontSize,
      color: dark ? Colors.white.withOpacity(0.87) : Colors.black87,
    );
  }

  static Color getIconColor(BuildContext context, {Color? webColor}) {
    bool dark = false;
    try {
      final settings = Provider.of<SettingsService>(context, listen: false);
      dark = settings.isDarkMode;
    } catch (_) {}
    return webColor ?? (dark ? const Color(0xFF81C784) : const Color(0xFF2E7D32));
  }
}

class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool web = ResponsiveTheme.isWebLayout(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar != null
          ? PreferredSize(
              preferredSize: appBar!.preferredSize,
              child: Theme(
                data: Theme.of(context).copyWith(
                  appBarTheme: AppBarTheme(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
                    actionsIconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
                    titleTextStyle: TextStyle(
                      color: const Color(0xFF1B5E20),
                      fontSize: web ? 22 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                child: appBar!,
              ),
            )
          : null,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: ResponsiveTheme.getAppBackgroundDecoration(context),
        child: SafeArea(
          top: appBar == null,
          child: body,
        ),
      ),
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final Color? webBgColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.webBgColor,
    this.margin,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = ResponsiveTheme.getCardDecoration(context, webBgColor: webBgColor);

    return Container(
      margin: margin,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

class DiseaseCard extends StatelessWidget {
  final String title;
  final String scientificName;
  final String overview;
  final List<String> causes;
  final List<String> symptoms;
  final List<String> treatment;
  final List<String> prevention;
  final List<String>? organic;
  final String? recoveryTime;
  final String? tips;

  const DiseaseCard({
    super.key,
    required this.title,
    required this.scientificName,
    required this.overview,
    required this.causes,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    this.organic,
    this.recoveryTime,
    this.tips,
  });

  @override
  Widget build(BuildContext context) {
    bool isFahrenheit = false;
    try {
      final settings = Provider.of<SettingsService>(context);
      isFahrenheit = settings.selectedUnit == 'Fahrenheit (°F)';
    } catch (_) {}

    String convert(String val) => SettingsService.convertTemperatureString(val, isFahrenheit);

    final resolvedTitle = convert(title);
    final resolvedOverview = convert(overview);
    final resolvedCauses = causes.map((e) => convert(e)).toList();
    final resolvedSymptoms = symptoms.map((e) => convert(e)).toList();
    final resolvedTreatment = treatment.map((e) => convert(e)).toList();
    final resolvedPrevention = prevention.map((e) => convert(e)).toList();
    final resolvedOrganic = organic?.map((e) => convert(e)).toList();
    final resolvedRecoveryTime = recoveryTime != null ? convert(recoveryTime!) : null;
    final resolvedTips = tips != null ? convert(tips!) : null;

    final Color txtColor = Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87;

    return ResponsiveCard(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resolvedTitle,
            style: ResponsiveTheme.getHeaderStyle(context, fontSize: 22),
          ),
          const SizedBox(height: 5),
          Text(
            "Scientific Name: $scientificName",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.grey[700],
            ),
          ),
          Divider(height: 25, color: Colors.grey[300]),
          
          Text(
            "Overview",
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: txtColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            resolvedOverview,
            style: TextStyle(color: txtColor),
          ),

          const SizedBox(height: 15),
          _sectionTitle(context, "Causes"),
          ...resolvedCauses.map((e) => _bulletPoint(context, e)),

          const SizedBox(height: 15),
          _sectionTitle(context, "Symptoms"),
          ...resolvedSymptoms.map((e) => _bulletPoint(context, e)),

          const SizedBox(height: 15),
          _sectionTitle(context, "Treatment"),
          ...resolvedTreatment.map((e) => _bulletPoint(context, e)),

          if (resolvedOrganic != null) ...[
            const SizedBox(height: 15),
            _sectionTitle(context, "Organic Remedies"),
            ...resolvedOrganic.map((e) => _bulletPoint(context, e)),
          ],

          const SizedBox(height: 15),
          _sectionTitle(context, "Prevention"),
          ...resolvedPrevention.map((e) => _bulletPoint(context, e)),

          if (resolvedRecoveryTime != null && resolvedRecoveryTime != "N/A") ...[
            const SizedBox(height: 15),
            _sectionTitle(context, "Recovery Time"),
            Text(
              resolvedRecoveryTime,
              style: TextStyle(color: txtColor),
            ),
          ],

          if (resolvedTips != null) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Farmer Tips",
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    resolvedTips,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.87) : Colors.black87,
        ),
      ),
    );
  }

  Widget _bulletPoint(BuildContext context, String text) {
    final Color txtColor = Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87;
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(fontWeight: FontWeight.bold, color: ResponsiveTheme.getIconColor(context))),
          Expanded(child: Text(text, style: TextStyle(color: txtColor))),
        ],
      ),
    );
  }
}
