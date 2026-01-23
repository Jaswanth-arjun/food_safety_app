import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_safety_app/providers/auth_provider.dart';
import 'package:food_safety_app/providers/restaurant_provider.dart';
import 'package:food_safety_app/providers/report_provider.dart';
import 'package:food_safety_app/providers/inspection_provider.dart';
import 'package:food_safety_app/screens/auth/login_screen.dart';
import 'package:food_safety_app/screens/citizen/home_screen.dart';
import 'package:food_safety_app/screens/inspector/dashboard.dart';
import 'package:food_safety_app/screens/admin/admin_dashboard.dart'; // Add this import

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => InspectionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Safety Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // Changed to match admin theme
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 4,
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const AppWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/citizen': (context) => const CitizenHomeScreen(),
        '/inspector': (context) => const InspectorDashboard(),
        '/admin': (context) => const AdminDashboard(),
      },
    );
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: Colors.deepPurple,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 60,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Food Safety Monitor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                color: Colors.white,
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
        return const InspectorDashboard();
      case 'admin':
        return const AdminDashboard(); // Now using the real AdminDashboard
      case 'citizen':
      default:
        return const CitizenHomeScreen();
    }
  }
}

// IMPORTANT: REMOVE THE PLACEHOLDER AdminDashboard CLASS FROM HERE!
// Delete everything below this line if it exists