// lib/models/feedback_model.dart

import 'package:post_app/models/enums.dart';

class FeedbackModel {
  final String feedbackId;
  final String userId;
  final String? postOfficeId;
  final String subject;
  final String message;
  final int? rating;
  final DateTime submittedAt;
  final FeedbackStatus status;
  final String? adminResponse;

  FeedbackModel({
    required this.feedbackId,
    required this.userId,
    this.postOfficeId,
    required this.subject,
    required this.message,
    this.rating,
    required this.submittedAt,
    required this.status,
    this.adminResponse,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      feedbackId: json['feedbackId'] as String,
      userId: json['userId'] as String,
      postOfficeId: json['postOfficeId'] as String?,
      subject: json['subject'] as String,
      message: json['message'] as String,
      rating: json['rating'] as int?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      status: FeedbackStatus.fromJson(json['status'] as String),
      adminResponse: json['adminResponse'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feedbackId': feedbackId,
      'userId': userId,
      'postOfficeId': postOfficeId,
      'subject': subject,
      'message': message,
      'rating': rating,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status.toJson(),
      'adminResponse': adminResponse,
    };
  }

  FeedbackModel copyWith({
    String? feedbackId,
    String? userId,
    String? postOfficeId,
    String? subject,
    String? message,
    int? rating,
    DateTime? submittedAt,
    FeedbackStatus? status,
    String? adminResponse,
  }) {
    return FeedbackModel(
      feedbackId: feedbackId ?? this.feedbackId,
      userId: userId ?? this.userId,
      postOfficeId: postOfficeId ?? this.postOfficeId,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      rating: rating ?? this.rating,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      adminResponse: adminResponse ?? this.adminResponse,
    );
  }
}

// --- Request/Response Models for Feedback ---

class SubmitFeedbackRequest {
  final String? postOfficeId;
  final String subject;
  final String message;
  final int? rating;

  SubmitFeedbackRequest({
    this.postOfficeId,
    required this.subject,
    required this.message,
    this.rating,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'subject': subject,
      'message': message,
    };
    if (postOfficeId != null) map['postOfficeId'] = postOfficeId as String;
    if (rating != null) map['rating'] = rating as String;
    return map;
  }
}

class AdminUpdateFeedbackStatusRequest {
  final FeedbackStatus status;
  final String? adminResponse;

  AdminUpdateFeedbackStatusRequest({required this.status, this.adminResponse});

  Map<String, dynamic> toJson() {
    final map = {'status': status.toJson()};
    if (adminResponse != null) map['adminResponse'] = adminResponse as String;
    return map;
  }
}
