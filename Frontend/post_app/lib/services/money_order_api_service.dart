// lib/services/money_order_api_service.dart

import 'package:post_app/models/enums.dart';
import 'package:post_app/models/money_order_model.dart';
import 'package:post_app/models/paginated_response_model.dart';
import 'package:post_app/services/api_client.dart';

class MoneyOrderApiService {
  final ApiClient _apiClient;

  MoneyOrderApiService(this._apiClient);

  Future<InitiateMoneyOrderResponse> initiateMoneyOrder(
      InitiateMoneyOrderRequest request) async {
    return _apiClient.post<InitiateMoneyOrderResponse>(
      '/money-orders/initiate',
      data: request.toJson(),
      fromJson: (json) =>
          InitiateMoneyOrderResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<MoneyOrderModel> confirmMoneyOrderPayment(
      String moneyOrderId, ConfirmMoneyOrderPaymentRequest request) async {
    return _apiClient.post<MoneyOrderModel>(
      '/money-orders/$moneyOrderId/confirm-payment',
      data: request.toJson(),
      fromJson: (json) =>
          MoneyOrderModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<MoneyOrderModel>> getUserMoneyOrders() async {
    return _apiClient.getList<MoneyOrderModel>(
      '/money-orders/my-orders',
      fromJsonT: (json) =>
          MoneyOrderModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<MoneyOrderModel> getMoneyOrderDetails(String moneyOrderId) async {
    return _apiClient.get<MoneyOrderModel>(
      '/money-orders/$moneyOrderId',
      fromJson: (json) =>
          MoneyOrderModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PaginatedResponse<MoneyOrderModel>> adminGetAllMoneyOrders({
    MoneyOrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    int offset = 0,
  }) async {
    final Map<String, dynamic> queryParams = {
      'limit': limit,
      'offset': offset,
    };
    if (status != null) queryParams['status'] = status.toJson();
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String().split('T').first;
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String().split('T').first;
    }

    return _apiClient.get<PaginatedResponse<MoneyOrderModel>>(
      '/money-orders/admin/all',
      queryParameters: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(
          json as Map<String, dynamic>,
          (itemJson) =>
              MoneyOrderModel.fromJson(itemJson)),
    );
  }

  Future<MoneyOrderModel> adminUpdateMoneyOrderStatus(
      String moneyOrderId, AdminUpdateMoneyOrderStatusRequest request) async {
    return _apiClient.put<MoneyOrderModel>(
      '/money-orders/admin/$moneyOrderId/status',
      data: request.toJson(),
      fromJson: (json) =>
          MoneyOrderModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
