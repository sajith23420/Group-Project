import 'package:post_app/models/fine_model.dart';
import 'package:post_app/services/api_client.dart';

class FineApiService {
  final ApiClient _apiClient;

  FineApiService(this._apiClient);

  Future<CreateFineResponse> createFine(CreateFineRequest request) async {
    return _apiClient.post<CreateFineResponse>(
      '/fines',
      data: request.toJson(),
      fromJson: (json) => CreateFineResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> customerPayFine(String fineId) async {
    await _apiClient.put<void>(
      '/fines/$fineId/pay',
    );
  }

  Future<void> adminUpdateFineStatus(String fineId, AdminUpdateFineStatusRequest request) async {
    await _apiClient.put<void>(
      '/fines/admin/$fineId/status',
      data: request.toJson(),
    );
  }

  Future<List<FineModel>> getUserFines() async {
    return _apiClient.getList<FineModel>(
      '/fines/my-fines',
      fromJsonT: (json) => FineModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<FineModel>> adminGetAllFines() async {
    return _apiClient.getList<FineModel>(
      '/fines/admin/all',
      fromJsonT: (json) => FineModel.fromJson(json as Map<String, dynamic>),
    );
  }
}