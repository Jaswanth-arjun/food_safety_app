import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_guard/providers/auth_provider.dart';
import 'package:food_guard/providers/theme_provider.dart';
import 'package:food_guard/providers/restaurant_provider.dart';
import 'package:food_guard/providers/rating_provider.dart';
import 'package:food_guard/providers/report_provider.dart';
import 'package:food_guard/providers/inspection_provider.dart';
import 'package:food_guard/providers/notification_provider.dart';
import 'package:food_guard/screens/auth/login_screen.dart';
import 'package:food_guard/screens/citizen/home_screen.dart';
import 'package:food_guard/screens/inspector/dashboard.dart';
import 'package:food_guard/screens/admin/admin_dashboard.dart';
import 'package:food_guard/app.dart';
import 'package:food_guard/services/supabase_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:food_guard/config/constants.dart';
import 'package:food_guard/widgets/brand_logo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.init();

  // Initialize providers
  final ratingProvider = RatingProvider();

  // Debug: remove local user 'jaswanth' from SharedPreferences when running in debug
  if (kDebugMode) {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('DEBUG: SharedPreferences keys before cleanup: ${prefs.getKeys()}');
      final usersJson = prefs.getString('users');
      if (usersJson != null) {
        final List users = jsonDecode(usersJson) as List;
        final before = users.length;
        users.removeWhere((u) => (u is Map && (u['email'] == 'jaswanth@gmail.com' || u['email'] == 'jaswanth@gmail.com')));
        final after = users.length;
        if (after != before) {
          await prefs.setString('users', jsonEncode(users));
          print('DEBUG: Removed jaswanth from local users (removed ${before - after}).');
        } else {
          print('DEBUG: jaswanth not found in local users.');
        }
      } else {
        print('DEBUG: No "users" key in SharedPreferences.');
      }
    } catch (e) {
      print('DEBUG: Failed to cleanup SharedPreferences: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ratingProvider),
        ChangeNotifierProvider(create: (_) => RestaurantProvider(ratingProvider: ratingProvider)),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => InspectionProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const App(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF2563EB), // Modern blue
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Light gray background
        fontFamily: 'Inter', // Modern font family

        // Color scheme
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF10B981), // Emerald green
          tertiary: Color(0xFFF59E0B), // Amber
          surface: Colors.white,
          error: Color(0xFFEF4444),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF1E293B),
        ),

        // App bar theme
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            fontFamily: 'Inter',
          ),
        ),

        // Card theme
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          surfaceTintColor: Colors.transparent,
        ),

        // Button themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
            fontFamily: 'Inter',
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 16,
            fontFamily: 'Inter',
          ),
        ),

        // Text themes
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            fontFamily: 'Inter',
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            fontFamily: 'Inter',
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            fontFamily: 'Inter',
          ),
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            fontFamily: 'Inter',
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            fontFamily: 'Inter',
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            fontFamily: 'Inter',
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            fontFamily: 'Inter',
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
            fontFamily: 'Inter',
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
            fontFamily: 'Inter',
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1E293B),
            fontFamily: 'Inter',
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF475569),
            fontFamily: 'Inter',
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
            fontFamily: 'Inter',
          ),
        ),

        // Bottom navigation bar theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF2563EB),
          unselectedItemColor: Color(0xFF94A3B8),
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),

        // Floating action button theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),

        // Chip theme
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF1F5F9),
          selectedColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
          checkmarkColor: const Color(0xFF2563EB),
          deleteIconColor: const Color(0xFFEF4444),
          labelStyle: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
          secondaryLabelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        // Dialog theme
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // SnackBar theme
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF1E293B),
          contentTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const AppWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/citizen': (context) => const CitizenHomeScreen(),
        '/inspector': (context) => const InspectorDashboard(),
        '/admin': (context) => AdminDashboard(),
      },
    );
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    print('DEBUG: AppWrapper build - isLoading: ${authProvider.isLoading}, isAuthenticated: ${authProvider.isAuthenticated}, userRole: ${authProvider.userRole}');
    
    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF2563EB),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Modern logo with gradient
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 24,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                  child: BrandLogo.large(),
              ),
              const SizedBox(height: 32),
              Text(
                AppConstants.appName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ensuring safe food for everyone',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 48),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: LogoSpinner(size: 20)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }
    
    // Route based on role
    switch (authProvider.userRole) {
      case 'inspector':
        print('DEBUG: Routing to InspectorDashboard');
        return const InspectorDashboard();
      case 'admin':
        print('DEBUG: Routing to AdminDashboard');
        return AdminDashboard(); // Now using the real AdminDashboard
      case 'citizen':
      default:
        print('DEBUG: Routing to CitizenHomeScreen');
        return const CitizenHomeScreen();
    }
  }
}

// IMPORTANT: REMOVE THE PLACEHOLDER AdminDashboard CLASS FROM HERE!
// Delete everything below this line if it exists