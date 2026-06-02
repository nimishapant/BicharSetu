import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String uid;
  final String username;
  final String profilePhoto;
  final String title;
  final String body;
  final String category;
  final List<String> keywords;
  final List<String> likes;
  final int commentCount;
  final int shareCount;
  final DateTime? createdAt;

  PostModel({
    required this.postId,
    required this.uid,
    required this.username,
    this.profilePhoto = '',
    this.title = '',
    this.body = '',
    this.category = '',
    this.keywords = const [],
    this.likes = const [],
    this.commentCount = 0,
    this.shareCount = 0,
    this.createdAt,
  });

  // Convert to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'uid': uid,
      'username': username,
      'profilePhoto': profilePhoto,
      'title': title,
      'body': body,
      'category': category,
      'keywords': keywords,
      'likes': likes,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // Create PostModel from Firestore Map
  factory PostModel.fromMap(Map<String, dynamic> map) {
    DateTime? createdTime;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        createdTime = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is int) {
        createdTime = DateTime.fromMillisecondsSinceEpoch(map['createdAt']);
      }
    }

    return PostModel(
      postId: map['postId'] ?? '',
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      category: map['category'] ?? '',
      keywords: List<String>.from(map['keywords'] ?? []),
      likes: List<String>.from(map['likes'] ?? []),
      commentCount: map['commentCount'] ?? 0,
      shareCount: map['shareCount'] ?? 0,
      createdAt: createdTime,
    );
  }

  // Create a copy with optional updated values
  PostModel copyWith({
    String? postId,
    String? uid,
    String? username,
    String? profilePhoto,
    String? title,
    String? body,
    String? category,
    List<String>? keywords,
    List<String>? likes,
    int? commentCount,
    int? shareCount,
    DateTime? createdAt,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      uid: uid ?? this.uid,
      username: username ?? this.username,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      keywords: keywords ?? this.keywords,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convenience: number of likes
  int get likeCount => likes.length;

  /// Human-readable time ago string
  String get timeAgo {
    if (createdAt == null) return 'Just now';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }
}
