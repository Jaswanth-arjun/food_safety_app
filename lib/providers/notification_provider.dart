import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../models/notification.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  List<UserNotification> _userNotifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  List<UserNotification> get userNotifications => _userNotifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all notifications (for admin)
  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client
          .from('notifications')
          .select('*, profiles(full_name)')
          .order('created_at', ascending: false);

      _notifications = response.map<NotificationModel>((json) {
        return NotificationModel.fromJson(json);
      }).toList();

      _error = null;
    } catch (e) {
      _error = 'Failed to load notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user notifications (for citizens/inspectors)
  Future<void> loadUserNotifications(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client
          .from('user_notifications')
          .select('*, notifications(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _userNotifications = response.map<UserNotification>((json) {
        return UserNotification.fromJson(json);
      }).toList();

      _error = null;
    } catch (e) {
      _error = 'Failed to load user notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send notification to selected recipients
  Future<bool> sendNotification({
    required String message,
    String? title,
    required String recipientType,
    required String sentBy,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create notification record
      final notificationResponse = await SupabaseService.client
          .from('notifications')
          .insert({
            'title': title,
            'message': message,
            'recipient_type': recipientType,
            'sent_by': sentBy,
            'sent_at': DateTime.now().toIso8601String(),
            'is_sent': true,
          })
          .select()
          .single();

      final notificationId = notificationResponse['id'];

      // Get recipients based on type
      String roleFilter;
      switch (recipientType) {
        case 'citizens':
          roleFilter = 'citizen';
          break;
        case 'inspectors':
          roleFilter = 'inspector';
          break;
        case 'both':
          roleFilter = 'citizen,inspector';
          break;
        default:
          throw Exception('Invalid recipient type');
      }

      // Get all users with the specified role(s)
      final usersResponse = await SupabaseService.client
          .from('profiles')
          .select('id')
          .in('role', roleFilter == 'citizen,inspector' ? ['citizen', 'inspector'] : [roleFilter]);

      // Create user notification records
      final userNotifications = usersResponse.map((user) => {
        'notification_id': notificationId,
        'user_id': user['id'],
      }).toList();

      if (userNotifications.isNotEmpty) {
        await SupabaseService.client
            .from('user_notifications')
            .insert(userNotifications);
      }

      // Reload notifications
      await loadNotifications();

      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to send notification: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String userNotificationId) async {
    try {
      await SupabaseService.client
          .from('user_notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userNotificationId);

      // Update local state
      final index = _userNotifications.indexWhere((n) => n.id == userNotificationId);
      if (index != -1) {
        _userNotifications[index] = _userNotifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to mark notification as read: $e';
      notifyListeners();
    }
  }

  // Get unread count
  int getUnreadCount(String userId) {
    return _userNotifications.where((n) => !n.isRead && n.userId == userId).length;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}