class Restaurant {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String licenseNumber;
  final int? lastInspectionScore;
  final DateTime? lastInspectionDate;
  final DateTime createdAt;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    this.phone = '',
    this.licenseNumber = '',
    this.lastInspectionScore,
    this.lastInspectionDate,
    required this.createdAt,
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
    );
  }
}