import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountStanding {
  goodStanding,
  warning,
  restricted,
  suspended;

  String get label {
    switch (this) {
      case AccountStanding.goodStanding:
        return 'Good Standing';
      case AccountStanding.warning:
        return 'Warning';
      case AccountStanding.restricted:
        return 'Restricted';
      case AccountStanding.suspended:
        return 'Suspended';
    }
  }
}

class AccountStatusModel {
  final String uid;
  final AccountStanding standing;
  final int warningCount;
  final String message;
  final List<AccountAction> actions;
  final DateTime updatedAt;

  AccountStatusModel({
    required this.uid,
    required this.standing,
    required this.warningCount,
    required this.message,
    required this.actions,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'standing': standing.name,
      'warningCount': warningCount,
      'message': message,
      'actions': actions.map((a) => a.toMap()).toList(),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory AccountStatusModel.fromMap(Map<String, dynamic> map) {
    return AccountStatusModel(
      uid: map['uid'] ?? '',
      standing: AccountStanding.values.firstWhere(
        (e) => e.name == map['standing'],
        orElse: () => AccountStanding.goodStanding,
      ),
      warningCount: map['warningCount'] ?? 0,
      message: map['message'] ?? '',
      actions: (map['actions'] as List<dynamic>?)
              ?.map((a) => AccountAction.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static AccountStatusModel initial(String uid) {
    return AccountStatusModel(
      uid: uid,
      standing: AccountStanding.goodStanding,
      warningCount: 0,
      message: 'Your account is currently in good standing. No violations or restrictions were found.',
      actions: [],
      updatedAt: DateTime.now(),
    );
  }
}

class AccountAction {
  final String reason;
  final DateTime timestamp;
  final String type; // e.g., 'Warning', 'Restriction'

  AccountAction({
    required this.reason,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'reason': reason,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
    };
  }

  factory AccountAction.fromMap(Map<String, dynamic> map) {
    return AccountAction(
      reason: map['reason'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: map['type'] ?? '',
    );
  }
}
