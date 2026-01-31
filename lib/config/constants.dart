import 'dart:ui';

class AppConstants {
  static const String appName = 'Food Guard';
  static const String apiBaseUrl = 'http://localhost:8000';
  
  // TODO: Add your Supabase credentials here
  // Copy from lib/config/constants.dart.example and fill in your real values
  // DO NOT COMMIT THIS FILE WITH REAL KEYS TO GIT
  static const String supabaseUrl = 'https://cgdbwwgcdgdjqlevimxi.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNnZGJ3d2djZGdkanFsZXZpbXhpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk1MTcyMjUsImV4cCI6MjA4NTA5MzIyNX0._qZqqVW74FBD5EoXtEe1q8orXhyKpMEE9dwO3B2vnDU';
  static const String supabaseServiceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNnZGJ3d2djZGdkanFsZXZpbXhpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTUxNzIyNSwiZXhwIjoyMDg1MDkzMjI1fQ.dXOuFGScC2DNZyrrcFlZneFLfwy-7j0x6xuOzOmo5Lo';
  
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