import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inspection_provider.dart';
import '../../providers/report_provider.dart';
import '../../models/inspection.dart';
import 'new_inspection.dart';

class InspectorDashboard extends StatefulWidget {
  const InspectorDashboard({super.key});

  @override
  State<InspectorDashboard> createState() => _InspectorDashboardState();
}

class _InspectorDashboardState extends State<InspectorDashboard> {
  int _selectedIndex = 0;

  void _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final inspectionProvider = Provider.of<InspectionProvider>(context);
    final reportProvider = Provider.of<ReportProvider>(context);
    
    final pendingInspections = inspectionProvider.getPendingInspections() as List<Inspection>;
    final completedInspections = inspectionProvider.getCompletedInspections() as List<Inspection>;
    final pendingReports = reportProvider.getPendingReports();
    final reportsNeedingAnalysis = reportProvider.getReportsNeedingAIAnalysis();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspector Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  // Navigate to profile
                  break;
                case 'settings':
                  // Navigate to settings
                  break;
                case 'logout':
                  _logout(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _getSelectedScreen(_selectedIndex, pendingInspections, completedInspections, pendingReports, reportsNeedingAnalysis),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Inspections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Citizen Reports',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewInspectionScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDashboard(List<dynamic> pending, List<dynamic> completed) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Inspector!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete inspections, ensure food safety standards, and generate reports.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NewInspectionScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_task, size: 20),
                          label: const Text('New Inspection'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 1;
                            });
                          },
                          icon: const Icon(Icons.history, size: 20),
                          label: const Text('View History'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Pending Inspections
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pending Inspections',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Chip(
                label: Text('${pending.length} pending'),
                backgroundColor: Colors.orange.shade50,
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (pending.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'No pending inspections',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            ...pending.map((inspection) => _buildInspectionCard(inspection, false)),

          const SizedBox(height: 24),

          // Recent Completed
          const Text(
            'Recent Completed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (completed.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'No completed inspections yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            ...completed.take(3).map((inspection) => _buildInspectionCard(inspection, true)),

          const SizedBox(height: 24),

          // Quick Stats
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Stats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Total', '${pending.length + completed.length}', Icons.list),
                      _buildStatItem('Pending', '${pending.length}', Icons.pending),
                      _buildStatItem('Completed', '${completed.length}', Icons.check_circle),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionCard(dynamic inspection, bool isCompleted) {
    Color getStatusColor(String status) {
      switch (status) {
        case 'completed':
          return Colors.green;
        case 'failed':
          return Colors.red;
        case 'in_progress':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (!isCompleted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewInspectionScreen(inspectionId: inspection.id),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: getStatusColor(inspection.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.pending,
                  color: getStatusColor(inspection.status),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inspection.restaurantName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Scheduled: ${_formatDate(inspection.inspectionDate)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (isCompleted && inspection.score != null) ...[
                          Icon(Icons.score, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Score: ${inspection.score!.toStringAsFixed(1)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: getStatusColor(inspection.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: getStatusColor(inspection.status)),
                          ),
                          child: Text(
                            inspection.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: getStatusColor(inspection.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedInspections(List<dynamic> inspections) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: inspections.length,
      itemBuilder: (context, index) {
        final inspection = inspections[index];
        Color getStatusColor(String status) {
          return status == 'completed' ? Colors.green : Colors.red;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: getStatusColor(inspection.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.restaurant,
                color: getStatusColor(inspection.status),
              ),
            ),
            title: Text(
              inspection.restaurantName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${_formatDate(inspection.inspectionDate)}'),
                if (inspection.nextInspectionDate != null)
                  Text('Next: ${_formatDate(inspection.nextInspectionDate!)}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (inspection.score != null)
                  Chip(
                    label: Text(
                      '${inspection.score!.toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: inspection.score! >= 70 ? Colors.green : Colors.red,
                  ),
                Text(
                  inspection.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: getStatusColor(inspection.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: Colors.blue, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _getSelectedScreen(int index, List pendingInspections, List completedInspections, List pendingReports, List reportsNeedingAnalysis) {
    switch (index) {
      case 0:
        return _buildDashboard(pendingInspections, completedInspections);
      case 1:
        return _buildCompletedInspections(completedInspections);
      case 2:
        return _buildCitizenReports(pendingReports, reportsNeedingAnalysis);
      default:
        return _buildDashboard(pendingInspections, completedInspections);
    }
  }

  Widget _buildCitizenReports(List pendingReports, List reportsNeedingAnalysis) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'All Reports'),
              Tab(text: 'Needs AI Analysis'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildReportsList(pendingReports, 'All Pending Reports'),
                _buildReportsList(reportsNeedingAnalysis, 'Reports Needing AI Analysis'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(List reports, String emptyMessage) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.report_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        report.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getReportTypeColor(report.type),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        report.type.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Restaurant: ${report.restaurantName}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reported by: ${report.reporterName}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(report.description),
                if (report.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.image, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text('${report.imageUrls.length} image(s) attached'),
                    ],
                  ),
                ],
                if (report.aiScore != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.smart_toy, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text('AI Score: ${report.aiScore!.toStringAsFixed(1)}'),
                      const SizedBox(width: 8),
                      Text('Confidence: ${(report.aiConfidence! * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                  if (report.aiIssues.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'AI Issues: ${report.aiIssues.join(", ")}',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (report.imageUrls.isNotEmpty && report.aiScore == null)
                      ElevatedButton.icon(
                        onPressed: () => _analyzeReportWithAI(report.id),
                        icon: const Icon(Icons.smart_toy),
                        label: const Text('Analyze with AI'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _showReportDetails(report),
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _analyzeReportWithAI(String reportId) async {
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing images with YOLOv8 AI model...'),
          ],
        ),
      ),
    );

    try {
      await reportProvider.analyzeReportWithAI(reportId);
      Navigator.of(context).pop(); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI analysis completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI analysis failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReportDetails(dynamic report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Restaurant: ${report.restaurantName}'),
              Text('Reporter: ${report.reporterName}'),
              Text('Type: ${report.type}'),
              const SizedBox(height: 8),
              Text('Description:'),
              Text(report.description),
              if (report.location != null && report.location!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Location: ${report.location}'),
              ],
              if (report.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Images:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: report.imageUrls.length,
                    itemBuilder: (context, index) {
                      final imageUrl = report.imageUrls[index];
                      return Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: imageUrl.startsWith('http')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image, color: Colors.grey);
                                },
                              ),
                            )
                          : const Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => _updateReportStatus(report.id, 'resolved'),
            child: const Text('Mark as Resolved'),
          ),
          ElevatedButton(
            onPressed: () => _updateReportStatus(report.id, 'rejected'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _updateReportStatus(String reportId, String status) async {
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    
    try {
      await reportProvider.updateReportStatus(reportId, status);
      Navigator.of(context).pop(); // Close dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report marked as $status'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getReportTypeColor(String type) {
    switch (type) {
      case 'hygiene':
        return Colors.blue;
      case 'food_safety':
        return Colors.red;
      case 'pest_control':
        return Colors.orange;
      case 'staff_hygiene':
        return Colors.purple;
      case 'equipment':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}