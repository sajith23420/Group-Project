// lib/models/enums.dart

enum UserRole {
  user,
  admin;

  String toJson() => name;
  static UserRole fromJson(String json) => values.byName(json);
}

enum MoneyOrderStatus {
  pending_payment,
  processing,
  completed,
  failed,
  cancelled;

  String toJson() => name;
  static MoneyOrderStatus fromJson(String json) => values.byName(json);
}

enum BillPaymentStatus {
  pending_payment,
  completed,
  failed;

  String toJson() => name;
  static BillPaymentStatus fromJson(String json) => values.byName(json);
}

enum BillType {
  // ignore: constant_identifier_names
  OSF,
  // ignore: constant_identifier_names
  ExamFee;

  String toJson() => name;
  static BillType fromJson(String json) => values.byName(json);
}

enum BookingStatus {
  pending_payment,
  confirmed,
  cancelled_by_user,
  cancelled_by_admin,
  completed;

  String toJson() => name;
  static BookingStatus fromJson(String json) => values.byName(json);
}

enum FeedbackStatus {
  // ignore: constant_identifier_names
  new_status, // 'new' is a keyword in Dart, changed to new_status for enum member
  under_review,
  resolved,
  closed;

  String toJson() => this == FeedbackStatus.new_status ? 'new' : name;
  static FeedbackStatus fromJson(String json) {
    if (json == 'new') return FeedbackStatus.new_status;
    return values.byName(json);
  }
}

enum PostOfficeService {
  // Using raw string values as they appear in constants.js
  // For actual enum use, you might want to map these to cleaner enum names.
  mail("Mail"),
  moneyOrder("Money Order"),
  billPayment("Bill Payment"),
  resortBooking("Resort Booking");

  const PostOfficeService(this.value);
  final String value;

  String toJson() => value;
  static PostOfficeService fromJson(String jsonValue) {
    return values.firstWhere(
      (e) => e.value == jsonValue,
      orElse:
          () =>
              throw ArgumentError(
                'Unknown PostOfficeService value: $jsonValue',
              ),
    );
  }
}

enum FineStatus {
  payment_pending,
  pay_by_customer,
  payment_confirmed,
  payment_declined;

  String toJson() => name;
  static FineStatus fromJson(String json) => values.byName(json);
}

enum ParcelStatus {
  pending,
  sent,
  in_delivery,
  received_at_destination,
  received_by_receiver;

  String toJson() => name;
  static ParcelStatus fromJson(String json) => values.byName(json);
}
