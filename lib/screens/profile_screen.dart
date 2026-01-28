import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import 'package:path/path.dart' as path;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;
  late TextEditingController _licenseController;
  late TextEditingController _organizationController;

  bool _isEditing = false;
  bool _isLoading = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?['fullName'] ?? '');
    _emailController = TextEditingController(text: user?['email'] ?? '');
    _phoneController = TextEditingController(text: user?['phoneNumber'] ?? '');
    _departmentController = TextEditingController(text: user?['department'] ?? '');
    _licenseController = TextEditingController(text: user?['licenseNumber'] ?? '');
    _organizationController = TextEditingController(text: user?['organization'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _licenseController.dispose();
    _organizationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _profileImage = null;
                  });
                },
              ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    Map<String, dynamic> updatedData = {
      'fullName': _nameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
    };

    // Handle image upload
    if (_profileImage != null) {
      try {
        final fileName = 'profile_${user?['id']}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = 'profile_images/$fileName';

        // Upload image to Supabase storage
        await SupabaseService.client.storage.from('avatars').upload(
          filePath,
          _profileImage!,
        );

        // Get public URL
        final imageUrl = SupabaseService.client.storage
            .from('avatars')
            .getPublicUrl(filePath);

        updatedData['profileImageUrl'] = imageUrl;
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }
    }

    // Add role-specific fields
    if (user?['role'] == 'inspector') {
      updatedData.addAll({
        'department': _departmentController.text.trim(),
        'licenseNumber': _licenseController.text.trim(),
      });
    } else if (user?['role'] == 'admin') {
      updatedData['organization'] = _organizationController.text.trim();
    }

    await authProvider.updateUserProfile(updatedData);

    if (authProvider.error == null) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final role = user?['role'] ?? 'citizen';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF2563EB)),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                ),
                TextButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save', style: TextStyle(color: Color(0xFF2563EB))),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: _profileImage != null
                                ? DecorationImage(
                                    image: FileImage(_profileImage!),
                                    fit: BoxFit.cover,
                                  )
                                : (user?['profileImageUrl'] != null && (user?['profileImageUrl'] as String).isNotEmpty)
                                    ? DecorationImage(
                                        image: NetworkImage(user?['profileImageUrl']),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                            gradient: (_profileImage == null && (user?['profileImageUrl'] == null || (user?['profileImageUrl'] as String).isEmpty))
                                ? LinearGradient(
                                    colors: role == 'admin'
                                        ? [Colors.deepPurple, Colors.purple]
                                        : role == 'inspector'
                                            ? [Colors.orange, Colors.deepOrange]
                                            : [const Color(0xFF60A5FA), const Color(0xFF2563EB)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: (role == 'admin'
                                    ? Colors.deepPurple
                                    : role == 'inspector'
                                        ? Colors.orange
                                        : const Color(0xFF2563EB)).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 4,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: (_profileImage == null && (user?['profileImageUrl'] == null || (user?['profileImageUrl'] as String).isEmpty))
                              ? Icon(
                                  role == 'admin'
                                      ? Icons.admin_panel_settings
                                      : role == 'inspector'
                                          ? Icons.search
                                          : Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        // Verified Badge
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: (user?['isVerified'] == true || user?['is_verified'] == true) ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              (user?['isVerified'] == true || user?['is_verified'] == true) ? Icons.check : Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImagePickerOptions,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user?['fullName'] ?? 'User',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (user?['isVerified'] == true || user?['is_verified'] == true)
                          const Tooltip(
                            message: 'Verified Account',
                            child: Icon(Icons.verified, color: Colors.green, size: 24),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: role == 'admin'
                            ? Colors.deepPurple.withOpacity(0.1)
                            : role == 'inspector'
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        role[0].toUpperCase() + role.substring(1),
                        style: TextStyle(
                          color: role == 'admin'
                              ? Colors.deepPurple
                              : role == 'inspector'
                                  ? Colors.orange
                                  : Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Profile Form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Full Name
                    TextFormField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline, color: Color(0xFF94A3B8)),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Email (read-only)
                    TextFormField(
                      controller: _emailController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF94A3B8)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Phone Number
                    TextFormField(
                      controller: _phoneController,
                      enabled: _isEditing,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined, color: Color(0xFF94A3B8)),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your phone number';
                        }
                        final phoneRegex = RegExp(r'^\+91\s\d{10}$');
                        if (!phoneRegex.hasMatch(value!)) {
                          return 'Please enter a valid phone number (+91 XXXXXXXXXX)';
                        }
                        return null;
                      },
                    ),

                    // Role-specific fields
                    if (role == 'inspector') ...[
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _departmentController,
                        enabled: _isEditing,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          prefixIcon: Icon(Icons.business_outlined, color: Color(0xFF94A3B8)),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your department';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _licenseController,
                        enabled: _isEditing,
                        decoration: const InputDecoration(
                          labelText: 'License Number',
                          prefixIcon: Icon(Icons.badge_outlined, color: Color(0xFF94A3B8)),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your license number';
                          }
                          return null;
                        },
                      ),
                    ],

                    if (role == 'admin') ...[
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _organizationController,
                        enabled: _isEditing,
                        decoration: const InputDecoration(
                          labelText: 'Organization',
                          prefixIcon: Icon(Icons.business_outlined, color: Color(0xFF94A3B8)),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your organization';
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Account Info (read-only)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                (user?['isVerified'] == true || user?['is_verified'] == true) ? Icons.verified : Icons.pending,
                                size: 20,
                                color: (user?['isVerified'] == true || user?['is_verified'] == true) ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                (user?['isVerified'] == true || user?['is_verified'] == true) ? 'Verified Account' : 'Unverified Account',
                                style: TextStyle(
                                  color: (user?['isVerified'] == true || user?['is_verified'] == true) ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Member since ${user?['createdAt'] != null ? DateTime.parse(user!['createdAt'].toString()).toString().split(' ')[0] : 'Unknown'}',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}