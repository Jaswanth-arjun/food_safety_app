import 'dart:ui';

class AppConstants {
  static const String appName = 'Food Safety Monitor';
  static const String apiBaseUrl = 'http://localhost:8000';
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_KEY';
  
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color dangerColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  
  // Padding
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
}