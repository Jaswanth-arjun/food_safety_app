import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/restaurant_provider.dart';
import 'providers/report_provider.dart';
import 'providers/inspection_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/citizen/home_screen.dart';
import 'screens/inspector/dashboard.dart'; // Add this import

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
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const AppWrapper(),
    );
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }
    
    // Route based on role
    switch (authProvider.userRole) {
      case 'inspector':
        return const InspectorDashboard(); // Use the actual InspectorDashboard
      case 'admin':
        return AdminDashboard(); // We'll create this later
      case 'citizen':
      default:
        return const CitizenHomeScreen();
    }
  }
}

// Keep the AdminDashboard placeholder for now
class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: const Center(
        child: Text('Admin Dashboard - Coming Soon!'),
      ),
    );
  }
}