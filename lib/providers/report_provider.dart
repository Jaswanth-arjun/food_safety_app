import 'package:flutter/material.dart';

class Report {
  final String id;
  final String restaurantId;
  final String reporterId;
  final String reporterName;
  final String restaurantName;
  final String title;
  final String description;
  final String type;
  final List<String> imageUrls;
  final double? aiScore;
  final double? aiConfidence;
  final List<String> aiIssues;
  final String status;
  final DateTime createdAt;
  final String? location;
  final String? actionTaken;
  final DateTime? resolvedAt;

  Report({
    required this.id,
    required this.restaurantId,
    required this.reporterId,
    required this.restaurantName,
    required this.title,
    required this.description,
    required this.type,
    this.imageUrls = const [],
    this.aiScore,
    this.aiConfidence,
    this.aiIssues = const [],
    required this.status,
    required this.createdAt,
    this.reporterName = 'Anonymous',
    this.location,
    this.actionTaken,
    this.resolvedAt,
  });

  // Copy with method for updates
  Report copyWith({
    String? id,
    String? restaurantId,
    String? reporterId,
    String? reporterName,
    String? restaurantName,
    String? title,
    String? description,
    String? type,
    List<String>? imageUrls,
    double? aiScore,
    double? aiConfidence,
    List<String>? aiIssues,
    String? status,
    DateTime? createdAt,
    String? location,
    String? actionTaken,
    DateTime? resolvedAt,
  }) {
    return Report(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      restaurantName: restaurantName ?? this.restaurantName,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      imageUrls: imageUrls ?? this.imageUrls,
      aiScore: aiScore ?? this.aiScore,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      aiIssues: aiIssues ?? this.aiIssues,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      actionTaken: actionTaken ?? this.actionTaken,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  // Formatted date for display
  String get formattedDate {
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
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Check if report is pending
  bool get isPending => status.toLowerCase() == 'pending';
  
  // Check if report is resolved
  bool get isResolved => status.toLowerCase() == 'resolved' || status.toLowerCase() == 'approved';
  
  // Check if report is rejected
  bool get isRejected => status.toLowerCase() == 'rejected';
}

class ReportProvider with ChangeNotifier {
  List<Report> _reports = [];
  bool _isLoading = false;
  String? _error;
  List<Report> _filteredReports = [];
  String _currentFilter = 'all';

  List<Report> get reports => _reports;
  List<Report> get filteredReports => _filteredReports;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentFilter => _currentFilter;

  // Statistics
  int get totalReports => _reports.length;
  int get pendingReports => _reports.where((r) => r.isPending).length;
  int get resolvedReports => _reports.where((r) => r.isResolved).length;
  int get rejectedReports => _reports.where((r) => r.isRejected).length;

  ReportProvider() {
    // Initialize with mock data
    _initializeMockData();
  }

  void _initializeMockData() {
    _reports = [
      Report(
        id: 'rep_1',
        restaurantId: 'rest_1',
        reporterId: 'user_1',
        reporterName: 'John Doe',
        restaurantName: 'Food Palace',
        title: 'Unhygienic Kitchen Conditions',
        description: 'Found insects and food debris in the kitchen area. Utensils were not properly cleaned. Staff not wearing gloves while handling food.',
        type: 'hygiene',
        imageUrls: ['https://example.com/image1.jpg'],
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        location: 'Mumbai Central',
      ),
      Report(
        id: 'rep_2',
        restaurantId: 'rest_2',
        reporterId: 'user_2',
        reporterName: 'Jane Smith',
        restaurantName: 'Spice Garden',
        title: 'Expired Food Items',
        description: 'Noticed several packaged food items past their expiry date. Staff was defensive when questioned about it.',
        type: 'food_safety',
        imageUrls: ['https://example.com/image2.jpg'],
        aiScore: 45.0,
        aiConfidence: 0.92,
        aiIssues: ['Expired products detected (92%)', 'Packaging integrity issue (78%)'],
        status: 'approved',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        location: 'Andheri West',
        actionTaken: 'Inspector dispatched for verification',
        resolvedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Report(
        id: 'rep_3',
        restaurantId: 'rest_3',
        reporterId: 'user_3',
        reporterName: 'Robert Johnson',
        restaurantName: 'Burger Hub',
        title: 'Poor Staff Hygiene',
        description: 'Staff not wearing hairnets or masks. Observed staff handling cash and then food without washing hands.',
        type: 'hygiene',
        imageUrls: ['https://example.com/image3.jpg'],
        aiScore: 55.0,
        aiConfidence: 0.88,
        aiIssues: ['Personal hygiene violation (88%)', 'Cross-contamination risk (72%)'],
        status: 'rejected',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        location: 'Bandra',
        actionTaken: 'Report found to be inaccurate after investigation',
      ),
      Report(
        id: 'rep_4',
        restaurantId: 'rest_1',
        reporterId: 'user_4',
        reporterName: 'Alice Brown',
        restaurantName: 'Food Palace',
        title: 'Rodent Sighting',
        description: 'Saw a rodent near the food storage area. This is a serious health violation that needs immediate attention.',
        type: 'pest_control',
        imageUrls: ['https://example.com/image4.jpg'],
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        location: 'Mumbai Central',
      ),
    ];
    
    _filteredReports = _reports;
    notifyListeners();
  }

  Future<Report> createReport({
    required String restaurantId,
    required String reporterId,
    required String reporterName,
    required String restaurantName,
    required String title,
    required String description,
    required String type,
    List<String> imageUrls = const [],
    String? location,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Don't automatically analyze - let inspector do it manually
      final newReport = Report(
        id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
        restaurantId: restaurantId,
        reporterId: reporterId,
        reporterName: reporterName,
        restaurantName: restaurantName,
        title: title,
        description: description,
        type: type,
        imageUrls: imageUrls,
        status: 'pending',
        createdAt: DateTime.now(),
        location: location,
      );

      _reports.insert(0, newReport);
      _applyFilter(_currentFilter);
      
      _isLoading = false;
      notifyListeners();
      
      return newReport;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to create report: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Fetch all reports (for admin)
  Future<void> fetchAllReports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      // In real app, fetch from API
      _applyFilter(_currentFilter);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to fetch reports: $e';
      notifyListeners();
    }
  }

  // Update report status (for admin)
  Future<void> updateReportStatus(String reportId, String newStatus, {String? actionTaken}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _reports.indexWhere((report) => report.id == reportId);
      if (index != -1) {
        final oldReport = _reports[index];
        final updatedReport = oldReport.copyWith(
          status: newStatus,
          actionTaken: actionTaken ?? oldReport.actionTaken,
          resolvedAt: newStatus == 'approved' || newStatus == 'rejected' 
              ? DateTime.now() 
              : oldReport.resolvedAt,
        );
        
        _reports[index] = updatedReport;
        _applyFilter(_currentFilter);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update report: $e';
      notifyListeners();
    }
  }

  // Filter reports
  void filterReports(String filter) {
    _currentFilter = filter;
    _applyFilter(filter);
  }

  void _applyFilter(String filter) {
    switch (filter.toLowerCase()) {
      case 'all':
        _filteredReports = List.from(_reports);
        break;
      case 'pending':
        _filteredReports = _reports.where((r) => r.isPending).toList();
        break;
      case 'approved':
      case 'resolved':
        _filteredReports = _reports.where((r) => r.isResolved).toList();
        break;
      case 'rejected':
        _filteredReports = _reports.where((r) => r.isRejected).toList();
        break;
      default:
        _filteredReports = List.from(_reports);
    }
    notifyListeners();
  }

  // Search reports
  void searchReports(String query) {
    if (query.isEmpty) {
      _applyFilter(_currentFilter);
      return;
    }

    _filteredReports = _reports.where((report) {
      return report.title.toLowerCase().contains(query.toLowerCase()) ||
             report.description.toLowerCase().contains(query.toLowerCase()) ||
             report.restaurantName.toLowerCase().contains(query.toLowerCase()) ||
             report.reporterName.toLowerCase().contains(query.toLowerCase()) ||
             report.type.toLowerCase().contains(query.toLowerCase());
    }).toList();
    
    notifyListeners();
  }

  // Get reports by restaurant
  List<Report> getReportsByRestaurant(String restaurantId) {
    return _reports.where((r) => r.restaurantId == restaurantId).toList();
  }

  // Get reports by reporter
  List<Report> getMyReports(String reporterId) {
    return _reports.where((r) => r.reporterId == reporterId).toList();
  }

  // Get report by ID
  Report? getReportById(String reportId) {
    return _reports.firstWhere((r) => r.id == reportId);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get statistics by type
  Map<String, int> getReportStatistics() {
    return {
      'total': totalReports,
      'pending': pendingReports,
      'resolved': resolvedReports,
      'rejected': rejectedReports,
    };
  }

  // Get reports by status
  List<Report> getReportsByStatus(String status) {
    return _reports.where((r) => r.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // Get recent reports
  List<Report> getRecentReports({int limit = 5}) {
    _reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _reports.take(limit).toList();
  }

  // Get pending reports for inspector review
  List<Report> getPendingReports() {
    return getReportsByStatus('pending');
  }

  // Get reports requiring AI analysis
  List<Report> getReportsNeedingAIAnalysis() {
    return _reports.where((r) => 
      r.status == 'pending' && 
      r.imageUrls.isNotEmpty && 
      (r.aiScore == null || r.aiConfidence == null)
    ).toList();
  }

  // Analyze report images with AI (simulated YOLOv8)
  Future<void> analyzeReportWithAI(String reportId) async {
    final reportIndex = _reports.indexWhere((r) => r.id == reportId);
    if (reportIndex == -1) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 3)); // Simulate AI processing

      // Simulate YOLOv8 analysis results
      final random = DateTime.now().millisecond;
      final aiScore = 40 + (random % 60); // 40-100 score
      final aiConfidence = 0.6 + (random % 40) / 100; // 0.6-1.0 confidence

      // Generate AI issues based on score
      List<String> aiIssues = [];
      if (aiScore < 60) {
        aiIssues.addAll([
          'Critical hygiene violations detected',
          'Potential food contamination risk',
          'Equipment sanitation issues identified',
          'Staff hygiene non-compliance'
        ]);
      } else if (aiScore < 75) {
        aiIssues.addAll([
          'Minor cleanliness issues detected',
          'Food storage practices need improvement',
          'Surface cleaning required'
        ]);
      } else {
        aiIssues.add('Food safety standards maintained');
      }

      // Update the report
      _reports[reportIndex] = _reports[reportIndex].copyWith(
        aiScore: aiScore.toDouble(),
        aiConfidence: aiConfidence,
        aiIssues: aiIssues,
      );

      _applyFilter(_currentFilter);
      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _isLoading = false;
      _error = 'AI analysis failed: $e';
      notifyListeners();
    }
  }
}