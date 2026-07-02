import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repo/auth_service.dart';

enum InteractionPermission {
  everyone,
  followersOnly,
  nobody;

  String get label {
    switch (this) {
      case InteractionPermission.everyone:
        return 'Everyone';
      case InteractionPermission.followersOnly:
        return 'Followers Only';
      case InteractionPermission.nobody:
        return 'Nobody';
    }
  }
}

class PrivacyController extends ChangeNotifier {
  PrivacyController._();
  static final PrivacyController instance = PrivacyController._();
  factory PrivacyController() => instance;

  static const String _prefShowProfile = 'privacy_show_profile';
  static const String _prefShowOnline = 'privacy_show_online';
  static const String _prefCommentPermission = 'privacy_comment_permission';
  static const String _prefMessagePermission = 'privacy_message_permission';
  static const String _prefMentionPermission = 'privacy_mention_permission';
  static const String _prefSensitiveFilter = 'privacy_sensitive_filter';

  bool _showProfileInfo = true;
  bool _showOnlineStatus = true;
  InteractionPermission _commentPermission = InteractionPermission.everyone;
  InteractionPermission _messagePermission = InteractionPermission.everyone;
  InteractionPermission _mentionPermission = InteractionPermission.everyone;
  bool _sensitiveContentFilter = false;

  bool get showProfileInfo => _showProfileInfo;
  bool get showOnlineStatus => _showOnlineStatus;
  InteractionPermission get commentPermission => _commentPermission;
  InteractionPermission get messagePermission => _messagePermission;
  InteractionPermission get mentionPermission => _mentionPermission;
  bool get sensitiveContentFilter => _sensitiveContentFilter;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _showProfileInfo = prefs.getBool(_prefShowProfile) ?? true;
    _showOnlineStatus = prefs.getBool(_prefShowOnline) ?? true;
    _commentPermission = InteractionPermission.values[prefs.getInt(_prefCommentPermission) ?? 0];
    _messagePermission = InteractionPermission.values[prefs.getInt(_prefMessagePermission) ?? 0];
    _mentionPermission = InteractionPermission.values[prefs.getInt(_prefMentionPermission) ?? 0];
    _sensitiveContentFilter = prefs.getBool(_prefSensitiveFilter) ?? false;
    notifyListeners();
  }

  Future<void> setShowProfileInfo(bool value) async {
    _showProfileInfo = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool(_prefShowProfile, value);
  }

  Future<void> setShowOnlineStatus(bool value) async {
    _showOnlineStatus = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool(_prefShowOnline, value);
  }

  Future<void> setCommentPermission(InteractionPermission value) async {
    _commentPermission = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setInt(_prefCommentPermission, value.index);
  }

  Future<void> setMessagePermission(InteractionPermission value) async {
    _messagePermission = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setInt(_prefMessagePermission, value.index);
  }

  Future<void> setMentionPermission(InteractionPermission value) async {
    _mentionPermission = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setInt(_prefMentionPermission, value.index);
  }

  Future<void> setSensitiveContentFilter(bool value) async {
    _sensitiveContentFilter = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool(_prefSensitiveFilter, value);
  }
}
