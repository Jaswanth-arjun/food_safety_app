class NotificationModel {
  final String id;
  final String? title;
  final String message;
  final String recipientType; // 'citizens', 'inspectors', 'both'
  final String? sentBy;
  final String? sentByName;
  final DateTime createdAt;
  final DateTime? sentAt;
  final bool isSent;

  NotificationModel({
    required this.id,
    this.title,
    required this.message,
    required this.recipientType,
    this.sentBy,
    this.sentByName,
    required this.createdAt,
    this.sentAt,
    required this.isSent,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      recipientType: json['recipient_type'],
      sentBy: json['sent_by'],
      sentByName: json['profiles']?['full_name'],
      createdAt: DateTime.parse(json['created_at']),
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      isSent: json['is_sent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'recipient_type': recipientType,
      'sent_by': sentBy,
      'created_at': createdAt.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
      'is_sent': isSent,
    };
  }
}

class UserNotification {
  final String id;
  final String notificationId;
  final String userId;
  final NotificationModel notification;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  UserNotification({
    required this.id,
    required this.notificationId,
    required this.userId,
    required this.notification,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'],
      notificationId: json['notification_id'],
      userId: json['user_id'],
      notification: NotificationModel.fromJson(json['notifications']),
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_id': notificationId,
      'user_id': userId,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserNotification copyWith({
    String? id,
    String? notificationId,
    String? userId,
    NotificationModel? notification,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return UserNotification(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      notification: notification ?? this.notification,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}