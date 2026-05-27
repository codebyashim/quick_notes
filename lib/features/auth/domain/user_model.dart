import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final int sessionVersion;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const UserModel({
    required this.uid,
    required this.username,
    required this.sessionVersion,
    required this.createdAt,
    required this.lastLoginAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      username: map['username'] as String,
      sessionVersion: (map['sessionVersion'] as num).toInt(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'username': username,
    'sessionVersion': sessionVersion,
    'createdAt': Timestamp.fromDate(createdAt),
    'lastLoginAt': Timestamp.fromDate(lastLoginAt),
  };

  UserModel copyWith({
    String? uid,
    String? username,
    int? sessionVersion,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      sessionVersion: sessionVersion ?? this.sessionVersion,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
