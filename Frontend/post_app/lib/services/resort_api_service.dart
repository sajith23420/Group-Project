// lib/services/resort_api_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:post_app/models/paginated_response_model.dart';
import 'package:post_app/models/resort_model.dart';
import 'package:post_app/services/api_client.dart';
import 'package:path/path.dart' as p;

class ResortApiService {
  final ApiClient _apiClient;

  ResortApiService(this._apiClient);

  Future<ResortModel> createResort(CreateResortRequest request) async {
    return _apiClient.post<ResortModel>(
      '/resorts',
      data: request.toJson(),
      fromJson: (json) => ResortModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResortModel> getResortById(String resortId) async {
    return _apiClient.get<ResortModel>(
      '/resorts/$resortId',
      fromJson: (json) => ResortModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PaginatedResponse<ResortModel>> getAllResorts({
    int limit = 10,
    int offset = 0,
    String? location,
    List<String>? amenities, // Pass as comma-separated string in query
    double? minPrice,
    double? maxPrice,
  }) async {
    final Map<String, dynamic> queryParams = {
      'limit': limit,
      'offset': offset,
    };
    if (location != null) queryParams['location'] = location;
    if (amenities != null && amenities.isNotEmpty)
      queryParams['amenities'] = amenities.join(',');
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;

    return _apiClient.get<PaginatedResponse<ResortModel>>(
      '/resorts',
      queryParameters: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(
          json as Map<String, dynamic>,
          (itemJson) => ResortModel.fromJson(itemJson)),
    );
  }

  Future<ResortModel> updateResort(
      String resortId, UpdateResortRequest request) async {
    return _apiClient.put<ResortModel>(
      '/resorts/$resortId',
      data: request.toJson(),
      fromJson: (json) => ResortModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Map<String, dynamic>> deleteResort(String resortId) async {
    return _apiClient.delete<Map<String, dynamic>>(
      '/resorts/$resortId',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<CheckResortAvailabilityResponse> checkResortAvailability(
      String resortId, CheckResortAvailabilityRequest request) async {
    return _apiClient.post<CheckResortAvailabilityResponse>(
      '/resorts/$resortId/check-availability',
      data: request.toJson(),
      fromJson: (json) => CheckResortAvailabilityResponse.fromJson(
          json as Map<String, dynamic>),
    );
  }

  Future<UploadResortImageResponse> uploadResortImage(
      String resortId, File imageFile) async {
    String fileName = p.basename(imageFile.path);
    FormData formData = FormData.fromMap({
      "resortImage":
          await MultipartFile.fromFile(imageFile.path, filename: fileName),
    });

    return _apiClient.postMultipart<UploadResortImageResponse>(
      '/resorts/$resortId/images',
      formData,
      fromJson: (json) =>
          UploadResortImageResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<DeleteResortImageResponse> deleteResortImage(
      String resortId, DeleteResortImageRequest request) async {
    return _apiClient.delete<DeleteResortImageResponse>(
      '/resorts/$resortId/images/delete',
      data: request.toJson(),
      fromJson: (json) =>
          DeleteResortImageResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
