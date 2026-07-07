import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ResponsiveTheme {
  static bool isWebLayout(BuildContext context) {
    return kIsWeb || MediaQuery.of(context).size.width >= 900;
  }

  static Decoration getAppBackgroundDecoration(BuildContext context) {
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

  static Color getSidebarColor() {
    return const Color(0xFF1B3B22); // Deep forest green solid color
  }

  static Decoration getCardDecoration(BuildContext context, {Color? webBgColor}) {
    return BoxDecoration(
      color: webBgColor ?? Colors.white, // Solid pure white card background
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFFE2EBE3), // Soft matching green border line
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static TextStyle getHeaderStyle(BuildContext context, {double fontSize = 22, FontWeight fontWeight = FontWeight.bold}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: const Color(0xFF1B5E20), // Always forest green for high contrast and readability
    );
  }

  static TextStyle getSubHeaderStyle(BuildContext context, {double fontSize = 16}) {
    return TextStyle(
      fontSize: fontSize,
      color: Colors.black54,
    );
  }

  static TextStyle getBodyStyle(BuildContext context, {double fontSize = 14}) {
    return TextStyle(
      fontSize: fontSize,
      color: Colors.black87,
    );
  }

  static Color getIconColor(BuildContext context, {Color? webColor}) {
    return webColor ?? const Color(0xFF2E7D32);
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
    return ResponsiveCard(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ResponsiveTheme.getHeaderStyle(context, fontSize: 22),
          ),
          const SizedBox(height: 5),
          Text(
            "Scientific Name: $scientificName",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
            ),
          ),
          Divider(height: 25, color: Colors.grey[300]),
          
          Text(
            "Overview",
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            overview,
            style: const TextStyle(color: Colors.black87),
          ),

          const SizedBox(height: 15),
          _sectionTitle(context, "Causes"),
          ...causes.map((e) => _bulletPoint(context, e)),

          const SizedBox(height: 15),
          _sectionTitle(context, "Symptoms"),
          ...symptoms.map((e) => _bulletPoint(context, e)),

          const SizedBox(height: 15),
          _sectionTitle(context, "Treatment"),
          ...treatment.map((e) => _bulletPoint(context, e)),

          if (organic != null) ...[
            const SizedBox(height: 15),
            _sectionTitle(context, "Organic Remedies"),
            ...organic!.map((e) => _bulletPoint(context, e)),
          ],

          const SizedBox(height: 15),
          _sectionTitle(context, "Prevention"),
          ...prevention.map((e) => _bulletPoint(context, e)),

          if (recoveryTime != null && recoveryTime != "N/A") ...[
            const SizedBox(height: 15),
            _sectionTitle(context, "Recovery Time"),
            Text(
              recoveryTime!,
              style: const TextStyle(color: Colors.black87),
            ),
          ],

          if (tips != null) ...[
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
                    tips!,
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
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _bulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ", 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
