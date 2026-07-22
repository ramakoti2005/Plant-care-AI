import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      final base = Uri.base;
      final portStr = (base.port == 80 || base.port == 443 || base.port == 0) ? "" : ":${base.port}";
      return "${base.scheme}://${base.host}$portStr/api/v1";
    }
    // Fallback for mobile/other platforms
    return "https://plant-care-ai-6ng8.onrender.com/api/v1";
  }
}