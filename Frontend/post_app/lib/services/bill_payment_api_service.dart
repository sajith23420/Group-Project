// lib/services/bill_payment_api_service.dart

import 'package:post_app/models/bill_payment_model.dart';
import 'package:post_app/models/enums.dart';
import 'package:post_app/models/paginated_response_model.dart';
import 'package:post_app/services/api_client.dart';

class BillPaymentApiService {
  final ApiClient _apiClient;

  BillPaymentApiService(this._apiClient);

  Future<List<BillType>> getAvailableBillTypes() async {
    // Backend returns a list of strings for bill types
    final List<dynamic> rawTypes =
        await _apiClient.get<List<dynamic>>('/bill-payments/types');
    return rawTypes
        .map((typeStr) => BillType.fromJson(typeStr as String))
        .toList();
  }

  Future<InitiateBillPaymentResponse> initiateBillPayment(
      InitiateBillPaymentRequest request) async {
    return _apiClient.post<InitiateBillPaymentResponse>(
      '/bill-payments/initiate',
      data: request.toJson(),
      fromJson: (json) =>
          InitiateBillPaymentResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BillPaymentModel> confirmBillPayment(
      String billPaymentId, ConfirmBillPaymentRequest request) async {
    return _apiClient.post<BillPaymentModel>(
      '/bill-payments/$billPaymentId/confirm-payment',
      data: request.toJson(),
      fromJson: (json) =>
          BillPaymentModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<BillPaymentModel>> getUserBillPayments() async {
    return _apiClient.getList<BillPaymentModel>(
      '/bill-payments/my-payments',
      fromJsonT: (json) =>
          BillPaymentModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BillPaymentModel> getBillPaymentDetails(String billPaymentId) async {
    return _apiClient.get<BillPaymentModel>(
      '/bill-payments/$billPaymentId',
      fromJson: (json) =>
          BillPaymentModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PaginatedResponse<BillPaymentModel>> adminGetAllBillPayments({
    BillType? billType,
    BillPaymentStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    int offset = 0,
  }) async {
    final Map<String, dynamic> queryParams = {
      'limit': limit,
      'offset': offset,
    };
    if (billType != null) queryParams['billType'] = billType.toJson();
    if (status != null) queryParams['status'] = status.toJson();
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String().split('T').first;
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String().split('T').first;
    }

    return _apiClient.get<PaginatedResponse<BillPaymentModel>>(
      '/bill-payments/admin/all',
      queryParameters: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(
          json as Map<String, dynamic>,
          (itemJson) =>
              BillPaymentModel.fromJson(itemJson)),
    );
  }
}
