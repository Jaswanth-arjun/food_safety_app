import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/brand_logo.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoBackupEnabled = true;
  bool _aiAnalysisEnabled = true;
  bool _realTimeUpdatesEnabled = true;
  String _dataRetentionPeriod = '1_year';
  String _reportAutoApprovalThreshold = 'high_confidence';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _autoBackupEnabled = prefs.getBool('auto_backup_enabled') ?? true;
      _aiAnalysisEnabled = prefs.getBool('ai_analysis_enabled') ?? true;
      _realTimeUpdatesEnabled = prefs.getBool('real_time_updates_enabled') ?? true;
      _dataRetentionPeriod = prefs.getString('data_retention_period') ?? '1_year';
      _reportAutoApprovalThreshold = prefs.getString('report_auto_approval_threshold') ?? 'high_confidence';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: _isLoading
          ? Center(child: LogoSpinner(size: 28))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // System Configuration
                  _buildSectionHeader('System Configuration'),
                  _buildSwitchTile(
                    title: 'Real-time Updates',
                    subtitle: 'Enable live data synchronization across all dashboards',
                    value: _realTimeUpdatesEnabled,
                    onChanged: (value) {
                      setState(() => _realTimeUpdatesEnabled = value);
                      _saveSetting('real_time_updates_enabled', value);
                    },
                  ),
                  _buildSwitchTile(
                    title: 'AI Analysis',
                    subtitle: 'Enable automated image analysis for reports',
                    value: _aiAnalysisEnabled,
                    onChanged: (value) {
                      setState(() => _aiAnalysisEnabled = value);
                      _saveSetting('ai_analysis_enabled', value);
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Auto Backup',
                    subtitle: 'Automatically backup system data daily',
                    value: _autoBackupEnabled,
                    onChanged: (value) {
                      setState(() => _autoBackupEnabled = value);
                      _saveSetting('auto_backup_enabled', value);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Notification Settings
                  _buildSectionHeader('Notifications'),
                  _buildSwitchTile(
                    title: 'System Notifications',
                    subtitle: 'Receive alerts for system events and updates',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                      _saveSetting('notifications_enabled', value);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Data Management
                  _buildSectionHeader('Data Management'),
                  _buildDropdownTile(
                    title: 'Data Retention Period',
                    subtitle: 'How long to keep historical data',
                    value: _dataRetentionPeriod,
                    items: const [
                      DropdownMenuItem(value: '6_months', child: Text('6 Months')),
                      DropdownMenuItem(value: '1_year', child: Text('1 Year')),
                      DropdownMenuItem(value: '2_years', child: Text('2 Years')),
                      DropdownMenuItem(value: '5_years', child: Text('5 Years')),
                      DropdownMenuItem(value: 'indefinite', child: Text('Indefinite')),
                    ],
                    onChanged: (value) {
                      setState(() => _dataRetentionPeriod = value!);
                      _saveSetting('data_retention_period', value);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Report Processing
                  _buildSectionHeader('Report Processing'),
                  _buildDropdownTile(
                    title: 'Auto-Approval Threshold',
                    subtitle: 'AI confidence level for automatic report approval',
                    value: _reportAutoApprovalThreshold,
                    items: const [
                      DropdownMenuItem(value: 'low_confidence', child: Text('Low Confidence (70%)')),
                      DropdownMenuItem(value: 'medium_confidence', child: Text('Medium Confidence (80%)')),
                      DropdownMenuItem(value: 'high_confidence', child: Text('High Confidence (90%)')),
                      DropdownMenuItem(value: 'very_high_confidence', child: Text('Very High Confidence (95%)')),
                      DropdownMenuItem(value: 'manual_only', child: Text('Manual Review Only')),
                    ],
                    onChanged: (value) {
                      setState(() => _reportAutoApprovalThreshold = value!);
                      _saveSetting('report_auto_approval_threshold', value);
                    },
                  ),

                  const SizedBox(height: 24),

                  // System Actions
                  _buildSectionHeader('System Actions'),
                  _buildActionButton(
                    title: 'Clear Cache',
                    subtitle: 'Clear temporary data and cached images',
                    icon: Icons.cleaning_services,
                    color: Colors.blue,
                    onPressed: _clearCache,
                  ),
                  _buildActionButton(
                    title: 'Export Data',
                    subtitle: 'Export all system data to CSV files',
                    icon: Icons.download,
                    color: Colors.green,
                    onPressed: _exportData,
                  ),
                  _buildActionButton(
                    title: 'System Maintenance',
                    subtitle: 'Run system health checks and optimizations',
                    icon: Icons.build,
                    color: Colors.orange,
                    onPressed: _runMaintenance,
                  ),
                  _buildActionButton(
                    title: 'Reset to Defaults',
                    subtitle: 'Reset all settings to default values',
                    icon: Icons.restore,
                    color: Colors.red,
                    onPressed: _resetToDefaults,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onPressed,
      ),
    );
  }

  Future<void> _clearCache() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all temporary data and cached images. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2)); // Simulate clearing
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully')),
        );
      }
    }
  }

  Future<void> _exportData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 3)); // Simulate export
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data export completed. Files saved to Downloads.')),
      );
    }
  }

  Future<void> _runMaintenance() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 4)); // Simulate maintenance
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('System maintenance completed successfully')),
      );
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text('This will reset all settings to their default values. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      // Reset all settings to defaults
      _notificationsEnabled = true;
      _autoBackupEnabled = true;
      _aiAnalysisEnabled = true;
      _realTimeUpdatesEnabled = true;
      _dataRetentionPeriod = '1_year';
      _reportAutoApprovalThreshold = 'high_confidence';

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All settings reset to defaults')),
        );
      }
    }
  }
}