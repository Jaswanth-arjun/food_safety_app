import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'auth/forgot_password_screen.dart';
import '../config/constants.dart';
import '../widgets/brand_logo.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationEnabled = true;
  bool _analyticsEnabled = true;
  String _language = 'English';
  String _theme = 'Light';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = _prefs.getBool('dark_mode_enabled') ?? false;
      _locationEnabled = _prefs.getBool('location_enabled') ?? true;
      _analyticsEnabled = _prefs.getBool('analytics_enabled') ?? true;
      _language = _prefs.getString('language') ?? 'English';
      _theme = _prefs.getString('theme') ?? 'Light';
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Center(child: LogoSpinner(size: 28)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        // Use app theme for AppBar so it follows light/dark
        elevation: Theme.of(context).appBarTheme.elevation ?? 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Settings Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Account Info
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          image: (user?['profileImageUrl'] != null && (user?['profileImageUrl'] as String).isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(user?['profileImageUrl']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          gradient: (user?['profileImageUrl'] == null || (user?['profileImageUrl'] as String).isEmpty)
                              ? LinearGradient(
                                  colors: user?['role'] == 'admin'
                                      ? [Colors.deepPurple, Colors.purple]
                                      : user?['role'] == 'inspector'
                                          ? [Colors.orange, Colors.deepOrange]
                                          : [const Color(0xFF60A5FA), const Color(0xFF2563EB)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: (user?['profileImageUrl'] == null || (user?['profileImageUrl'] as String).isEmpty)
                            ? BrandLogo(size: 24, circle: true)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user?['fullName'] ?? 'User',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (user?['isVerified'] == true || user?['is_verified'] == true)
                                  const Icon(Icons.verified, color: Colors.green, size: 18),
                              ],
                            ),
                            Text(
                              user?['email'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          (user?['isVerified'] == true || user?['is_verified'] == true) ? Icons.verified : Icons.pending,
                          color: (user?['isVerified'] == true || user?['is_verified'] == true) ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          (user?['isVerified'] == true || user?['is_verified'] == true) ? 'Verified Account' : 'Pending Verification',
                          style: TextStyle(
                            color: (user?['isVerified'] == true || user?['is_verified'] == true) ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // App Preferences Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Language Setting
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.language, color: Theme.of(context).iconTheme.color),
                            const SizedBox(width: 12),
                            const Text(
                              'Language',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        DropdownButton<String>(
                          value: _language,
                          underline: const SizedBox(),
                          items: ['English', 'Hindi', 'Spanish'].map((lang) {
                            return DropdownMenuItem(value: lang, child: Text(lang));
                          }).toList(),
                          onChanged: (newLang) {
                            if (newLang != null) {
                              setState(() => _language = newLang);
                              _saveSetting('language', newLang);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Language changed to $newLang')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Theme Setting
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Consumer<ThemeProvider>(
                              builder: (_, themeProvider, __) {
                                return Icon(
                                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                                  color: const Color(0xFF64748B),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Theme',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        Consumer<ThemeProvider>(
                          builder: (_, themeProvider, __) {
                            return DropdownButton<String>(
                              value: themeProvider.isDarkMode ? 'Dark' : 'Light',
                              underline: const SizedBox(),
                              items: ['Light', 'Dark'].map((theme) {
                                return DropdownMenuItem(value: theme, child: Text(theme));
                              }).toList(),
                              onChanged: (newTheme) {
                                if (newTheme != null) {
                                  // Explicitly set theme instead of toggling so value is deterministic
                                  Provider.of<ThemeProvider>(context, listen: false)
                                      .setDarkMode(newTheme == 'Dark');
                                  _saveSetting('theme', newTheme);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Theme changed to $newTheme'),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notifications Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications & Privacy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notifications Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                            Icon(Icons.notifications, color: Theme.of(context).iconTheme.color),
                          const SizedBox(width: 12),
                          const Text(
                            'Push Notifications',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _notificationsEnabled,
                        activeColor: Colors.green,
                        onChanged: (newValue) {
                          setState(() => _notificationsEnabled = newValue);
                          _saveSetting('notifications_enabled', newValue);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_notificationsEnabled ? 'Notifications enabled' : 'Notifications disabled'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Location Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Theme.of(context).iconTheme.color),
                          const SizedBox(width: 12),
                          const Text(
                            'Location Services',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _locationEnabled,
                        activeColor: Colors.green,
                        onChanged: (newValue) {
                          setState(() => _locationEnabled = newValue);
                          _saveSetting('location_enabled', newValue);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_locationEnabled ? 'Location enabled' : 'Location disabled'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Analytics Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.analytics, color: Theme.of(context).iconTheme.color),
                          const SizedBox(width: 12),
                          const Text(
                            'Usage Analytics',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _analyticsEnabled,
                        activeColor: Colors.green,
                        onChanged: (newValue) {
                          setState(() => _analyticsEnabled = newValue);
                          _saveSetting('analytics_enabled', newValue);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_analyticsEnabled ? 'Analytics enabled' : 'Analytics disabled'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Actions Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Change Password Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to password reset (reuse forgot password screen)
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      child: Text(
                        'Change Password',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  authProvider.logout();
                                },
                                child: const Text('Logout', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    '${AppConstants.appName} v1.0.0',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2026 Food Guard Authority',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
