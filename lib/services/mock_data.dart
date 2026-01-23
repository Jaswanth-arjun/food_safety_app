import 'package:food_safety_app/models/restaurant.dart';
import 'package:food_safety_app/models/inspection.dart';
import 'package:food_safety_app/models/report.dart';
import 'package:food_safety_app/models/rating.dart';

class MockDataService {
  // Mock Restaurants
  static List<Restaurant> getRestaurants() {
    return [
      Restaurant(
        id: '1',
        name: 'Food Haven Restaurant',
        address: '123 Main Street, Colaba',
        city: 'Mumbai',
        state: 'Maharashtra',
        postalCode: '400001',
        country: 'India',
        phoneNumber: '+91 9876543210',
        email: 'contact@foodhaven.com',
        ownerName: 'Rajesh Kumar',
        licenseNumber: 'FSSAI123456',
        latitude: 18.9204,
        longitude: 72.8301,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Restaurant(
        id: '2',
        name: 'Spice Palace',
        address: '456 Park Avenue, Connaught Place',
        city: 'Delhi',
        state: 'Delhi',
        postalCode: '110001',
        country: 'India',
        phoneNumber: '+91 9876543211',
        email: 'info@spicepalace.com',
        ownerName: 'Priya Sharma',
        licenseNumber: 'FSSAI123457',
        latitude: 28.6139,
        longitude: 77.2090,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Restaurant(
        id: '3',
        name: 'Ocean View Cafe',
        address: '789 Beach Road, Calangute',
        city: 'Goa',
        state: 'Goa',
        postalCode: '403516',
        country: 'India',
        phoneNumber: '+91 9876543212',
        email: 'hello@oceanview.com',
        ownerName: 'Sunil D\'Souza',
        licenseNumber: 'FSSAI123458',
        latitude: 15.4909,
        longitude: 73.8278,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Restaurant(
        id: '4',
        name: 'Quick Bites Fast Food',
        address: '321 Market Street, MG Road',
        city: 'Bangalore',
        state: 'Karnataka',
        postalCode: '560001',
        country: 'India',
        phoneNumber: '+91 9876543213',
        email: 'support@quickbites.com',
        ownerName: 'Arun Patel',
        licenseNumber: 'FSSAI123459',
        latitude: 12.9716,
        longitude: 77.5946,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Restaurant(
        id: '5',
        name: 'Green Leaf Vegetarian',
        address: '654 Garden Lane, Jubilee Hills',
        city: 'Hyderabad',
        state: 'Telangana',
        postalCode: '500033',
        country: 'India',
        phoneNumber: '+91 9876543214',
        email: 'greenleaf@email.com',
        ownerName: 'Meera Reddy',
        licenseNumber: 'FSSAI123460',
        latitude: 17.4065,
        longitude: 78.4772,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Mock Checklist Items (FSSAI/HACCP based)
  static List<ChecklistItem> getChecklistItems() {
    return [
      // Personal Hygiene
      ChecklistItem(
        id: '1',
        category: 'personal_hygiene',
        itemText: 'Food handlers wear clean protective clothing',
        weight: 1.0,
        isCritical: false,
        fssaiSection: '4.1',
      ),
      ChecklistItem(
        id: '2',
        category: 'personal_hygiene',
        itemText: 'Hands washed properly and frequently',
        weight: 1.5,
        isCritical: true,
        fssaiSection: '4.2',
      ),
      ChecklistItem(
        id: '3',
        category: 'personal_hygiene',
        itemText: 'No jewelry on hands/arms while handling food',
        weight: 1.0,
        isCritical: false,
        fssaiSection: '4.3',
      ),
      // Food Storage
      ChecklistItem(
        id: '4',
        category: 'food_storage',
        itemText: 'Raw and cooked foods stored separately',
        weight: 2.0,
        isCritical: true,
        fssaiSection: '5.1',
      ),
      ChecklistItem(
        id: '5',
        category: 'food_storage',
        itemText: 'Food stored at correct temperatures',
        weight: 2.0,
        isCritical: true,
        fssaiSection: '5.2',
      ),
      // Kitchen Hygiene
      ChecklistItem(
        id: '6',
        category: 'kitchen_hygiene',
        itemText: 'Food contact surfaces clean and sanitized',
        weight: 2.0,
        isCritical: true,
        fssaiSection: '6.1',
      ),
      ChecklistItem(
        id: '7',
        category: 'kitchen_hygiene',
        itemText: 'Separate cutting boards for raw/cooked foods',
        weight: 1.5,
        isCritical: true,
        fssaiSection: '6.2',
      ),
    ];
  }

  // Mock Inspections
  static List<Inspection> getInspections() {
    return [
      Inspection(
        id: '1',
        restaurantId: '1',
        restaurantName: 'Spice Garden Restaurant',
        inspectorId: 'inspector1',
        inspectionDate: DateTime.now().subtract(const Duration(days: 7)),
        score: 85.5,
        status: 'completed',
        notes: 'Good overall hygiene. Need improvement in storage.',
        nextInspectionDate: DateTime.now().add(const Duration(days: 90)),
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Inspection(
        id: '2',
        restaurantId: '2',
        restaurantName: 'Tasty Bites Cafe',
        inspectorId: 'inspector1',
        inspectionDate: DateTime.now().subtract(const Duration(days: 14)),
        score: 92.0,
        status: 'completed',
        notes: 'Excellent hygiene standards maintained.',
        nextInspectionDate: DateTime.now().add(const Duration(days: 180)),
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        updatedAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      Inspection(
        id: '3',
        restaurantId: '3',
        restaurantName: 'Food Paradise',
        inspectorId: 'inspector2',
        inspectionDate: DateTime.now().subtract(const Duration(days: 30)),
        score: 65.0,
        status: 'failed',
        notes: 'Critical issues found in food storage.',
        nextInspectionDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }

  // Mock Citizen Reports
  static List<CitizenReport> getCitizenReports() {
    return [
      CitizenReport(
        id: '1',
        restaurantId: '1',
        reporterId: 'citizen1',
        title: 'Unclean kitchen surface',
        description: 'Found food debris on cutting board. Kitchen staff not wearing gloves.',
        reportType: 'hygiene',
        imageUrls: ['https://example.com/photo1.jpg'],
        aiHygieneScore: 45.0,
        aiConfidence: 0.85,
        aiIssuesDetected: ['Food debris', 'No gloves'],
        status: 'under_review',
        adminNotes: 'Inspector assigned for follow-up',
        latitude: 18.9204,
        longitude: 72.8301,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CitizenReport(
        id: '2',
        restaurantId: '2',
        reporterId: 'citizen2',
        title: 'Excellent hygiene observed',
        description: 'Clean premises, staff wearing proper gear.',
        reportType: 'hygiene',
        imageUrls: ['https://example.com/photo2.jpg'],
        aiHygieneScore: 95.0,
        aiConfidence: 0.92,
        aiIssuesDetected: [],
        status: 'resolved',
        adminNotes: 'Positive report verified',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }

  // Mock Ratings
  static List<RestaurantRating> getRestaurantRatings() {
    return [
      RestaurantRating(
        id: '1',
        restaurantId: '1',
        overallRating: 4.0,
        hygieneScore: 80.0,
        inspectionScore: 85.5,
        citizenReportScore: 45.0,
        lastInspectionDate: DateTime.now().subtract(const Duration(days: 7)),
        totalInspections: 5,
        totalCitizenReports: 3,
        ratingCategory: 'good',
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      RestaurantRating(
        id: '2',
        restaurantId: '2',
        overallRating: 5.0,
        hygieneScore: 92.5,
        inspectionScore: 92.0,
        citizenReportScore: 95.0,
        lastInspectionDate: DateTime.now().subtract(const Duration(days: 14)),
        totalInspections: 8,
        totalCitizenReports: 2,
        ratingCategory: 'excellent',
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      RestaurantRating(
        id: '3',
        restaurantId: '3',
        overallRating: 2.0,
        hygieneScore: 60.0,
        inspectionScore: 65.0,
        citizenReportScore: null,
        lastInspectionDate: DateTime.now().subtract(const Duration(days: 30)),
        totalInspections: 3,
        totalCitizenReports: 5,
        ratingCategory: 'poor',
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      RestaurantRating(
        id: '4',
        restaurantId: '4',
        overallRating: 1.0,
        hygieneScore: 40.0,
        inspectionScore: null,
        citizenReportScore: 40.0,
        lastInspectionDate: null,
        totalInspections: 0,
        totalCitizenReports: 8,
        ratingCategory: 'critical',
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  // Mock AI Scoring Function
  static Future<Map<String, dynamic>> analyzeHygieneImage(String imagePath) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate AI processing
    
    // Generate realistic mock AI scores
    final randomScore = 60 + (DateTime.now().millisecond % 40); // 60-100
    final randomConfidence = 0.7 + (DateTime.now().second % 30) / 100; // 0.7-1.0
    
    final issues = [
      'Food debris on surfaces',
      'Improper storage temperature',
      'Unclean equipment',
      'Staff not wearing gloves',
      'Cross-contamination risk',
      'Pest presence',
      'Mold growth',
      'Poor waste management',
    ];
    
    // Randomly select 0-3 issues
    final detectedIssues = <String>[];
    final issueCount = DateTime.now().millisecond % 4;
    for (int i = 0; i < issueCount; i++) {
      detectedIssues.add('${issues[i]} (${(70 + DateTime.now().millisecond % 30)}%)');
    }
    
    // Generate suggestions based on issues
    final suggestions = <String>[
      'Clean all food contact surfaces',
      'Maintain proper storage temperatures',
      'Implement regular equipment sanitization',
      'Provide staff hygiene training',
    ];
    
    return {
      'score': randomScore.toDouble(),
      'confidence': randomConfidence,
      'detected_issues': detectedIssues,
      'suggestions': suggestions.sublist(0, detectedIssues.isEmpty ? 2 : 3),
      'model_version': 'v1.2.0',
    };
  }
}