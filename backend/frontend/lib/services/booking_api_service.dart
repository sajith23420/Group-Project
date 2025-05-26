// lib/services/booking_api_service.dart

import 'package:post_app/models/booking_model.dart';
import 'package:post_app/models/enums.dart';
import 'package:post_app/models/paginated_response_model.dart';
import 'package:post_app/services/api_client.dart';

class BookingApiService {
  final ApiClient _apiClient;

  BookingApiService(this._apiClient);

  Future<CreateBookingResponse> createBooking(
      CreateBookingRequest request) async {
    return _apiClient.post<CreateBookingResponse>(
      '/bookings',
      data: request.toJson(),
      fromJson: (json) =>
          CreateBookingResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BookingModel> confirmBookingPayment(
      String bookingId, ConfirmBookingPaymentRequest request) async {
    return _apiClient.post<BookingModel>(
      '/bookings/$bookingId/confirm-payment',
      data: request.toJson(),
      fromJson: (json) => BookingModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<BookingModel>> getUserBookings() async {
    return _apiClient.getList<BookingModel>(
      '/bookings/my-bookings',
      fromJsonT: (json) => BookingModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BookingModel> getBookingDetails(String bookingId) async {
    return _apiClient.get<BookingModel>(
      '/bookings/$bookingId',
      fromJson: (json) => BookingModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BookingModel> cancelBooking(String bookingId) async {
    return _apiClient.put<BookingModel>(
      '/bookings/$bookingId/cancel', // No body needed for this PUT
      fromJson: (json) => BookingModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PaginatedResponse<BookingModel>> adminGetAllBookings({
    String? resortId,
    BookingStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    int offset = 0,
  }) async {
    final Map<String, dynamic> queryParams = {
      'limit': limit,
      'offset': offset,
    };
    if (resortId != null) queryParams['resortId'] = resortId;
    if (status != null) queryParams['status'] = status.toJson();
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String().split('T').first;
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String().split('T').first;
    }

    return _apiClient.get<PaginatedResponse<BookingModel>>(
      '/bookings/admin/all',
      queryParameters: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(
          json as Map<String, dynamic>,
          (itemJson) =>
              BookingModel.fromJson(itemJson)),
    );
  }

  Future<BookingModel> adminUpdateBookingStatus(
      String bookingId, AdminUpdateBookingStatusRequest request) async {
    return _apiClient.put<BookingModel>(
      '/bookings/admin/$bookingId/status',
      data: request.toJson(),
      fromJson: (json) => BookingModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
