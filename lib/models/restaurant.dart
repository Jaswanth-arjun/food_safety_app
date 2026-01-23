class Restaurant {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String licenseNumber;
  final int? lastInspectionScore;
  final DateTime? lastInspectionDate;
  final DateTime createdAt;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? phoneNumber;
  final String? email;
  final String? ownerName;
  final double? latitude;
  final double? longitude;
  final bool? isActive;
  final DateTime? updatedAt;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    this.phone = '',
    this.licenseNumber = '',
    this.lastInspectionScore,
    this.lastInspectionDate,
    required this.createdAt,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.phoneNumber,
    this.email,
    this.ownerName,
    this.latitude,
    this.longitude,
    this.isActive,
    this.updatedAt,
  });

  // Formatted date for display
  String get formattedLastInspectionDate {
    if (lastInspectionDate == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(lastInspectionDate!);
    
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

  // Copy with method
  Restaurant copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? licenseNumber,
    int? lastInspectionScore,
    DateTime? lastInspectionDate,
    DateTime? createdAt,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phoneNumber,
    String? email,
    String? ownerName,
    double? latitude,
    double? longitude,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      lastInspectionScore: lastInspectionScore ?? this.lastInspectionScore,
      lastInspectionDate: lastInspectionDate ?? this.lastInspectionDate,
      createdAt: createdAt ?? this.createdAt,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      ownerName: ownerName ?? this.ownerName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}