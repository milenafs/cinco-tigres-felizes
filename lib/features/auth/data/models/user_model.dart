import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa o perfil persistido do usuário no Firestore.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final bool onboardingCompleted;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.onboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'onboardingCompleted': onboardingCompleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: map['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}
