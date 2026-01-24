import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _user;
  String? _error;
  List<Map<String, dynamic>> _allUsers = [];
  SharedPreferences? _prefs;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  String get userRole => _user?['role'] ?? 'citizen';
  List<Map<String, dynamic>> get allUsers => _allUsers;

  // Get current user as User model (for admin dashboard)
  Map<String, dynamic>? get currentUser => _user;

  AuthProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (_prefs == null) return;

    final usersJson = _prefs!.getString('users');
    if (usersJson != null) {
      final List<dynamic> usersList = json.decode(usersJson);
      _allUsers = usersList.map((user) => Map<String, dynamic>.from(user)).toList();
    }
    // No demo users initialization - start with empty user list
    notifyListeners();
  }

  Future<void> _saveUsers() async {
    if (_prefs == null) return;

    final usersJson = json.encode(_allUsers);
    await _prefs!.setString('users', usersJson);
  }

  Future<bool> login(String email, String password, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Validate input
    if (email.isEmpty || password.isEmpty) {
      _error = 'Please fill in all fields';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _error = 'Please enter a valid email address';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Find user by email
    final user = _allUsers.firstWhere(
      (user) => user['email'] == email,
      orElse: () => {},
    );

    if (user.isEmpty) {
      _error = 'No account found with this email address';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Check password
    if (user['password'] != password) {
      _error = 'Incorrect password';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Check role
    if (user['role'] != role) {
      _error = 'Account role does not match selected role';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Check if account is active
    if (!user['isActive']) {
      _error = 'Account is deactivated. Please contact support.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Login successful
    _user = Map<String, dynamic>.from(user);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Citizen Registration (normal registration)
  Future<bool> registerCitizen({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // Validate input
    if (email.isEmpty || password.isEmpty || fullName.isEmpty || phoneNumber.isEmpty) {
      _error = 'Please fill in all fields';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _error = 'Please enter a valid email address';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Password validation
    if (password.length < 6) {
      _error = 'Password must be at least 6 characters long';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Phone validation
    final phoneRegex = RegExp(r'^\+91\s\d{10}$');
    if (!phoneRegex.hasMatch(phoneNumber)) {
      _error = 'Please enter a valid phone number (+91 XXXXXXXXXX)';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Check if email already exists
    final existingUser = _allUsers.firstWhere(
      (user) => user['email'] == email,
      orElse: () => {},
    );

    if (existingUser.isNotEmpty) {
      _error = 'Email already registered';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Create new citizen user
    final newUser = {
      'id': 'citizen_${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'password': password, // In production, hash this
      'name': fullName,
      'fullName': fullName,
      'role': 'citizen',
      'phoneNumber': phoneNumber,
      'isActive': true,
      'isVerified': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    _allUsers.add(newUser);
    await _saveUsers();
    _user = newUser;

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Inspector Registration (requires special registration code)
  Future<bool> registerInspector({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String registrationCode,
    String department = 'Food Safety Department',
    required String licenseNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // Validate input
    if (email.isEmpty || password.isEmpty || fullName.isEmpty || phoneNumber.isEmpty ||
        registrationCode.isEmpty || licenseNumber.isEmpty) {
      _error = 'Please fill in all fields';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _error = 'Please enter a valid email address';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Password validation
    if (password.length < 6) {
      _error = 'Password must be at least 6 characters long';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Phone validation
    final phoneRegex = RegExp(r'^\+91\s\d{10}$');
    if (!phoneRegex.hasMatch(phoneNumber)) {
      _error = 'Please enter a valid phone number (+91 XXXXXXXXXX)';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Validate FSSAI license number (14-digit number)
    final licenseRegex = RegExp(r'^\d{14}$');
    if (!licenseRegex.hasMatch(registrationCode)) {
      _error = 'Please enter a valid 14-digit FSSAI license number';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Check if email already exists
    final existingUser = _allUsers.firstWhere(
      (user) => user['email'] == email,
      orElse: () => {},
    );

    if (existingUser.isNotEmpty) {
      _error = 'Email already registered';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Create new inspector user
    final newUser = {
      'id': 'inspector_${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'password': password, // In production, hash this
      'name': fullName,
      'fullName': fullName,
      'role': 'inspector',
      'phoneNumber': phoneNumber,
      'department': department,
      'licenseNumber': licenseNumber,
      'isActive': true,
      'isVerified': true, // Auto-verified for inspectors
      'createdAt': DateTime.now().toIso8601String(),
    };

    _allUsers.add(newUser);
    await _saveUsers();
    _user = newUser;

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Admin Registration (requires admin approval or special code)
  Future<bool> registerAdmin({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String adminCode,
    required String organization,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // Validate input
    if (email.isEmpty || password.isEmpty || fullName.isEmpty || phoneNumber.isEmpty ||
        adminCode.isEmpty || organization.isEmpty) {
      _error = 'Please fill in all fields';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _error = 'Please enter a valid email address';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Password validation
    if (password.length < 6) {
      _error = 'Password must be at least 6 characters long';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Phone validation
    final phoneRegex = RegExp(r'^\+91\s\d{10}$');
    if (!phoneRegex.hasMatch(phoneNumber)) {
      _error = 'Please enter a valid phone number (+91 XXXXXXXXXX)';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Validate admin code (mock validation)
    const validAdminCodes = ['ADMIN2024', 'SUPERADMIN', 'FSSAISUPER'];
    if (!validAdminCodes.contains(adminCode)) {
      _error = 'Invalid admin registration code. Access denied.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Check if email already exists
    final existingUser = _allUsers.firstWhere(
      (user) => user['email'] == email,
      orElse: () => {},
    );

    if (existingUser.isNotEmpty) {
      _error = 'Email already registered';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Create new admin user
    final newUser = {
      'id': 'admin_${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'password': password, // In production, hash this
      'name': fullName,
      'fullName': fullName,
      'role': 'admin',
      'phoneNumber': phoneNumber,
      'organization': organization,
      'isActive': true,
      'isVerified': true, // Auto-verified for admins
      'createdAt': DateTime.now().toIso8601String(),
    };

    _allUsers.add(newUser);
    await _saveUsers();
    _user = newUser;

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _user = null;
    _error = null;
    // Don't clear _allUsers on logout, they are persisted
    notifyListeners();
  }

  // Admin functions
  Future<void> fetchAllUsers() async {
    try {
      // Users are already loaded from shared preferences
      // This method ensures users are up to date
      await Future.delayed(const Duration(milliseconds: 300));
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

        await _saveUsers();
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