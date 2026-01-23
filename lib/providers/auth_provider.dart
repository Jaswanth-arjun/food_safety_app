import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _user;
  String? _error;
  List<Map<String, dynamic>> _allUsers = [];

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  String get userRole => _user?['role'] ?? 'citizen';
  List<Map<String, dynamic>> get allUsers => _allUsers;

  // Get current user as User model (for admin dashboard)
  Map<String, dynamic>? get currentUser => _user;

  Future<bool> login(String email, String password, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Mock user data
    _user = {
      'id': '${role}_${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'name': '${role[0].toUpperCase()}${role.substring(1)} User',
      'fullName': '${role[0].toUpperCase()}${role.substring(1)} User',
      'role': role,
      'phoneNumber': '+91 9876543210',
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
    };

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _user = null;
    _error = null;
    _allUsers = []; // Clear all users on logout
    notifyListeners();
  }

  // Admin functions
  Future<void> fetchAllUsers() async {
    try {
      // Mock data for admin dashboard
      await Future.delayed(const Duration(milliseconds: 500));
      
      _allUsers = [
        {
          'id': 'admin_1',
          'name': 'Admin User',
          'email': 'admin@foodsafety.com',
          'role': 'admin',
          'phoneNumber': '+91 9876543210',
          'isActive': true,
          'createdAt': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
        },
        {
          'id': 'inspector_1',
          'name': 'Inspector One',
          'email': 'inspector1@foodsafety.com',
          'role': 'inspector',
          'phoneNumber': '+91 9876543211',
          'isActive': true,
          'createdAt': DateTime.now().subtract(Duration(days: 25)).toIso8601String(),
        },
        {
          'id': 'inspector_2',
          'name': 'Inspector Two',
          'email': 'inspector2@foodsafety.com',
          'role': 'inspector',
          'phoneNumber': '+91 9876543212',
          'isActive': true,
          'createdAt': DateTime.now().subtract(Duration(days: 20)).toIso8601String(),
        },
        {
          'id': 'citizen_1',
          'name': 'Citizen User',
          'email': 'citizen@foodsafety.com',
          'role': 'citizen',
          'phoneNumber': '+91 9876543213',
          'isActive': true,
          'createdAt': DateTime.now().subtract(Duration(days: 15)).toIso8601String(),
        },
        {
          'id': 'citizen_2',
          'name': 'John Doe',
          'email': 'john@example.com',
          'role': 'citizen',
          'phoneNumber': '+91 9876543214',
          'isActive': true,
          'createdAt': DateTime.now().subtract(Duration(days: 10)).toIso8601String(),
        },
        {
          'id': 'citizen_3',
          'name': 'Jane Smith',
          'email': 'jane@example.com',
          'role': 'citizen',
          'phoneNumber': '+91 9876543215',
          'isActive': true,
          'createdAt': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
        },
      ];
      
      notifyListeners();
    } catch (error) {
      _error = 'Failed to fetch users: $error';
      notifyListeners();
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Update in allUsers list
      final userIndex = _allUsers.indexWhere((user) => user['id'] == userId);
      if (userIndex != -1) {
        _allUsers[userIndex]['role'] = newRole;
        
        // Also update current user if it's the same user
        if (_user?['id'] == userId) {
          _user?['role'] = newRole;
        }
        
        notifyListeners();
      }
    } catch (error) {
      _error = 'Failed to update user role: $error';
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Don't allow admin to delete themselves
      if (_user?['id'] == userId) {
        _error = 'Cannot delete your own account';
        notifyListeners();
        return;
      }
      
      _allUsers.removeWhere((user) => user['id'] == userId);
      notifyListeners();
    } catch (error) {
      _error = 'Failed to delete user: $error';
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> updatedData) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (_user != null) {
        _user = {..._user!, ...updatedData};
        
        // Also update in allUsers list if admin is viewing
        if (_user?['role'] == 'admin' || _allUsers.isNotEmpty) {
          final userIndex = _allUsers.indexWhere((u) => u['id'] == _user?['id']);
          if (userIndex != -1) {
            _allUsers[userIndex] = {..._allUsers[userIndex], ...updatedData};
          }
        }
        
        notifyListeners();
      }
    } catch (error) {
      _error = 'Failed to update profile: $error';
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Check if user has admin privileges
  bool get isAdmin => _user?['role'] == 'admin';

  // Check if user has inspector privileges
  bool get isInspector => _user?['role'] == 'inspector';

  // Check if user has citizen privileges
  bool get isCitizen => _user?['role'] == 'citizen';
}