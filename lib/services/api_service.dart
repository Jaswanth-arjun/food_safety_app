import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = 'http://localhost:8000';
  late Dio _dio;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try to refresh
          final refreshToken = prefs.getString('refresh_token');
          if (refreshToken != null) {
            try {
              final newToken = await refreshAccessToken(refreshToken);
              if (newToken != null) {
                // Retry the original request
                error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                return handler.resolve(await _dio.fetch(error.requestOptions));
              }
            } catch (e) {
              // Refresh failed, logout
              await prefs.clear();
              // Navigate to login (you'll need to handle this in UI)
            }
          }
        }
        return handler.next(error);
      },
    ));
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access_token']);
        await prefs.setString('user_data', json.encode(data['user']));
        
        return {'success': true, 'data': data};
      }
      return {'success': false, 'error': 'Invalid credentials'};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data?['detail'] ?? 'Login failed'};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: userData,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access_token']);
        await prefs.setString('user_data', json.encode(data['user']));
        
        return {'success': true, 'data': data};
      }
      return {'success': false, 'error': 'Registration failed'};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data?['detail'] ?? 'Registration failed'};
    }
  }

  // Restaurants
  Future<Map<String, dynamic>> getRestaurants({
    String? city,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/restaurants/',
        queryParameters: {
          'city': city,
          'search': search,
          'limit': limit,
          'offset': offset,
        },
      );
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data?['detail'] ?? 'Failed to fetch restaurants'};
    }
  }

  Future<Map<String, dynamic>> getRestaurant(String id) async {
    try {
      final response = await _dio.get('/api/restaurants/$id');
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data?['detail'] ?? 'Failed to fetch restaurant'};
    }
  }

  // Inspections
  Future<Map<String, dynamic>> getInspections({
    String? restaurantId,
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/inspections/',
        queryParameters: {
          'restaurant_id': restaurantId,
          'status': status,
          'limit': limit,
          'offset': offset,
        },
      );
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data?['detail'] ?? 'Failed to fetch inspections'};
    }
  }

  Future<Map<String, dynamic>> createInspection(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/inspections/', data: data);
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data?['detail'] ?? 'Failed to create inspection'};
    }
  }

  // Citizen Reports
  Future<Map<String, dynamic>> createReport(
    Map<String, dynamic> reportData,
    List<File>? images,
  ) async {
    try {
      if (images != null && images.isNotEmpty) {
        // Upload images first
        final imageUrls = <String>[];
        for (final image in images) {
          final uploadResult = await uploadImage(image, 'citizen-reports');
          if (uploadResult['success']) {
            imageUrls.add(uploadResult['image_url']);
          }
        }
        reportData['image_urls'] = imageUrls;
      }

      final response = await _dio.post('/api/reports/', data: reportData);
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data?['detail'] ?? 'Failed to create report'};
    }
  }

  // AI Scoring
  Future<Map<String, dynamic>> analyzeHygieneImage(File image) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: 'hygiene_image.jpg',
        ),
      });

      final response = await _dio.post(
        '/api/ai/analyze-hygiene',
        data: formData,
      );
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data?['detail'] ?? 'Failed to analyze image'};
    }
  }

  // Image Upload
  Future<Map<String, dynamic>> uploadImage(File image, String folder) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio.post(
        '/api/inspections/upload-evidence',
        data: formData,
      );
      return {'success': true, 'image_url': response.data['image_url']};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data?['detail'] ?? 'Failed to upload image'};
    }
  }

  // Helper Methods
  Future<String?> refreshAccessToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/api/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      
      if (response.statusCode == 200) {
        final newToken = response.data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', newToken);
        return newToken;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/logout');
    } catch (e) {
      // Ignore errors during logout
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }
}