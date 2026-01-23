class User {
  final String id;
  final String email;
  final String fullName;
  final String name; // Added for compatibility with admin dashboard
  final String role; // 'citizen', 'inspector', 'admin'
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final List<String> permissions;
  final Map<String, dynamic>? metadata;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    required this.isActive,
    this.isVerified = false,
    required this.createdAt,
    this.lastLoginAt,
    this.permissions = const [],
    this.metadata,
  }) : name = fullName; // Initialize name from fullName

  // Get display name (first name or full name)
  String get displayName {
    final parts = fullName.split(' ');
    return parts.isNotEmpty ? parts[0] : fullName;
  }

  // Get initials for avatar
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (fullName.isNotEmpty) {
      return fullName.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  // Check if user has admin role
  bool get isAdmin => role.toLowerCase() == 'admin';

  // Check if user has inspector role
  bool get isInspector => role.toLowerCase() == 'inspector';

  // Check if user has citizen role
  bool get isCitizen => role.toLowerCase() == 'citizen';

  // Get role display name
  String get roleDisplayName {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'inspector':
        return 'Food Safety Inspector';
      case 'citizen':
        return 'Citizen Reporter';
      default:
        return role;
    }
  }

  // Get role color for UI
  int get roleColor {
    switch (role.toLowerCase()) {
      case 'admin':
        return 0xFF6A0DAD; // Deep purple
      case 'inspector':
        return 0xFF2196F3; // Blue
      case 'citizen':
        return 0xFF4CAF50; // Green
      default:
        return 0xFF757575; // Grey
    }
  }

  // Formatted creation date
  String get formattedCreatedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Today';
    }
  }

  // Check if user is online (within last 5 minutes)
  bool get isOnline {
    if (lastLoginAt == null) return false;
    final now = DateTime.now();
    return now.difference(lastLoginAt!).inMinutes < 5;
  }

  // Copy with method for updates
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? name,
    String? role,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? permissions,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      permissions: permissions ?? this.permissions,
      metadata: metadata ?? this.metadata,
    );
  }

  // Factory method to create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 
                json['full_name']?.toString() ?? 
                json['name']?.toString() ?? 
                'Unknown User',
      role: json['role']?.toString()?.toLowerCase() ?? 'citizen',
      phoneNumber: json['phoneNumber']?.toString() ?? 
                   json['phone_number']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString() ?? 
                       json['profile_image_url']?.toString(),
      isActive: json['isActive'] ?? 
                json['is_active'] ?? 
                json['active'] ?? 
                true,
      isVerified: json['isVerified'] ?? 
                  json['is_verified'] ?? 
                  json['verified'] ?? 
                  false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'].toString())
              : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'].toString())
          : json['last_login_at'] != null
              ? DateTime.parse(json['last_login_at'].toString())
              : null,
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'])
          : json['permission'] != null
              ? [json['permission'].toString()]
              : [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'name': name,
      'role': role,
      'phone_number': phoneNumber,
      'profile_image_url': profileImageUrl,
      'is_active': isActive,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'permissions': permissions,
      if (metadata != null) 'metadata': metadata,
    };
  }

  // Convert to simple map for local storage
  Map<String, dynamic> toSimpleMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Check if user has specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission) ||
           (isAdmin && permission.startsWith('admin.')) ||
           (isInspector && permission.startsWith('inspector.')) ||
           (isCitizen && permission.startsWith('citizen.'));
  }

  // Get default permissions based on role
  List<String> get defaultPermissions {
    switch (role.toLowerCase()) {
      case 'admin':
        return [
          'admin.dashboard',
          'admin.users.manage',
          'admin.reports.review',
          'admin.restaurants.manage',
          'admin.analytics.view',
          'admin.settings.manage',
          'inspector.checklist.create',
          'citizen.report.create',
        ];
      case 'inspector':
        return [
          'inspector.dashboard',
          'inspector.checklist.create',
          'inspector.restaurants.view',
          'inspector.reports.view',
          'inspector.history.view',
          'citizen.report.create',
        ];
      case 'citizen':
        return [
          'citizen.dashboard',
          'citizen.report.create',
          'citizen.restaurants.view',
          'citizen.history.view',
          'citizen.profile.edit',
        ];
      default:
        return ['citizen.dashboard', 'citizen.report.create'];
    }
  }

  // Static method to create empty user
  static User empty() {
    return User(
      id: '',
      email: '',
      fullName: 'Guest User',
      role: 'citizen',
      isActive: false,
      createdAt: DateTime.now(),
      isVerified: false,
    );
  }

  // Check if user is empty
  bool get isEmpty => id.isEmpty;

  // Equality check
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  // toString method for debugging
  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $fullName, role: $role)';
  }
}