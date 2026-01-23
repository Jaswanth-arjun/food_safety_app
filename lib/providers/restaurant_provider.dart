import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class RestaurantProvider with ChangeNotifier {
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String? _error;

  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with mock data
  RestaurantProvider() {
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