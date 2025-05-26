import 'package:post_app/models/enums.dart';

class FineModel {
  final String fineId;
  final String userId;
  final String reason;
  final double amount;
  final FineStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  FineModel({
    required this.fineId,
    required this.userId,
    required this.reason,
    required this.amount,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FineModel.fromJson(Map<String, dynamic> json) {
    return FineModel(
      fineId: json['fineId'] as String,
      userId: json['userId'] as String,
      reason: json['reason'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: FineStatus.fromJson(json['status'] as String),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fineId': fineId,
      'userId': userId,
      'reason': reason,
      'amount': amount,
      'status': status.toJson(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// --- Request/Response Models for Fine ---

class CreateFineRequest {
  final String userId;
  final String reason;
  final double amount;

  CreateFineRequest({
    required this.userId,
    required this.reason,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'reason': reason,
      'amount': amount,
    };
  }
}

class AdminUpdateFineStatusRequest {
  final FineStatus status;

  AdminUpdateFineStatusRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {
      'status': status.toJson(),
    };
  }
}

class CreateFineResponse {
  final String message;
  final FineModel fine;

  CreateFineResponse({
    required this.message,
    required this.fine,
  });

  factory CreateFineResponse.fromJson(Map<String, dynamic> json) {
    return CreateFineResponse(
      message: json['message'] as String,
      fine: FineModel.fromJson(json['fine'] as Map<String, dynamic>),
    );
  }
}