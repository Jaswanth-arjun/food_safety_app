import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/inspection_provider.dart';
import '../../providers/restaurant_provider.dart';

class NewInspectionScreen extends StatefulWidget {
  final String? inspectionId;
  
  const NewInspectionScreen({super.key, this.inspectionId});

  @override
  State<NewInspectionScreen> createState() => _NewInspectionScreenState();
}

class _NewInspectionScreenState extends State<NewInspectionScreen> {
  final _notesController = TextEditingController();
  String? _selectedRestaurantId;
  Map<String, Map<String, dynamic>> _checklistResponses = {};
  Map<String, File?> _evidenceImages = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.inspectionId != null) {
      // Load existing inspection data
      _loadInspectionData();
    }
  }

  void _loadInspectionData() {
    // This would load existing inspection data
    // For now, we'll just initialize empty responses
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickEvidenceImage(String itemId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _evidenceImages[itemId] = File(pickedFile.path);
      });
    }
  }

  void _updateChecklistItem(String itemId, String compliance, String? comments) {
    setState(() {
      _checklistResponses[itemId] = {
        'compliance': compliance,
        'comments': comments,
        'evidence': _evidenceImages[itemId]?.path,
      };
    });
  }

  Future<void> _submitInspection() async {
    if (_selectedRestaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a restaurant'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_checklistResponses.length < 5) { // Minimum items completed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete at least 5 checklist items'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final inspectionProvider = Provider.of<InspectionProvider>(context, listen: false);
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    
    final restaurant = restaurantProvider.getRestaurantById(_selectedRestaurantId!);
    
    try {
      if (widget.inspectionId != null) {
        // Update existing inspection
        // Update each checklist item
        for (final entry in _checklistResponses.entries) {
          await inspectionProvider.updateChecklistItem(
            widget.inspectionId!,
            entry.key,
            entry.value['compliance'],
            entry.value['comments'],
            entry.value['evidence'],
          );
        }
        
        // Complete the inspection
        await inspectionProvider.completeInspection(widget.inspectionId!, _notesController.text);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Inspection completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Create new inspection
        await inspectionProvider.createNewInspection(_selectedRestaurantId!, restaurant!.name);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('New inspection created!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Navigate back after delay
      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (context.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final inspectionProvider = Provider.of<InspectionProvider>(context);
    final restaurants = restaurantProvider.restaurants;
    final checklistByCategories = inspectionProvider.getChecklistByCategories();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.inspectionId != null ? 'Complete Inspection' : 'New Inspection'),
        actions: [
          if (_checklistResponses.isNotEmpty)
            Chip(
              label: Text('${_checklistResponses.length}/${inspectionProvider.checklistTemplate.length}'),
              backgroundColor: Colors.blue,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Selection
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Restaurant Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedRestaurantId,
                      decoration: const InputDecoration(
                        labelText: 'Select Restaurant',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.restaurant),
                      ),
                      items: restaurants.map((restaurant) {
                        return DropdownMenuItem(
                          value: restaurant.id,
                          child: Text(restaurant.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRestaurantId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a restaurant';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Checklist by Categories
            ...checklistByCategories.entries.map((entry) {
              return _buildChecklistCategory(entry.key, entry.value);
            }).toList(),

            const SizedBox(height: 20),

            // Additional Notes
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitInspection,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Icon(Icons.check_circle, size: 20),
                label: _isLoading
                    ? const Text('Processing...')
                    : Text(widget.inspectionId != null ? 'Complete Inspection' : 'Create Inspection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistCategory(String category, List<ChecklistItem> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${items.length} items'),
                  backgroundColor: Colors.blue.shade50,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _buildChecklistItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(ChecklistItem item) {
    final currentResponse = _checklistResponses[item.id];
    final currentCompliance = currentResponse?['compliance'];
    final currentComments = currentResponse?['comments'];
    final evidenceImage = _evidenceImages[item.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.text,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: item.isCritical ? Colors.red.shade700 : Colors.black,
                  ),
                ),
              ),
              if (item.isCritical)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Text(
                    'CRITICAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Compliance Options
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildComplianceButton('Compliant', 'compliant', currentCompliance, item),
              _buildComplianceButton('Non-Compliant', 'non_compliant', currentCompliance, item),
              _buildComplianceButton('Needs Improvement', 'needs_improvement', currentCompliance, item),
              _buildComplianceButton('N/A', 'not_applicable', currentCompliance, item),
            ],
          ),
          
          if (currentCompliance != null && currentCompliance != 'compliant' && currentCompliance != 'not_applicable') ...[
            const SizedBox(height: 12),
            
            // Comments
            TextField(
              onChanged: (value) {
                _updateChecklistItem(item.id, currentCompliance, value);
              },
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Comments (required for non-compliance)',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                errorText: (currentCompliance == 'non_compliant' || currentCompliance == 'needs_improvement') && 
                           (currentComments == null || currentComments.isEmpty)
                    ? 'Comments required'
                    : null,
              ),
              controller: TextEditingController(text: currentComments ?? ''),
            ),
            
            const SizedBox(height: 12),
            
            // Evidence Upload
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickEvidenceImage(item.id),
                  icon: const Icon(Icons.camera_alt, size: 16),
                  label: const Text('Add Evidence'),
                ),
                const SizedBox(width: 12),
                if (evidenceImage != null)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: FileImage(evidenceImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComplianceButton(String label, String value, String? currentValue, ChecklistItem item) {
    final isSelected = currentValue == value;
    Color getButtonColor() {
      switch (value) {
        case 'compliant':
          return Colors.green;
        case 'non_compliant':
          return Colors.red;
        case 'needs_improvement':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _updateChecklistItem(item.id, value, null);
        }
      },
      backgroundColor: isSelected ? getButtonColor().withOpacity(0.2) : Colors.grey.shade100,
      selectedColor: getButtonColor().withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? getButtonColor() : Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? getButtonColor() : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
    );
  }
}