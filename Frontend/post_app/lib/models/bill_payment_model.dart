// lib/models/bill_payment_model.dart

import 'package:post_app/models/enums.dart';
import 'package:post_app/models/money_order_model.dart'; // For PaymentDetails

class BillPaymentModel {
  final String billPaymentId;
  final String userId;
  final BillType billType;
  final String billReferenceNumber;
  final String billerName;
  final double amount;
  final String? transactionId;
  final Map<String, dynamic>? paymentGatewayResponse;
  final BillPaymentStatus status;
  final DateTime? paymentDate;
  final DateTime createdAt;

  BillPaymentModel({
    required this.billPaymentId,
    required this.userId,
    required this.billType,
    required this.billReferenceNumber,
    required this.billerName,
    required this.amount,
    this.transactionId,
    this.paymentGatewayResponse,
    required this.status,
    this.paymentDate,
    required this.createdAt,
  });

  factory BillPaymentModel.fromJson(Map<String, dynamic> json) {
    return BillPaymentModel(
      billPaymentId: json['billPaymentId'] as String,
      userId: json['userId'] as String,
      billType: BillType.fromJson(json['billType'] as String),
      billReferenceNumber: json['billReferenceNumber'] as String,
      billerName: json['billerName'] as String,
      amount: (json['amount'] as num).toDouble(),
      transactionId: json['transactionId'] as String?,
      paymentGatewayResponse:
          json['paymentGatewayResponse'] as Map<String, dynamic>?,
      status: BillPaymentStatus.fromJson(json['status'] as String),
      paymentDate: json['paymentDate'] == null
          ? null
          : DateTime.parse(json['paymentDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billPaymentId': billPaymentId,
      'userId': userId,
      'billType': billType.toJson(),
      'billReferenceNumber': billReferenceNumber,
      'billerName': billerName,
      'amount': amount,
      'transactionId': transactionId,
      'paymentGatewayResponse': paymentGatewayResponse,
      'status': status.toJson(),
      'paymentDate': paymentDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  BillPaymentModel copyWith({
    String? billPaymentId,
    String? userId,
    BillType? billType,
    String? billReferenceNumber,
    String? billerName,
    double? amount,
    String? transactionId,
    Map<String, dynamic>? paymentGatewayResponse,
    BillPaymentStatus? status,
    DateTime? paymentDate,
    DateTime? createdAt,
  }) {
    return BillPaymentModel(
      billPaymentId: billPaymentId ?? this.billPaymentId,
      userId: userId ?? this.userId,
      billType: billType ?? this.billType,
      billReferenceNumber: billReferenceNumber ?? this.billReferenceNumber,
      billerName: billerName ?? this.billerName,
      amount: amount ?? this.amount,
      transactionId: transactionId ?? this.transactionId,
      paymentGatewayResponse:
          paymentGatewayResponse ?? this.paymentGatewayResponse,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// --- Request/Response Models for Bill Payment ---

class InitiateBillPaymentRequest {
  final BillType billType;
  final String billReferenceNumber;
  final String billerName;
  final double amount;

  InitiateBillPaymentRequest({
    required this.billType,
    required this.billReferenceNumber,
    required this.billerName,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'billType': billType.toJson(),
      'billReferenceNumber': billReferenceNumber,
      'billerName': billerName,
      'amount': amount,
    };
  }
}

class InitiateBillPaymentResponse {
  final String message;
  final BillPaymentModel billPayment;
  final PaymentDetails paymentDetails;

  InitiateBillPaymentResponse({
    required this.message,
    required this.billPayment,
    required this.paymentDetails,
  });

  factory InitiateBillPaymentResponse.fromJson(Map<String, dynamic> json) {
    return InitiateBillPaymentResponse(
      message: json['message'] as String,
      billPayment: BillPaymentModel.fromJson(
          json['billPayment'] as Map<String, dynamic>),
      paymentDetails: PaymentDetails.fromJson(
          json['paymentDetails'] as Map<String, dynamic>),
    );
  }
}

class ConfirmBillPaymentRequest {
  final String transactionId;
  final Map<String, dynamic> paymentGatewayResponse;
  final BillPaymentStatus status;

  ConfirmBillPaymentRequest({
    required this.transactionId,
    required this.paymentGatewayResponse,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'paymentGatewayResponse': paymentGatewayResponse,
      'status': status.toJson(),
    };
  }
}
