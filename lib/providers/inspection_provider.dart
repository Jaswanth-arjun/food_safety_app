import 'package:flutter/material.dart';

class Inspection {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final DateTime inspectionDate;
  final String status; // 'pending', 'in_progress', 'completed', 'failed'
  final double? score;
  final DateTime? nextInspectionDate;
  final List<ChecklistItem> checklistItems;

  Inspection({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.inspectionDate,
    this.status = 'pending',
    this.score,
    this.nextInspectionDate,
    this.checklistItems = const [],
  });
}

class ChecklistItem {
  final String id;
  final String category;
  final String text;
  final double weight;
  final bool isCritical;
  final String? compliance; // 'compliant', 'non_compliant', 'needs_improvement', 'not_applicable'
  final String? comments;
  final String? evidenceImage;

  ChecklistItem({
    required this.id,
    required this.category,
    required this.text,
    required this.weight,
    required this.isCritical,
    this.compliance,
    this.comments,
    this.evidenceImage,
  });
}

class InspectionProvider with ChangeNotifier {
  List<Inspection> _inspections = [];
  List<ChecklistItem> _checklistTemplate = [];
  bool _isLoading = false;
  String? _error;

  List<Inspection> get inspections => _inspections;
  List<ChecklistItem> get checklistTemplate => _checklistTemplate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  InspectionProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    // Mock checklist items (FSSAI/HACCP based)
    _checklistTemplate = [
      // Personal Hygiene (20%)
      ChecklistItem(
        id: '1',
        category: 'Personal Hygiene',
        text: 'Food handlers wear clean protective clothing',
        weight: 1.0,
        isCritical: false,
      ),
      ChecklistItem(
        id: '2',
        category: 'Personal Hygiene',
        text: 'Hands washed properly and frequently',
        weight: 1.5,
        isCritical: true,
      ),
      ChecklistItem(
        id: '3',
        category: 'Personal Hygiene',
        text: 'No jewelry on hands/arms while handling food',
        weight: 1.0,
        isCritical: false,
      ),
      ChecklistItem(
        id: '4',
        category: 'Personal Hygiene',
        text: 'No signs of illness among staff',
        weight: 1.5,
        isCritical: true,
      ),
      
      // Food Storage (25%)
      ChecklistItem(
        id: '5',
        category: 'Food Storage',
        text: 'Raw and cooked foods stored separately',
        weight: 2.0,
        isCritical: true,
      ),
      ChecklistItem(
        id: '6',
        category: 'Food Storage',
        text: 'Food stored at correct temperatures',
        weight: 2.0,
        isCritical: true,
      ),
      ChecklistItem(
        id: '7',
        category: 'Food Storage',
        text: 'FIFO (First In First Out) system followed',
        weight: 1.0,
        isCritical: false,
      ),
      ChecklistItem(
        id: '8',
        category: 'Food Storage',
        text: 'Storage areas clean and pest-free',
        weight: 1.5,
        isCritical: true,
      ),
      
      // Kitchen Hygiene (30%)
      ChecklistItem(
        id: '9',
        category: 'Kitchen Hygiene',
        text: 'Food contact surfaces clean and sanitized',
        weight: 2.0,
        isCritical: true,
      ),
      ChecklistItem(
        id: '10',
        category: 'Kitchen Hygiene',
        text: 'Separate cutting boards for raw/cooked foods',
        weight: 1.5,
        isCritical: true,
      ),
      ChecklistItem(
        id: '11',
        category: 'Kitchen Hygiene',
        text: 'Proper waste disposal system',
        weight: 1.5,
        isCritical: true,
      ),
      ChecklistItem(
        id: '12',
        category: 'Kitchen Hygiene',
        text: 'No cross-contamination observed',
        weight: 2.0,
        isCritical: true,
      ),
      
      // Equipment (15%)
      ChecklistItem(
        id: '13',
        category: 'Equipment',
        text: 'Equipment clean and in good repair',
        weight: 1.5,
        isCritical: false,
      ),
      ChecklistItem(
        id: '14',
        category: 'Equipment',
        text: 'Thermometers available and calibrated',
        weight: 1.0,
        isCritical: false,
      ),
      ChecklistItem(
        id: '15',
        category: 'Equipment',
        text: 'Proper dishwashing facilities',
        weight: 1.0,
        isCritical: false,
      ),
      
      // Documentation (10%)
      ChecklistItem(
        id: '16',
        category: 'Documentation',
        text: 'FSSAI license displayed and valid',
        weight: 1.5,
        isCritical: true,
      ),
      ChecklistItem(
        id: '17',
        category: 'Documentation',
        text: 'Staff training records maintained',
        weight: 1.0,
        isCritical: false,
      ),
      ChecklistItem(
        id: '18',
        category: 'Documentation',
        text: 'Pest control records available',
        weight: 1.0,
        isCritical: false,
      ),
    ];

    // Mock inspections
    _inspections = [
      Inspection(
        id: '1',
        restaurantId: '1',
        restaurantName: 'Food Haven Restaurant',
        inspectionDate: DateTime.now().add(const Duration(days: 2)),
        status: 'pending',
        checklistItems: _checklistTemplate,
      ),
      Inspection(
        id: '2',
        restaurantId: '2',
        restaurantName: 'Spice Palace',
        inspectionDate: DateTime.now().add(const Duration(days: 5)),
        status: 'pending',
        checklistItems: _checklistTemplate,
      ),
      Inspection(
        id: '3',
        restaurantId: '3',
        restaurantName: 'Ocean View Cafe',
        inspectionDate: DateTime.now().subtract(const Duration(days: 7)),
        status: 'completed',
        score: 85.5,
        nextInspectionDate: DateTime.now().add(const Duration(days: 90)),
        checklistItems: _checklistTemplate,
      ),
      Inspection(
        id: '4',
        restaurantId: '4',
        restaurantName: 'Quick Bites Fast Food',
        inspectionDate: DateTime.now().subtract(const Duration(days: 30)),
        status: 'failed',
        score: 45.0,
        nextInspectionDate: DateTime.now().add(const Duration(days: 30)),
        checklistItems: _checklistTemplate,
      ),
    ];
  }

  List<Inspection> getPendingInspections() {
    return _inspections.where((i) => i.status == 'pending').toList();
  }

  List<Inspection> getCompletedInspections() {
    return _inspections.where((i) => i.status == 'completed' || i.status == 'failed').toList();
  }

  Future<void> updateChecklistItem(String inspectionId, String itemId, 
      String compliance, String? comments, String? evidenceImage) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final inspectionIndex = _inspections.indexWhere((i) => i.id == inspectionId);
    if (inspectionIndex != -1) {
      final inspection = _inspections[inspectionIndex];
      final updatedItems = inspection.checklistItems.map((item) {
        if (item.id == itemId) {
          return ChecklistItem(
            id: item.id,
            category: item.category,
            text: item.text,
            weight: item.weight,
            isCritical: item.isCritical,
            compliance: compliance,
            comments: comments,
            evidenceImage: evidenceImage,
          );
        }
        return item;
      }).toList();

      _inspections[inspectionIndex] = Inspection(
        id: inspection.id,
        restaurantId: inspection.restaurantId,
        restaurantName: inspection.restaurantName,
        inspectionDate: inspection.inspectionDate,
        status: 'in_progress',
        score: inspection.score,
        nextInspectionDate: inspection.nextInspectionDate,
        checklistItems: updatedItems,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeInspection(String inspectionId, String? notes) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final inspectionIndex = _inspections.indexWhere((i) => i.id == inspectionId);
    if (inspectionIndex != -1) {
      final inspection = _inspections[inspectionIndex];
      
      // Calculate score
      double totalWeight = 0;
      double totalScore = 0;
      bool hasCriticalViolation = false;

      for (final item in inspection.checklistItems) {
        if (item.compliance != null && item.compliance != 'not_applicable') {
          totalWeight += item.weight;
          
          if (item.compliance == 'compliant') {
            totalScore += 100 * item.weight;
          } else if (item.compliance == 'non_compliant') {
            totalScore += 0;
            if (item.isCritical) hasCriticalViolation = true;
          } else if (item.compliance == 'needs_improvement') {
            totalScore += 50 * item.weight;
          }
        }
      }

      final double overallScore = totalWeight > 0 ? totalScore / totalWeight : 0.0;
      final status = (overallScore >= 70 && !hasCriticalViolation) ? 'completed' : 'failed';
      final nextInspection = status == 'failed' 
          ? DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 90));

      _inspections[inspectionIndex] = Inspection(
        id: inspection.id,
        restaurantId: inspection.restaurantId,
        restaurantName: inspection.restaurantName,
        inspectionDate: inspection.inspectionDate,
        status: status,
        score: overallScore,
        nextInspectionDate: nextInspection,
        checklistItems: inspection.checklistItems,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createNewInspection(String restaurantId, String restaurantName) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final newInspection = Inspection(
      id: 'insp_${DateTime.now().millisecondsSinceEpoch}',
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      inspectionDate: DateTime.now(),
      status: 'pending',
      checklistItems: _checklistTemplate,
    );

    _inspections.insert(0, newInspection);

    _isLoading = false;
    notifyListeners();
  }

  List<ChecklistItem> getChecklistByCategory(String category) {
    return _checklistTemplate.where((item) => item.category == category).toList();
  }

  List<String> getChecklistCategories() {
    return _checklistTemplate.map((item) => item.category).toSet().toList();
  }

  Map<String, List<ChecklistItem>> getChecklistByCategories() {
    final categories = getChecklistCategories();
    final result = <String, List<ChecklistItem>>{};
    
    for (final category in categories) {
      result[category] = getChecklistByCategory(category);
    }
    
    return result;
  }
}