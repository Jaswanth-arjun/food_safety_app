import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import 'rating_provider.dart';

class RestaurantProvider with ChangeNotifier {
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String? _error;
  RatingProvider? _ratingProvider;

  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with mock data
  RestaurantProvider({RatingProvider? ratingProvider}) {
    _ratingProvider = ratingProvider;
    _initializeMockData();
  }

  void _initializeMockData() {
    _restaurants = [
      Restaurant(
        id: '1',
        name: 'Food Palace',
        address: '123 Main Street, Mumbai',
        phone: '+91 9876543210',
        licenseNumber: 'FSSAI123456',
        lastInspectionScore: 85,
        lastInspectionDate: DateTime.now().subtract(const Duration(days: 15)),
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        userRating: _ratingProvider?.getAverageRating('1') ?? 0.0,
        userReviewCount: _ratingProvider?.getReviewCount('1') ?? 0,
      ),
      Restaurant(
        id: '2',
        name: 'Spice Garden',
        address: '456 Park Avenue, Delhi',
        phone: '+91 9876543211',
        licenseNumber: 'FSSAI123457',
        lastInspectionScore: 92,
        lastInspectionDate: DateTime.now().subtract(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        userRating: _ratingProvider?.getAverageRating('2') ?? 0.0,
        userReviewCount: _ratingProvider?.getReviewCount('2') ?? 0,
      ),
      Restaurant(
        id: '3',
        name: 'Burger Hub',
        address: '789 Beach Road, Goa',
        phone: '+91 9876543212',
        licenseNumber: 'FSSAI123458',
        lastInspectionScore: 45,
        lastInspectionDate: DateTime.now().subtract(const Duration(days: 60)),
        createdAt: DateTime.now().subtract(const Duration(days: 250)),
        userRating: _ratingProvider?.getAverageRating('3') ?? 0.0,
        userReviewCount: _ratingProvider?.getReviewCount('3') ?? 0,
      ),
      Restaurant(
        id: '4',
        name: 'Pizza Corner',
        address: '321 Market Street, Bangalore',
        phone: '+91 9876543213',
        licenseNumber: 'FSSAI123459',
        lastInspectionScore: 78,
        lastInspectionDate: DateTime.now().subtract(const Duration(days: 10)),
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        userRating: _ratingProvider?.getAverageRating('4') ?? 0.0,
        userReviewCount: _ratingProvider?.getReviewCount('4') ?? 0,
      ),
      Restaurant(
        id: '5',
        name: 'Noodle Bar',
        address: '654 Garden Lane, Hyderabad',
        phone: '+91 9876543214',
        licenseNumber: 'FSSAI123460',
        lastInspectionScore: 65,
        lastInspectionDate: DateTime.now().subtract(const Duration(days: 45)),
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        userRating: _ratingProvider?.getAverageRating('5') ?? 0.0,
        userReviewCount: _ratingProvider?.getReviewCount('5') ?? 0,
      ),
    ];
  }

  // Fetch restaurants (simulated API call)
  Future<void> fetchRestaurants() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      // Already initialized with mock data
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to fetch restaurants: $e';
      notifyListeners();
    }
  }

  // Add restaurant
  Future<void> addRestaurant(Restaurant restaurant) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _restaurants.add(restaurant);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add restaurant: $e';
      notifyListeners();
    }
  }

  // Update restaurant
  Future<void> updateRestaurant(Restaurant restaurant) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _restaurants.indexWhere((r) => r.id == restaurant.id);
      if (index != -1) {
        _restaurants[index] = restaurant;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update restaurant: $e';
      notifyListeners();
    }
  }

  // Delete restaurant
  Future<void> deleteRestaurant(String restaurantId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _restaurants.removeWhere((r) => r.id == restaurantId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to delete restaurant: $e';
      notifyListeners();
    }
  }

  // Update restaurant rating
  void updateRestaurantRating(String restaurantId) {
    final index = _restaurants.indexWhere((r) => r.id == restaurantId);
    if (index != -1) {
      final userRating = _ratingProvider?.getAverageRating(restaurantId) ?? 0.0;
      final userReviewCount = _ratingProvider?.getReviewCount(restaurantId) ?? 0;

      _restaurants[index] = _restaurants[index].copyWith(
        userRating: userRating,
        userReviewCount: userReviewCount,
      );
      notifyListeners();
    }
  }

  // Get restaurant by ID
  Restaurant? getRestaurantById(String id) {
    try {
      return _restaurants.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}