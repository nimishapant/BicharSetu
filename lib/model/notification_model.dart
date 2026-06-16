import 'package:cloud_firestore/cloud_firestore.dart';

/// The type of action that triggered a notification.
enum NotificationType { like, comment, mention }

class NotificationModel {
  final String notificationId;

  /// UID of the user who owns this notification (post author).
  final String recipientUid;

  /// UID of the user who performed the action.
  final String senderUid;
  final String senderUsername;
  final String senderProfilePhoto;

  final NotificationType type;
  final String postId;

  /// Short preview of the post title / body (shown in the notification).
  final String postPreview;

  /// Only set for comment notifications — the actual comment text.
  final String? commentText;

  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.notificationId,
    required this.recipientUid,
    required this.senderUid,
    required this.senderUsername,
    this.senderProfilePhoto = '',
    required this.type,
    required this.postId,
    this.postPreview = '',
    this.commentText,
    this.isRead = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'recipientUid': recipientUid,
      'senderUid': senderUid,
      'senderUsername': senderUsername,
      'senderProfilePhoto': senderProfilePhoto,
      'type': type.name, // 'like' or 'comment'
      'postId': postId,
      'postPreview': postPreview,
      'commentText': commentText,
      'isRead': isRead,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    DateTime? createdTime;
    if (map['createdAt'] is Timestamp) {
      createdTime = (map['createdAt'] as Timestamp).toDate();
    }

    return NotificationModel(
      notificationId: map['notificationId'] ?? '',
      recipientUid: map['recipientUid'] ?? '',
      senderUid: map['senderUid'] ?? '',
      senderUsername: map['senderUsername'] ?? '',
      senderProfilePhoto: map['senderProfilePhoto'] ?? '',
      type: map['type'] == 'comment'
          ? NotificationType.comment
          : map['type'] == 'mention'
              ? NotificationType.mention
              : NotificationType.like,
      postId: map['postId'] ?? '',
      postPreview: map['postPreview'] ?? '',
      commentText: map['commentText'] as String?,
      isRead: (map['isRead'] as bool?) ?? false,
      createdAt: createdTime,
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      notificationId: notificationId,
      recipientUid: recipientUid,
      senderUid: senderUid,
      senderUsername: senderUsername,
      senderProfilePhoto: senderProfilePhoto,
      type: type,
      postId: postId,
      postPreview: postPreview,
      commentText: commentText,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  String get timeAgo {
    if (createdAt == null) return 'Just now';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }
}
