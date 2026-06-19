import 'package:cloud_firestore/cloud_firestore.dart';

/// Mood options for a diary entry.
enum DiaryMood { happy, neutral, sad, excited, anxious, grateful }

extension DiaryMoodX on DiaryMood {
  String get emoji {
    switch (this) {
      case DiaryMood.happy:    return '😊';
      case DiaryMood.neutral:  return '😐';
      case DiaryMood.sad:      return '😢';
      case DiaryMood.excited:  return '🤩';
      case DiaryMood.anxious:  return '😰';
      case DiaryMood.grateful: return '🙏';
    }
  }

  String get label {
    switch (this) {
      case DiaryMood.happy:    return 'Happy';
      case DiaryMood.neutral:  return 'Neutral';
      case DiaryMood.sad:      return 'Sad';
      case DiaryMood.excited:  return 'Excited';
      case DiaryMood.anxious:  return 'Anxious';
      case DiaryMood.grateful: return 'Grateful';
    }
  }
}

class DiaryEntryModel {
  final String entryId;
  final String uid;
  final String title;
  final String body;
  final DiaryMood mood;

  /// Whether this entry is visible to other users (Public Diaries tab).
  final bool isPublic;

  /// The date this entry is FOR (can differ from createdAt if backdated).
  final DateTime entryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DiaryEntryModel({
    required this.entryId,
    required this.uid,
    required this.title,
    required this.body,
    this.mood = DiaryMood.neutral,
    this.isPublic = false,
    required this.entryDate,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'entryId':   entryId,
      'uid':       uid,
      'title':     title,
      'body':      body,
      'mood':      mood.name,
      'isPublic':  isPublic,
      'entryDate': Timestamp.fromDate(entryDate),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  factory DiaryEntryModel.fromMap(Map<String, dynamic> map) {
    DateTime? ts(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return null;
    }

    final moodStr = map['mood'] as String? ?? 'neutral';
    final mood = DiaryMood.values.firstWhere(
      (m) => m.name == moodStr,
      orElse: () => DiaryMood.neutral,
    );

    return DiaryEntryModel(
      entryId:   map['entryId'] ?? '',
      uid:       map['uid'] ?? '',
      title:     map['title'] ?? '',
      body:      map['body'] ?? '',
      mood:      mood,
      isPublic:  (map['isPublic'] as bool?) ?? false,
      entryDate: ts(map['entryDate']) ?? DateTime.now(),
      createdAt: ts(map['createdAt']),
      updatedAt: ts(map['updatedAt']),
    );
  }

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return '${days[entryDate.weekday % 7]}, ${months[entryDate.month - 1]} ${entryDate.day}, ${entryDate.year}';
  }
}
