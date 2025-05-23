// lib/services/officer_api_service.dart

import 'package:post_app/models/officer_model.dart';
import 'package:post_app/services/api_client.dart';

class OfficerApiService {
  final ApiClient _apiClient;

  OfficerApiService(this._apiClient);

  Future<OfficerModel> createOfficer(CreateOfficerRequest request) async {
    return _apiClient.post<OfficerModel>(
      '/officers',
      data: request.toJson(),
      fromJson: (json) => OfficerModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<OfficerModel> getOfficerById(String officerId) async {
    return _apiClient.get<OfficerModel>(
      '/officers/$officerId',
      fromJson: (json) => OfficerModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<OfficerModel>> getOfficersByPostOffice(
      String postOfficeId) async {
    return _apiClient.getList<OfficerModel>(
      '/officers/by-post-office/$postOfficeId',
      fromJsonT: (json) => OfficerModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<OfficerModel>> getAllOfficers() async {
    return _apiClient.getList<OfficerModel>(
      '/officers',
      fromJsonT: (json) => OfficerModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<OfficerModel> updateOfficer(
      String officerId, UpdateOfficerRequest request) async {
    return _apiClient.put<OfficerModel>(
      '/officers/$officerId',
      data: request.toJson(),
      fromJson: (json) => OfficerModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Map<String, dynamic>> deleteOfficer(String officerId) async {
    return _apiClient.delete<Map<String, dynamic>>(
      '/officers/$officerId',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
