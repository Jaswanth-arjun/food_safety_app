class UserReview {
  final String id;
  final String restaurantId;
  final String userId;
  final String userName;
  final double rating; // 1-5 stars
  final String? reviewText;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserReview({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.reviewText,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserReview.fromJson(Map<String, dynamic> json) {
    return UserReview(
      id: json['id'] ?? '',
      restaurantId: json['restaurant_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : 0.0,
      reviewText: json['review_text'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'review_text': reviewText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserReview copyWith({
    String? id,
    String? restaurantId,
    String? userId,
    String? userName,
    double? rating,
    String? reviewText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserReview(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}