// lib/models/user_model.dart

import 'package:post_app/models/enums.dart';
import 'package:post_app/models/payment_history_refs_model.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final UserRole role;
  final String? profilePictureUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PaymentHistoryRefs? paymentHistoryRefs;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.phoneNumber,
    required this.role,
    this.profilePictureUrl,
    required this.createdAt,
    required this.updatedAt,
    this.paymentHistoryRefs,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: UserRole.fromJson(json['role'] as String),
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      paymentHistoryRefs: json['paymentHistoryRefs'] == null
          ? null
          : PaymentHistoryRefs.fromJson(
              json['paymentHistoryRefs'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'role': role.toJson(),
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'paymentHistoryRefs': paymentHistoryRefs?.toJson(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    UserRole? role,
    String? profilePictureUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    PaymentHistoryRefs? paymentHistoryRefs,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentHistoryRefs: paymentHistoryRefs ?? this.paymentHistoryRefs,
    );
  }
}

// --- Request/Response Models for User ---

class UpdateUserProfileRequest {
  final String? displayName;
  final String? phoneNumber;

  UpdateUserProfileRequest({this.displayName, this.phoneNumber});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (displayName != null) data['displayName'] = displayName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    return data;
  }
}

class UploadProfilePictureResponse {
  final String message;
  final String profilePictureUrl;
  final UserModel userProfile;

  UploadProfilePictureResponse({
    required this.message,
    required this.profilePictureUrl,
    required this.userProfile,
  });

  factory UploadProfilePictureResponse.fromJson(Map<String, dynamic> json) {
    return UploadProfilePictureResponse(
      message: json['message'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String,
      userProfile:
          UserModel.fromJson(json['userProfile'] as Map<String, dynamic>),
    );
  }
}

class AdminUpdateUserRoleRequest {
  final UserRole role;

  AdminUpdateUserRoleRequest({required this.role});

  Map<String, dynamic> toJson() {
    return {
      'role': role.toJson(),
    };
  }
}
