import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inspection_provider.dart';
import 'new_inspection.dart';

class InspectorDashboard extends StatefulWidget {
  const InspectorDashboard({super.key});

  @override
  State<InspectorDashboard> createState() => _InspectorDashboardState();
}

class _InspectorDashboardState extends State<InspectorDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final inspectionProvider = Provider.of<InspectionProvider>(context);
    
    final pendingInspections = inspectionProvider.getPendingInspections();
    final completedInspections = inspectionProvider.getCompletedInspections();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspector Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: _selectedIndex == 0 
          ? _buildDashboard(pendingInspections, completedInspections)
          : _buildCompletedInspections(completedInspections),
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
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
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

  Widget _buildDashboard(List<Inspection> pending, List<Inspection> completed) {
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

  Widget _buildInspectionCard(Inspection inspection, bool isCompleted) {
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

  Widget _buildCompletedInspections(List<Inspection> inspections) {
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
}