import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ResponsiveTheme {
  static bool isWebLayout(BuildContext context) {
    return kIsWeb || MediaQuery.of(context).size.width >= 900;
  }

  static Decoration getAppBackgroundDecoration(BuildContext context) {
    if (isWebLayout(context)) {
      return const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else {
      return const BoxDecoration(
        color: Colors.transparent,
      );
    }
  }

  static Color getSidebarColor() {
    return const Color(0xFF1B3B22); // Deep forest green solid color
  }

  static Decoration getCardDecoration(BuildContext context, {Color? webBgColor}) {
    if (isWebLayout(context)) {
      return BoxDecoration(
        color: webBgColor ?? const Color(0xFFF4F8F1), // Solid pale mint/off-white background surface
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } else {
      // Frosted Glass decoration (mobile)
      return BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }
  }

  static TextStyle getHeaderStyle(BuildContext context, {double fontSize = 22, FontWeight fontWeight = FontWeight.bold}) {
    final bool web = isWebLayout(context);
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: web ? const Color(0xFF1B5E20) : Colors.white,
    );
  }

  static TextStyle getSubHeaderStyle(BuildContext context, {double fontSize = 16}) {
    final bool web = isWebLayout(context);
    return TextStyle(
      fontSize: fontSize,
      color: web ? Colors.black54 : const Color(0xFFE0E0E0),
    );
  }

  static TextStyle getBodyStyle(BuildContext context, {double fontSize = 14}) {
    final bool web = isWebLayout(context);
    return TextStyle(
      fontSize: fontSize,
      color: web ? Colors.black87 : Colors.white.withOpacity(0.9),
    );
  }

  static Color getIconColor(BuildContext context, {Color? webColor}) {
    return isWebLayout(context) ? (webColor ?? const Color(0xFF2E7D32)) : Colors.white;
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

    if (web) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        drawer: drawer,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: ResponsiveTheme.getAppBackgroundDecoration(context),
          child: body,
        ),
      );
    } else {
      // Mobile layout with a blurred background image
      return Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        drawer: drawer,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: appBar != null
            ? PreferredSize(
                preferredSize: appBar!.preferredSize,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    appBarTheme: const AppBarTheme(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      iconTheme: IconThemeData(color: Colors.white),
                      actionsIconTheme: IconThemeData(color: Colors.white),
                      titleTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  child: appBar!,
                ),
              )
            : null,
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/image_290c76.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // Blur Layer
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: Colors.black.withOpacity(0.12),
                ),
              ),
            ),
            // Foreground Content
            SafeArea(
              top: appBar == null,
              child: body,
            ),
          ],
        ),
      );
    }
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
    final bool web = ResponsiveTheme.isWebLayout(context);
    final decoration = ResponsiveTheme.getCardDecoration(context, webBgColor: webBgColor);

    if (web) {
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
    } else {
      // Mobile Glassmorphism card
      return Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
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
            ),
          ),
        ),
      );
    }
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
    final bool web = ResponsiveTheme.isWebLayout(context);
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
              color: web ? Colors.grey[700] : const Color(0xFFE0E0E0),
            ),
          ),
          Divider(height: 25, color: web ? Colors.grey[300] : Colors.white24),
          
          Text(
            "Overview",
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: web ? Colors.black87 : Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            overview,
            style: TextStyle(color: web ? Colors.black87 : const Color(0xFFE0E0E0)),
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
              style: TextStyle(color: web ? Colors.black87 : const Color(0xFFE0E0E0)),
            ),
          ],

          if (tips != null) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: web ? Colors.green.withOpacity(0.1) : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: web ? Colors.green.withOpacity(0.3) : Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Farmer Tips",
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16,
                          color: web ? Colors.black87 : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    tips!,
                    style: TextStyle(color: web ? Colors.black87 : const Color(0xFFE0E0E0)),
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
    final bool web = ResponsiveTheme.isWebLayout(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: web ? Colors.black87 : Colors.white,
        ),
      ),
    );
  }

  Widget _bulletPoint(BuildContext context, String text) {
    final bool web = ResponsiveTheme.isWebLayout(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ", 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: web ? Colors.black87 : Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: web ? Colors.black87 : const Color(0xFFE0E0E0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
