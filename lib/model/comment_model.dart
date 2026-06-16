import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String postId;
  final String uid;
  final String username;
  final String profilePhoto;
  final String text;
  final DateTime? createdAt;

  CommentModel({
    required this.commentId,
    required this.postId,
    required this.uid,
    required this.username,
    this.profilePhoto = '',
    required this.text,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'postId': postId,
      'uid': uid,
      'username': username,
      'profilePhoto': profilePhoto,
      'text': text,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    DateTime? createdTime;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        createdTime = (map['createdAt'] as Timestamp).toDate();
      }
    }
    return CommentModel(
      commentId: map['commentId'] ?? '',
      postId: map['postId'] ?? '',
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      text: map['text'] ?? '',
      createdAt: createdTime,
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
