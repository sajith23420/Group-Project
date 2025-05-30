import 'package:post_app/models/enums.dart';

class MailModel {
  final String mailId;
  final String userId;
  final String senderName;
  final String receiverName;
  final String receiverAddress;
  final double weight;
  final ParcelStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  MailModel({
    required this.mailId,
    required this.userId,
    required this.senderName,
    required this.receiverName,
    required this.receiverAddress,
    required this.weight,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MailModel.fromJson(Map<String, dynamic> json) {
    return MailModel(
      mailId: json['mailId'] as String,
      userId: json['userId'] as String,
      senderName: json['senderName'] as String,
      receiverName: json['receiverName'] as String,
      receiverAddress: json['receiverAddress'] as String,
      weight: (json['weight'] as num).toDouble(),
      status: ParcelStatus.fromJson(json['status'] as String),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mailId': mailId,
      'userId': userId,
      'senderName': senderName,
      'receiverName': receiverName,
      'receiverAddress': receiverAddress,
      'weight': weight,
      'status': status.toJson(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// --- Request/Response Models for Mail ---

class CreateMailRequest {
  final String userId;
  final String senderName;
  final String receiverName;
  final String receiverAddress;
  final double weight;
  final String receiverEmail;

  CreateMailRequest({
    required this.userId,
    required this.senderName,
    required this.receiverName,
    required this.receiverAddress,
    required this.weight,
    required this.receiverEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'senderName': senderName,
      'receiverName': receiverName,
      'receiverAddress': receiverAddress,
      'weight': weight,
    };
  }
}

class AdminUpdateMailStatusRequest {
  final ParcelStatus status;

  AdminUpdateMailStatusRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {
      'status': status.toJson(),
    };
  }
}

class CreateMailResponse {
  final String message;
  final MailModel mail;

  CreateMailResponse({
    required this.message,
    required this.mail,
  });

  factory CreateMailResponse.fromJson(Map<String, dynamic> json) {
    return CreateMailResponse(
      message: json['message'] as String,
      mail: MailModel.fromJson(json['mail'] as Map<String, dynamic>),
    );
  }
}

class SendTrackingEmailRequest {
  final String recipientEmail;
  final String trackingNumber;
  final String receiverName;
  final String senderName;

  SendTrackingEmailRequest({
    required this.recipientEmail,
    required this.trackingNumber,
    required this.receiverName,
    required this.senderName,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipientEmail': recipientEmail,
      'trackingNumber': trackingNumber,
      'receiverName': receiverName,
      'senderName': senderName,
    };
  }
}