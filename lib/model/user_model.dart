import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String aboutMe;
  final String profilePhoto;
  final String coverPhoto;
  final String profession;
  final String location;
  final List<String> galleryPhotos;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.aboutMe = '',
    this.profilePhoto = '',
    this.coverPhoto = '',
    this.profession = '',
    this.location = '',
    this.galleryPhotos = const [],
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'aboutMe': aboutMe,
      'profilePhoto': profilePhoto,
      'coverPhoto': coverPhoto,
      'profession': profession,
      'location': location,
      'galleryPhotos': galleryPhotos,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime? createdTime;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        createdTime = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is int) {
        createdTime = DateTime.fromMillisecondsSinceEpoch(map['createdAt']);
      }
    }

    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      aboutMe: map['aboutMe'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      coverPhoto: map['coverPhoto'] ?? '',
      profession: map['profession'] ?? '',
      location: map['location'] ?? '',
      galleryPhotos: (map['galleryPhotos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: createdTime,
    );
  }

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? aboutMe,
    String? profilePhoto,
    String? coverPhoto,
    String? profession,
    String? location,
    List<String>? galleryPhotos,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      aboutMe: aboutMe ?? this.aboutMe,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      profession: profession ?? this.profession,
      location: location ?? this.location,
      galleryPhotos: galleryPhotos ?? this.galleryPhotos,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
