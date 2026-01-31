import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _initTheme();
  }

  Future<void> _initTheme() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('dark_mode_enabled') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('dark_mode_enabled', _isDarkMode);
    notifyListeners();
  }

  /// Explicitly set theme mode instead of just toggling.
  Future<void> setDarkMode(bool enabled) async {
    _isDarkMode = enabled;
    await _prefs.setBool('dark_mode_enabled', _isDarkMode);
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF2563EB),
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2563EB),
        secondary: Color(0xFF10B981),
        tertiary: Color(0xFFF59E0B),
        surface: Colors.white,
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1E293B),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1E293B),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF2563EB),
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF2563EB),
        secondary: Color(0xFF10B981),
        tertiary: Color(0xFFF59E0B),
        surface: Color(0xFF1E293B),
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFFE2E8F0),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Color(0xFFE2E8F0),
      ),
    );
  }
}
