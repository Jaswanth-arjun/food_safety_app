import 'package:flutter/material.dart';
import '../models/inspection.dart';
import '../models/user.dart';

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
        itemText: 'Food handlers wear clean protective clothing',
        weight: 1.0,
        isCritical: false,
      ),
      ChecklistItem(
        id: '2',
        category: 'Personal Hygiene',
        itemText: 'Hands washed properly and frequently',
        weight: 1.5,
        isCritical: true,
      ),
      ChecklistItem(
        id: '3',
        category: 'Personal Hygiene',
        itemText: 'No jewelry on hands/arms while handling food',
        weight: 1.0,
        isCritical: false,
      ),
      ChecklistItem(
        id: '4',
        category: 'Personal Hygiene',
        itemText: 'No signs of illness among staff',
        weight: 1.5,
        isCritical: true,
      ),
      
      // Food Storage (25%)
      ChecklistItem(
        id: '5',
        category: 'Food Storage',
        itemText: 'Raw and cooked foods stored separately',
        weight: 2.0,
        isCritical: true,
      ),
      ChecklistItem(
        id: '6',
        category: 'Food Storage',
        itemText: 'Food stored at correct temperatures',
        weight: 2.0,
        isCritical: true,
      ),
      ChecklistItem(
        id: '7',
        category: 'Food Storage',
        itemText: 'FIFO (First In First Out) system followed',
        weight: 1.0,
        isCritical: false,
      ),
      ChecklistItem(
        id: '8',
        category: 'Food Storage',
        itemText: 'Storage areas clean and pest-free',
        weight: 1.5,
        isCritical: true,
      ),
      
      // Kitchen Hygiene (30%)
      ChecklistItem(
        id: '9',
        category: 'Kitchen Hygiene',
        itemText: 'Food contact surfaces clean and sanitized',
        weight: 2.0,
        isCritical: true,
      ),
      ChecklistItem(
        id: '10',
        category: 'Kitchen Hygiene',
        itemText: 'Separate cutting boards for raw/cooked foods',
        weight: 1.5,
        isCritical: true,
      ),
      ChecklistItem(
        id: '11',
        category: 'Kitchen Hygiene',
        itemText: 'Proper waste disposal system',
        weight: 1.5,
        isCritical: true,
      ),
      ChecklistItem(
        id: '12',
        category: 'Kitchen Hygiene',
        itemText: 'No cross-contamination observed',
        weight: 2.0,
        isCritical: true,
      ),
      
      // Equipment (15%)
      ChecklistItem(
        id: '13',
        category: 'Equipment',
        itemText: 'Equipment clean and in good repair',
        weight: 1.5,
        isCritical: false,
      ),
      ChecklistItem(
        id: '14',
        category: 'Equipment',
        itemText: 'Thermometers available and calibrated',
        weight: 1.0,
        isCritical: false,
      ),
      ChecklistItem(
        id: '15',
        category: 'Equipment',
        itemText: 'Proper dishwashing facilities',
        weight: 1.0,
        isCritical: false,
      ),
      
      // Documentation (10%)
      ChecklistItem(
        id: '16',
        category: 'Documentation',
        itemText: 'FSSAI license displayed and valid',
        weight: 1.5,
        isCritical: true,
      ),
      ChecklistItem(
        id: '17',
        category: 'Documentation',
        itemText: 'Staff training records maintained',
        weight: 1.0,
        isCritical: false,
      ),
      ChecklistItem(
        id: '18',
        category: 'Documentation',
        itemText: 'Pest control records available',
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
        inspectorId: 'inspector_1',
        inspectionDate: DateTime.now().add(const Duration(days: 2)),
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        checklistItems: _checklistTemplate,
      ),
      Inspection(
        id: '2',
        restaurantId: '2',
        restaurantName: 'Spice Palace',
        inspectorId: 'inspector_1',
        inspectionDate: DateTime.now().add(const Duration(days: 5)),
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        checklistItems: _checklistTemplate,
      ),
      Inspection(
        id: '3',
        restaurantId: '3',
        restaurantName: 'Ocean View Cafe',
        inspectorId: 'inspector_1',
        inspectionDate: DateTime.now().subtract(const Duration(days: 7)),
        status: 'completed',
        score: 85.5,
        nextInspectionDate: DateTime.now().add(const Duration(days: 90)),
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        checklistItems: _checklistTemplate,
      ),
      Inspection(
        id: '4',
        restaurantId: '4',
        restaurantName: 'Quick Bites Fast Food',
        inspectorId: 'inspector_1',
        inspectionDate: DateTime.now().subtract(const Duration(days: 30)),
        status: 'failed',
        score: 45.0,
        nextInspectionDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
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
            itemText: item.itemText,
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
        inspectorId: inspection.inspectorId,
        inspectionDate: inspection.inspectionDate,
        status: 'in_progress',
        score: inspection.score,
        nextInspectionDate: inspection.nextInspectionDate,
        createdAt: inspection.createdAt,
        updatedAt: DateTime.now(),
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
        inspectorId: inspection.inspectorId,
        inspectionDate: inspection.inspectionDate,
        status: status,
        score: overallScore,
        nextInspectionDate: nextInspection,
        createdAt: inspection.createdAt,
        updatedAt: DateTime.now(),
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
      inspectorId: 'inspector_1', // Default inspector for now
      inspectionDate: DateTime.now(),
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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