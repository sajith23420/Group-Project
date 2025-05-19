// lib/models/money_order_model.dart

import 'package:post_app/models/enums.dart';

class MoneyOrderModel {
  final String moneyOrderId;
  final String senderUserId;
  final String recipientName;
  final String recipientAddress;
  final String recipientContact;
  final double amount;
  final double serviceCharge;
  final double totalAmount;
  final String? transactionId;
  final Map<String, dynamic>? paymentGatewayResponse;
  final MoneyOrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  MoneyOrderModel({
    required this.moneyOrderId,
    required this.senderUserId,
    required this.recipientName,
    required this.recipientAddress,
    required this.recipientContact,
    required this.amount,
    required this.serviceCharge,
    required this.totalAmount,
    this.transactionId,
    this.paymentGatewayResponse,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  factory MoneyOrderModel.fromJson(Map<String, dynamic> json) {
    return MoneyOrderModel(
      moneyOrderId: json['moneyOrderId'] as String,
      senderUserId: json['senderUserId'] as String,
      recipientName: json['recipientName'] as String,
      recipientAddress: json['recipientAddress'] as String,
      recipientContact: json['recipientContact'] as String,
      amount: (json['amount'] as num).toDouble(),
      serviceCharge: (json['serviceCharge'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      transactionId: json['transactionId'] as String?,
      paymentGatewayResponse:
          json['paymentGatewayResponse'] as Map<String, dynamic>?,
      status: MoneyOrderStatus.fromJson(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moneyOrderId': moneyOrderId,
      'senderUserId': senderUserId,
      'recipientName': recipientName,
      'recipientAddress': recipientAddress,
      'recipientContact': recipientContact,
      'amount': amount,
      'serviceCharge': serviceCharge,
      'totalAmount': totalAmount,
      'transactionId': transactionId,
      'paymentGatewayResponse': paymentGatewayResponse,
      'status': status.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
    };
  }

  MoneyOrderModel copyWith({
    String? moneyOrderId,
    String? senderUserId,
    String? recipientName,
    String? recipientAddress,
    String? recipientContact,
    double? amount,
    double? serviceCharge,
    double? totalAmount,
    String? transactionId,
    Map<String, dynamic>? paymentGatewayResponse,
    MoneyOrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return MoneyOrderModel(
      moneyOrderId: moneyOrderId ?? this.moneyOrderId,
      senderUserId: senderUserId ?? this.senderUserId,
      recipientName: recipientName ?? this.recipientName,
      recipientAddress: recipientAddress ?? this.recipientAddress,
      recipientContact: recipientContact ?? this.recipientContact,
      amount: amount ?? this.amount,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      totalAmount: totalAmount ?? this.totalAmount,
      transactionId: transactionId ?? this.transactionId,
      paymentGatewayResponse:
          paymentGatewayResponse ?? this.paymentGatewayResponse,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}

// --- Request/Response Models for Money Order ---

class InitiateMoneyOrderRequest {
  final String recipientName;
  final String recipientAddress;
  final String recipientContact;
  final double amount;
  final String? notes;

  InitiateMoneyOrderRequest({
    required this.recipientName,
    required this.recipientAddress,
    required this.recipientContact,
    required this.amount,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'recipientName': recipientName,
      'recipientAddress': recipientAddress,
      'recipientContact': recipientContact,
      'amount': amount,
    };
    if (notes != null) map['notes'] = notes as String;
    return map;
  }
}

class PaymentDetails {
  final double payableAmount;

  PaymentDetails({required this.payableAmount});

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      payableAmount: (json['payableAmount'] as num).toDouble(),
    );
  }
}

class InitiateMoneyOrderResponse {
  final String message;
  final MoneyOrderModel moneyOrder;
  final PaymentDetails paymentDetails;

  InitiateMoneyOrderResponse({
    required this.message,
    required this.moneyOrder,
    required this.paymentDetails,
  });

  factory InitiateMoneyOrderResponse.fromJson(Map<String, dynamic> json) {
    return InitiateMoneyOrderResponse(
      message: json['message'] as String,
      moneyOrder:
          MoneyOrderModel.fromJson(json['moneyOrder'] as Map<String, dynamic>),
      paymentDetails: PaymentDetails.fromJson(
          json['paymentDetails'] as Map<String, dynamic>),
    );
  }
}

class ConfirmMoneyOrderPaymentRequest {
  final String transactionId;
  final Map<String, dynamic> paymentGatewayResponse;
  final MoneyOrderStatus status;

  ConfirmMoneyOrderPaymentRequest({
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

class AdminUpdateMoneyOrderStatusRequest {
  final MoneyOrderStatus status;

  AdminUpdateMoneyOrderStatusRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {
      'status': status.toJson(),
    };
  }
}
