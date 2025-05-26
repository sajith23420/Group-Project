// lib/models/payment_history_refs_model.dart

class PaymentHistoryRefs {
  final Map<String, bool>? moneyOrders;
  final Map<String, bool>? billPayments;
  final Map<String, bool>? bookings;

  PaymentHistoryRefs({
    this.moneyOrders,
    this.billPayments,
    this.bookings,
  });

  factory PaymentHistoryRefs.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryRefs(
      moneyOrders: (json['moneyOrders'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as bool)),
      billPayments: (json['billPayments'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as bool)),
      bookings: (json['bookings'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as bool)),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (moneyOrders != null) {
      data['moneyOrders'] = moneyOrders;
    }
    if (billPayments != null) {
      data['billPayments'] = billPayments;
    }
    if (bookings != null) {
      data['bookings'] = bookings;
    }
    return data;
  }

  PaymentHistoryRefs copyWith({
    Map<String, bool>? moneyOrders,
    Map<String, bool>? billPayments,
    Map<String, bool>? bookings,
  }) {
    return PaymentHistoryRefs(
      moneyOrders: moneyOrders ?? this.moneyOrders,
      billPayments: billPayments ?? this.billPayments,
      bookings: bookings ?? this.bookings,
    );
  }
}