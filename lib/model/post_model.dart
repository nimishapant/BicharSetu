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
  final String imageUrl;
  /// Index into the post background palette (0 = no background / default card).
  final int backgroundIndex;
  final DateTime? createdAt;
  final DateTime? editedAt; // non-null if post was edited

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
    this.imageUrl = '',
    this.backgroundIndex = 0,
    this.createdAt,
    this.editedAt,
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
      'imageUrl': imageUrl,
      'backgroundIndex': backgroundIndex,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      if (editedAt != null) 'editedAt': Timestamp.fromDate(editedAt!),
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
      imageUrl: map['imageUrl'] ?? '',
      backgroundIndex: (map['backgroundIndex'] as int?) ?? 0,
      createdAt: createdTime,
      editedAt: map['editedAt'] is Timestamp
          ? (map['editedAt'] as Timestamp).toDate()
          : null,
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
    String? imageUrl,
    int? backgroundIndex,
    DateTime? createdAt,
    DateTime? editedAt,
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
      imageUrl: imageUrl ?? this.imageUrl,
      backgroundIndex: backgroundIndex ?? this.backgroundIndex,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  /// True if this post was created less than 24 hours ago.
  bool get canEdit {
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt!).inHours < 24;
  }

  /// Convenience: number of likes
  int get likeCount => likes.length;

  /// Human-readable time ago string, with "(edited)" suffix if applicable.
  String get timeAgo {
    final base = createdAt == null ? 'Just now' : _formatDiff(DateTime.now().difference(createdAt!));
    return editedAt != null ? '$base · Edited' : base;
  }

  String _formatDiff(Duration diff) {
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }
}
