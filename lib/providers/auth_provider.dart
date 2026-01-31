import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:food_guard/services/supabase_service.dart';
import 'package:food_guard/config/constants.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _user;
  String? _error;
  List<Map<String, dynamic>> _allUsers = [];

  // Development mode flag - set to true to bypass email confirmation
  static const bool _isDevelopmentMode = true;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  String get userRole => _user?['role'] ?? 'citizen';
  List<Map<String, dynamic>> get allUsers => _allUsers;

  // Get current user as User model (for admin dashboard)
  Map<String, dynamic>? get currentUser => _user;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    // Listen to auth state changes
    SupabaseService.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedIn) {
        _loadUserProfile();
      } else if (event.event == AuthChangeEvent.signedOut) {
        _user = null;
        notifyListeners();
      }
    });

    // Check if user is already signed in
    final currentUser = SupabaseService.client.auth.currentUser;
    if (currentUser != null) {
      await _loadUserProfile();
    }
  }

  Future<void> _confirmUserEmail(String userId) async {
    try {
      // Use admin client to confirm the user's email
      await SupabaseService.adminClient.auth.admin.updateUserById(
        userId,
        attributes: AdminUserAttributes(emailConfirm: true),
      );
    } catch (e) {
      // If admin confirmation fails, we'll rely on the user being able to login
      // This might happen if service role key is not set properly
      print('Admin confirmation failed: $e');
    }
  }

  Future<void> _loadUserProfile({String? userId}) async {
    try {
      // Use provided userId or get from current user
      final id = userId ?? SupabaseService.client.auth.currentUser?.id;
      
      if (id == null) {
        _error = 'User not authenticated. Please sign in again.';
        notifyListeners();
        return;
      }

      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', id)
          .single();

      _user = Map<String, dynamic>.from(response);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user profile: $e';
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
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

      // Sign in with Supabase
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        _error = 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Load user profile
      await _loadUserProfile();

      // Check role
      if (_user?['role'] != role) {
        _error = 'Account role does not match selected role';
        await logout();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if account is active
      if (!(_user?['is_active'] ?? true)) {
        _error = 'Account is deactivated. Please contact support.';
        await logout();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if account is verified
      if (!(_user?['is_verified'] ?? false)) {
        _error = 'Account is not verified. Please contact support for verification.';
        await logout();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Citizen Registration
  Future<bool> registerCitizen({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
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

      // Sign up with Supabase
      final authResponse = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: _isDevelopmentMode ? {'email_confirm': true} : null,
      );

      if (authResponse.user == null) {
        _error = 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // In development mode, skip email confirmation and create profile directly
      if (_isDevelopmentMode) {
        // Check if service role key is configured
        if (AppConstants.supabaseServiceRoleKey == 'YOUR_SERVICE_ROLE_KEY_HERE') {
          _error = 'Service role key not configured. Please add your Supabase service role key to constants.dart';
          // Delete the user from auth since profile creation will fail
          await SupabaseService.client.auth.signOut();
          _isLoading = false;
          notifyListeners();
          return false;
        }

        try {
          // Create profile using admin client (bypasses RLS)
          await SupabaseService.adminClient
              .from('profiles')
              .insert({
                'id': authResponse.user!.id,
                'email': email,
                'full_name': fullName,
                'phone': phoneNumber,
                'role': 'citizen',
                'is_verified': true,
              });
        } catch (profileError) {
          _error = 'Failed to create user profile: $profileError';
          // Delete the user from auth since profile creation failed
          try {
            await SupabaseService.adminClient.auth.admin.deleteUser(authResponse.user!.id);
          } catch (e) {
            print('Failed to delete auth user: $e');
          }
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Load user profile
        await _loadUserProfile(userId: authResponse.user!.id);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Production mode: Use admin confirmation
      // Check if service role key is configured
      if (AppConstants.supabaseServiceRoleKey == 'YOUR_SERVICE_ROLE_KEY_HERE') {
        _error = 'Service role key not configured. Please add your Supabase service role key to constants.dart';
        // Delete the user from auth since profile creation will fail
        await SupabaseService.client.auth.signOut();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      try {
        // Create profile using admin client (bypasses RLS)
        await SupabaseService.adminClient
            .from('profiles')
            .insert({
              'id': authResponse.user!.id,
              'email': email,
              'full_name': fullName,
              'phone': phoneNumber,
              'role': 'citizen',
              'is_verified': true,
            });
      } catch (profileError) {
        _error = 'Failed to create user profile: $profileError';
        // Delete the user from auth since profile creation failed
        try {
          await SupabaseService.adminClient.auth.admin.deleteUser(authResponse.user!.id);
        } catch (e) {
          print('Failed to delete auth user: $e');
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Confirm user email to allow immediate login
      await _confirmUserEmail(authResponse.user!.id);

      // Load user profile
      await _loadUserProfile(userId: authResponse.user!.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Inspector Registration
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

    try {
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

      // Validate FSSAI license number
      final licenseRegex = RegExp(r'^\d{14}$');
      if (!licenseRegex.hasMatch(registrationCode)) {
        _error = 'Please enter a valid 14-digit FSSAI license number';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Sign up with Supabase
      final authResponse = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: _isDevelopmentMode ? {'email_confirm': true} : null,
      );

      if (authResponse.user == null) {
        _error = 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // In development mode, skip email confirmation and create profile directly
      if (_isDevelopmentMode) {
        // Check if service role key is configured
        if (AppConstants.supabaseServiceRoleKey == 'YOUR_SERVICE_ROLE_KEY_HERE') {
          _error = 'Service role key not configured. Please add your Supabase service role key to constants.dart';
          // Delete the user from auth since profile creation will fail
          await SupabaseService.client.auth.signOut();
          _isLoading = false;
          notifyListeners();
          return false;
        }

        try {
          // Create profile using admin client (bypasses RLS)
          await SupabaseService.adminClient
              .from('profiles')
              .insert({
                'id': authResponse.user!.id,
                'email': email,
                'full_name': fullName,
                'phone': phoneNumber,
                'role': 'inspector',
                'department': department,
                'license_number': licenseNumber,
                'is_verified': true,
              });
        } catch (profileError) {
          _error = 'Failed to create user profile: $profileError';
          // Delete the user from auth since profile creation failed
          try {
            await SupabaseService.adminClient.auth.admin.deleteUser(authResponse.user!.id);
          } catch (e) {
            print('Failed to delete auth user: $e');
          }
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Load user profile
        await _loadUserProfile(userId: authResponse.user!.id);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Production mode: Use admin confirmation
      // Check if service role key is configured
      if (AppConstants.supabaseServiceRoleKey == 'YOUR_SERVICE_ROLE_KEY_HERE') {
        _error = 'Service role key not configured. Please add your Supabase service role key to constants.dart';
        // Delete the user from auth since profile creation will fail
        await SupabaseService.client.auth.signOut();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      try {
        // Create profile using admin client (bypasses RLS)
        await SupabaseService.adminClient
            .from('profiles')
            .insert({
              'id': authResponse.user!.id,
              'email': email,
              'full_name': fullName,
              'phone': phoneNumber,
              'role': 'inspector',
              'department': department,
              'license_number': licenseNumber,
              'is_verified': true,
            });
      } catch (profileError) {
        _error = 'Failed to create user profile: $profileError';
        // Delete the user from auth since profile creation failed
        try {
          await SupabaseService.adminClient.auth.admin.deleteUser(authResponse.user!.id);
        } catch (e) {
          print('Failed to delete auth user: $e');
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Confirm user email to allow immediate login
      await _confirmUserEmail(authResponse.user!.id);

      // Load user profile
      await _loadUserProfile(userId: authResponse.user!.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Admin Registration
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

    try {
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

      // Validate admin code
      const validAdminCodes = ['ADMIN2024', 'SUPERADMIN', 'FSSAISUPER'];
      if (!validAdminCodes.contains(adminCode)) {
        _error = 'Invalid admin registration code. Access denied.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Sign up with Supabase
      final authResponse = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: _isDevelopmentMode ? {'email_confirm': true} : null,
      );

      if (authResponse.user == null) {
        _error = 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // In development mode, skip email confirmation and create profile directly
      if (_isDevelopmentMode) {
        // Check if service role key is configured
        if (AppConstants.supabaseServiceRoleKey == 'YOUR_SERVICE_ROLE_KEY_HERE') {
          _error = 'Service role key not configured. Please add your Supabase service role key to constants.dart';
          // Delete the user from auth since profile creation will fail
          await SupabaseService.client.auth.signOut();
          _isLoading = false;
          notifyListeners();
          return false;
        }

        try {
          // Create profile using admin client (bypasses RLS)
          await SupabaseService.adminClient
              .from('profiles')
              .insert({
                'id': authResponse.user!.id,
                'email': email,
                'full_name': fullName,
                'phone': phoneNumber,
                'role': 'admin',
                'organization': organization,
                'is_verified': true,
              });
        } catch (profileError) {
          _error = 'Failed to create user profile: $profileError';
          // Delete the user from auth since profile creation failed
          try {
            await SupabaseService.adminClient.auth.admin.deleteUser(authResponse.user!.id);
          } catch (e) {
            print('Failed to delete auth user: $e');
          }
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Load user profile
        await _loadUserProfile(userId: authResponse.user!.id);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Production mode: Use admin confirmation
      // Check if service role key is configured
      if (AppConstants.supabaseServiceRoleKey == 'YOUR_SERVICE_ROLE_KEY_HERE') {
        _error = 'Service role key not configured. Please add your Supabase service role key to constants.dart';
        // Delete the user from auth since profile creation will fail
        await SupabaseService.client.auth.signOut();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      try {
        // Create profile using admin client (bypasses RLS)
        await SupabaseService.adminClient
            .from('profiles')
            .insert({
              'id': authResponse.user!.id,
              'email': email,
              'full_name': fullName,
              'phone': phoneNumber,
              'role': 'admin',
              'organization': organization,
              'is_verified': true,
            });
      } catch (profileError) {
        _error = 'Failed to create user profile: $profileError';
        // Delete the user from auth since profile creation failed
        try {
          await SupabaseService.adminClient.auth.admin.deleteUser(authResponse.user!.id);
        } catch (e) {
          print('Failed to delete auth user: $e');
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Confirm user email to allow immediate login
      await _confirmUserEmail(authResponse.user!.id);

      // Load user profile
      await _loadUserProfile(userId: authResponse.user!.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await SupabaseService.client.auth.signOut();
    _user = null;
    _error = null;
    notifyListeners();
  }

  /// Send a password reset email using Supabase auth
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Basic validation to avoid complex regex mangling during automated edits
    if (!email.contains('@') || !email.contains('.')) {
      _error = 'Please enter a valid email address';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      await SupabaseService.client.auth.resetPasswordForEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to send reset email: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Admin methods
  Future<void> fetchAllUsers() async {
    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select();

      _allUsers = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch users: $e';
      notifyListeners();
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await SupabaseService.client
          .from('profiles')
          .update({'role': newRole})
          .eq('id', userId);

      // Refresh users list
      await fetchAllUsers();
    } catch (e) {
      _error = 'Failed to update user role: $e';
      notifyListeners();
    }
  }

  Future<void> verifyUser(String userId, bool isVerified) async {
    try {
      await SupabaseService.client
          .from('profiles')
          .update({'is_verified': isVerified})
          .eq('id', userId);

      // Refresh users list
      await fetchAllUsers();
    } catch (e) {
      _error = 'Failed to verify user: $e';
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await SupabaseService.client
          .from('profiles')
          .delete()
          .eq('id', userId);

      // Refresh users list
      await fetchAllUsers();
    } catch (e) {
      _error = 'Failed to delete user: $e';
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    if (_user == null) return;

    try {
      await SupabaseService.client
          .from('profiles')
          .update(updates)
          .eq('id', _user!['id']);

      // Reload profile
      await _loadUserProfile();
    } catch (e) {
      _error = 'Failed to update profile: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}