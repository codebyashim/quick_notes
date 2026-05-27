import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String sessionId;
  final String uid;
  final int sessionVersion;
  final DateTime createdAt;
  final DateTime expiresAt;

  const SessionModel({
    required this.sessionId,
    required this.uid,
    required this.sessionVersion,
    required this.createdAt,
    required this.expiresAt,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      sessionId: map['sessionId'] as String,
      uid: map['uid'] as String,
      sessionVersion: (map['sessionVersion'] as num).toInt(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'sessionId': sessionId,
    'uid': uid,
    'sessionVersion': sessionVersion,
    'createdAt': Timestamp.fromDate(createdAt),
    'expiresAt': Timestamp.fromDate(expiresAt),
  };
}
