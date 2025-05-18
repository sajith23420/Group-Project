// lib/models/booking_model.dart

import 'package:post_app/models/enums.dart';
import 'package:post_app/models/money_order_model.dart'; // For PaymentDetails

class BookingModel {
  final String bookingId;
  final String userId;
  final String resortId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final int numberOfUnitsBooked;
  final double totalAmount;
  final String? transactionId;
  final Map<String, dynamic>? paymentGatewayResponse;
  final BookingStatus status;
  final DateTime bookedAt;
  final String? specialRequests;
  final DateTime updatedAt;

  BookingModel({
    required this.bookingId,
    required this.userId,
    required this.resortId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.numberOfUnitsBooked,
    required this.totalAmount,
    this.transactionId,
    this.paymentGatewayResponse,
    required this.status,
    required this.bookedAt,
    this.specialRequests,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: json['bookingId'] as String,
      userId: json['userId'] as String,
      resortId: json['resortId'] as String,
      checkInDate: DateTime.parse(json['checkInDate'] as String),
      checkOutDate: DateTime.parse(json['checkOutDate'] as String),
      numberOfGuests: json['numberOfGuests'] as int,
      numberOfUnitsBooked: json['numberOfUnitsBooked'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      transactionId: json['transactionId'] as String?,
      paymentGatewayResponse:
          json['paymentGatewayResponse'] as Map<String, dynamic>?,
      status: BookingStatus.fromJson(json['status'] as String),
      bookedAt: DateTime.parse(json['bookedAt'] as String),
      specialRequests: json['specialRequests'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'resortId': resortId,
      'checkInDate':
          checkInDate.toIso8601String().split('T').first, // YYYY-MM-DD
      'checkOutDate':
          checkOutDate.toIso8601String().split('T').first, // YYYY-MM-DD
      'numberOfGuests': numberOfGuests,
      'numberOfUnitsBooked': numberOfUnitsBooked,
      'totalAmount': totalAmount,
      'transactionId': transactionId,
      'paymentGatewayResponse': paymentGatewayResponse,
      'status': status.toJson(),
      'bookedAt': bookedAt.toIso8601String(),
      'specialRequests': specialRequests,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BookingModel copyWith({
    String? bookingId,
    String? userId,
    String? resortId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? numberOfGuests,
    int? numberOfUnitsBooked,
    double? totalAmount,
    String? transactionId,
    Map<String, dynamic>? paymentGatewayResponse,
    BookingStatus? status,
    DateTime? bookedAt,
    String? specialRequests,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      resortId: resortId ?? this.resortId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      numberOfUnitsBooked: numberOfUnitsBooked ?? this.numberOfUnitsBooked,
      totalAmount: totalAmount ?? this.totalAmount,
      transactionId: transactionId ?? this.transactionId,
      paymentGatewayResponse:
          paymentGatewayResponse ?? this.paymentGatewayResponse,
      status: status ?? this.status,
      bookedAt: bookedAt ?? this.bookedAt,
      specialRequests: specialRequests ?? this.specialRequests,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// --- Request/Response Models for Booking ---

class CreateBookingRequest {
  final String resortId;
  final String checkInDate; // YYYY-MM-DD
  final String checkOutDate; // YYYY-MM-DD
  final int numberOfGuests;
  final int? numberOfUnitsBooked;
  final String? specialRequests;

  CreateBookingRequest({
    required this.resortId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    this.numberOfUnitsBooked,
    this.specialRequests,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'resortId': resortId,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'numberOfGuests': numberOfGuests,
    };
    if (numberOfUnitsBooked != null) map['numberOfUnitsBooked'] = numberOfUnitsBooked as int;
    if (specialRequests != null) map['specialRequests'] = specialRequests as String;
    return map;
  }
}

class CreateBookingResponse {
  final String message;
  final BookingModel booking;
  final PaymentDetails paymentDetails;

  CreateBookingResponse({
    required this.message,
    required this.booking,
    required this.paymentDetails,
  });

  factory CreateBookingResponse.fromJson(Map<String, dynamic> json) {
    return CreateBookingResponse(
      message: json['message'] as String,
      booking: BookingModel.fromJson(json['booking'] as Map<String, dynamic>),
      paymentDetails: PaymentDetails.fromJson(
          json['paymentDetails'] as Map<String, dynamic>),
    );
  }
}

class ConfirmBookingPaymentRequest {
  final String transactionId;
  final Map<String, dynamic> paymentGatewayResponse;

  ConfirmBookingPaymentRequest({
    required this.transactionId,
    required this.paymentGatewayResponse,
  });

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'paymentGatewayResponse': paymentGatewayResponse,
    };
  }
}

class AdminUpdateBookingStatusRequest {
  final BookingStatus status;

  AdminUpdateBookingStatusRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {
      'status': status.toJson(),
    };
  }
}
