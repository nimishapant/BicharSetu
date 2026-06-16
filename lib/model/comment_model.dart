import 'package:cloud_firestore/cloud_firestore.dart';

/// Reaction types supported on a comment.
enum CommentReaction { like, love, laugh, sad, angry, wow }

extension CommentReactionX on CommentReaction {
  String get emoji {
    switch (this) {
      case CommentReaction.like:  return '👍';
      case CommentReaction.love:  return '❤️';
      case CommentReaction.laugh: return '😂';
      case CommentReaction.sad:   return '😢';
      case CommentReaction.angry: return '😡';
      case CommentReaction.wow:   return '😮';
    }
  }

  String get label {
    switch (this) {
      case CommentReaction.like:  return 'Like';
      case CommentReaction.love:  return 'Love';
      case CommentReaction.laugh: return 'Haha';
      case CommentReaction.sad:   return 'Sad';
      case CommentReaction.angry: return 'Angry';
      case CommentReaction.wow:   return 'Wow';
    }
  }
}

class CommentModel {
  final String commentId;
  final String postId;
  final String uid;
  final String username;
  final String profilePhoto;
  final String text;
  final String imageUrl;
  final Map<String, List<String>> reactions;

  /// If this is a reply, parentId = the parent comment's ID.
  /// Top-level comments have parentId == ''.
  final String parentId;

  /// Username of the person being replied to (for display "@username").
  final String replyToUsername;

  /// Cached count of replies on this comment (top-level only).
  final int replyCount;

  final DateTime? createdAt;

  CommentModel({
    required this.commentId,
    required this.postId,
    required this.uid,
    required this.username,
    this.profilePhoto = '',
    required this.text,
    this.imageUrl = '',
    this.reactions = const {},
    this.parentId = '',
    this.replyToUsername = '',
    this.replyCount = 0,
    this.createdAt,
  });

  bool get isReply => parentId.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'postId': postId,
      'uid': uid,
      'username': username,
      'profilePhoto': profilePhoto,
      'text': text,
      'imageUrl': imageUrl,
      'reactions': reactions.map((k, v) => MapEntry(k, v)),
      'parentId': parentId,
      'replyToUsername': replyToUsername,
      'replyCount': replyCount,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    DateTime? createdTime;
    if (map['createdAt'] is Timestamp) {
      createdTime = (map['createdAt'] as Timestamp).toDate();
    }

    final rawReactions = map['reactions'] as Map<String, dynamic>? ?? {};
    final reactions = rawReactions.map((key, value) {
      final uids = (value as List<dynamic>).map((e) => e.toString()).toList();
      return MapEntry(key, uids);
    });

    return CommentModel(
      commentId: map['commentId'] ?? '',
      postId: map['postId'] ?? '',
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      reactions: reactions,
      parentId: map['parentId'] ?? '',
      replyToUsername: map['replyToUsername'] ?? '',
      replyCount: (map['replyCount'] as int?) ?? 0,
      createdAt: createdTime,
    );
  }

  int get totalReactions =>
      reactions.values.fold(0, (sum, list) => sum + list.length);

  CommentReaction? get topReaction {
    if (reactions.isEmpty) return null;
    String? top;
    int max = 0;
    reactions.forEach((key, uids) {
      if (uids.length > max) {
        max = uids.length;
        top = key;
      }
    });
    if (top == null) return null;
    return CommentReaction.values.firstWhere(
      (r) => r.name == top,
      orElse: () => CommentReaction.like,
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
