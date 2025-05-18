// lib/services/post_office_api_service.dart

import 'package:post_app/models/enums.dart';
import 'package:post_app/models/paginated_response_model.dart';
import 'package:post_app/models/post_office_model.dart';
import 'package:post_app/services/api_client.dart';

class PostOfficeApiService {
  final ApiClient _apiClient;

  PostOfficeApiService(this._apiClient);

  Future<PostOfficeModel> createPostOffice(
      CreatePostOfficeRequest request) async {
    return _apiClient.post<PostOfficeModel>(
      '/post-offices',
      data: request.toJson(),
      fromJson: (json) =>
          PostOfficeModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PostOfficeModel> getPostOfficeById(String postOfficeId) async {
    return _apiClient.get<PostOfficeModel>(
      '/post-offices/$postOfficeId',
      fromJson: (json) =>
          PostOfficeModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PaginatedResponse<PostOfficeModel>> getAllPostOffices({
    int limit = 10,
    int offset = 0,
    String? name,
    String? postalCode,
    PostOfficeService? service,
  }) async {
    final Map<String, dynamic> queryParams = {
      'limit': limit,
      'offset': offset,
    };
    if (name != null) queryParams['name'] = name;
    if (postalCode != null) queryParams['postalCode'] = postalCode;
    if (service != null) queryParams['service'] = service.toJson();

    return _apiClient.get<PaginatedResponse<PostOfficeModel>>(
      '/post-offices',
      queryParameters: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(
          json as Map<String, dynamic>,
          (itemJson) =>
              PostOfficeModel.fromJson(itemJson)),
    );
  }

  Future<PaginatedResponse<PostOfficeModel>> searchPostOffices({
    int limit = 10,
    int offset = 0,
    String? name,
    String? postalCode,
    PostOfficeService? service,
  }) async {
    final Map<String, dynamic> queryParams = {
      'limit': limit,
      'offset': offset,
    };
    if (name != null) queryParams['name'] = name;
    if (postalCode != null) queryParams['postalCode'] = postalCode;
    if (service != null) queryParams['service'] = service.toJson();

    return _apiClient.get<PaginatedResponse<PostOfficeModel>>(
      '/post-offices/search',
      queryParameters: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(
          json as Map<String, dynamic>,
          (itemJson) =>
              PostOfficeModel.fromJson(itemJson)),
    );
  }

  Future<PostOfficeModel> updatePostOffice(
      String postOfficeId, UpdatePostOfficeRequest request) async {
    return _apiClient.put<PostOfficeModel>(
      '/post-offices/$postOfficeId',
      data: request.toJson(),
      fromJson: (json) =>
          PostOfficeModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Map<String, dynamic>> deletePostOffice(String postOfficeId) async {
    // Backend returns { message: 'Post office deleted successfully.' }
    return _apiClient.delete<Map<String, dynamic>>(
      '/post-offices/$postOfficeId',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
