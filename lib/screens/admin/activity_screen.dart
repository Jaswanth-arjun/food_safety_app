import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/brand_logo.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String _filter = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Refresh activities when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().refreshActivities();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<ActivityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Activity'),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => activityProvider.refreshActivities(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search activities...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Activity List
          Expanded(
            child: activityProvider.isLoading
                ? Center(child: LogoSpinner(size: 28))
                : _buildActivityList(activityProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(ActivityProvider activityProvider) {
    final filteredActivities = _getFilteredActivities(activityProvider.activities);

    if (filteredActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty ? 'No activities found' : 'No activities match your search',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => activityProvider.refreshActivities(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: filteredActivities.length,
        itemBuilder: (context, index) {
          final activity = filteredActivities[index];
          return ActivityListTile(activity: activity);
        },
      ),
    );
  }

  List<dynamic> _getFilteredActivities(List activities) {
    var filtered = activities;

    // Apply type filter
    if (_filter != 'all') {
      filtered = activities.where((activity) {
        switch (_filter) {
          case 'reports':
            return activity.isReportActivity;
          case 'restaurants':
            return activity.isRestaurantActivity;
          case 'users':
            return activity.isUserActivity;
          case 'system':
            return activity.isSystemActivity;
          default:
            return true;
        }
      }).toList();
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((activity) {
        return activity.title.toLowerCase().contains(query) ||
               activity.description.toLowerCase().contains(query) ||
               activity.userName.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Activities'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('All Activities'),
              value: 'all',
              groupValue: _filter,
              onChanged: (value) {
                setState(() => _filter = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Reports'),
              value: 'reports',
              groupValue: _filter,
              onChanged: (value) {
                setState(() => _filter = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Restaurants'),
              value: 'restaurants',
              groupValue: _filter,
              onChanged: (value) {
                setState(() => _filter = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Users'),
              value: 'users',
              groupValue: _filter,
              onChanged: (value) {
                setState(() => _filter = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('System'),
              value: 'system',
              groupValue: _filter,
              onChanged: (value) {
                setState(() => _filter = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class ActivityListTile extends StatelessWidget {
  final dynamic activity;

  const ActivityListTile({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(activity.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: activity.color.withOpacity(0.1),
          child: Icon(
            activity.icon,
            color: activity.color,
          ),
        ),
        title: Text(
          activity.title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  activity.userName,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: activity.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: activity.color.withOpacity(0.3)),
          ),
          child: Text(
            _getActivityTypeLabel(activity.type),
            style: TextStyle(
              color: activity.color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () => _showActivityDetails(context, activity),
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getActivityTypeLabel(String type) {
    switch (type) {
      case 'report_created':
        return 'REPORT';
      case 'report_approved':
        return 'APPROVED';
      case 'report_rejected':
        return 'REJECTED';
      case 'restaurant_added':
        return 'RESTAURANT';
      case 'restaurant_updated':
        return 'UPDATED';
      case 'user_registered':
        return 'USER';
      case 'inspection_completed':
        return 'INSPECTION';
      case 'system_backup':
        return 'SYSTEM';
      default:
        return 'ACTIVITY';
    }
  }

  void _showActivityDetails(BuildContext context, dynamic activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(activity.icon, color: activity.color),
            const SizedBox(width: 8),
            Expanded(child: Text(activity.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                activity.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('User', activity.userName),
              _buildDetailRow('Time', DateFormat('MMM dd, yyyy hh:mm a').format(activity.timestamp)),
              _buildDetailRow('Type', _getActivityTypeLabel(activity.type)),
              if (activity.metadata != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Additional Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...activity.metadata.entries.map((entry) =>
                  _buildDetailRow(entry.key.capitalize(), entry.value.toString())
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}