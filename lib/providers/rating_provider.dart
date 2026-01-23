import 'package:flutter/foundation.dart';
import '../models/user_review.dart';
import '../models/restaurant.dart';
import '../services/mock_data.dart';

class RatingProvider with ChangeNotifier {
  List<UserReview> _reviews = [];
  bool _isLoading = false;

  List<UserReview> get reviews => _reviews;
  bool get isLoading => _isLoading;

  RatingProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _reviews = MockDataService.getUserReviews();
    notifyListeners();
  }

  // Get reviews for a specific restaurant
  List<UserReview> getReviewsForRestaurant(String restaurantId) {
    return _reviews.where((review) => review.restaurantId == restaurantId).toList();
  }

  // Get average rating for a restaurant
  double getAverageRating(String restaurantId) {
    final restaurantReviews = getReviewsForRestaurant(restaurantId);
    if (restaurantReviews.isEmpty) return 0.0;

    final totalRating = restaurantReviews.fold<double>(0.0, (sum, review) => sum + review.rating);
    return totalRating / restaurantReviews.length;
  }

  // Get total number of reviews for a restaurant
  int getReviewCount(String restaurantId) {
    return getReviewsForRestaurant(restaurantId).length;
  }

  // Add a new review
  Future<bool> addReview(UserReview review) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if user already reviewed this restaurant
      final existingReviewIndex = _reviews.indexWhere(
        (r) => r.restaurantId == review.restaurantId && r.userId == review.userId,
      );

      if (existingReviewIndex != -1) {
        // Update existing review
        _reviews[existingReviewIndex] = review.copyWith(updatedAt: DateTime.now());
      } else {
        // Add new review
        _reviews.add(review);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding review: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if user has already reviewed a restaurant
  bool hasUserReviewed(String restaurantId, String userId) {
    return _reviews.any((review) =>
        review.restaurantId == restaurantId && review.userId == userId);
  }

  // Get user's review for a restaurant
  UserReview? getUserReview(String restaurantId, String userId) {
    try {
      return _reviews.firstWhere((review) =>
          review.restaurantId == restaurantId && review.userId == userId);
    } catch (e) {
      return null;
    }
  }
}