// lib/services/feedback_api_service.dart

import 'package:post_app/models/enums.dart';
import 'package:post_app/models/feedback_model.dart';
import 'package:post_app/models/paginated_response_model.dart';
import 'package:post_app/services/api_client.dart';

class FeedbackApiService {
  final ApiClient _apiClient;

  FeedbackApiService(this._apiClient);

  Future<FeedbackModel> submitFeedback(SubmitFeedbackRequest request) async {
    return _apiClient.post<FeedbackModel>(
      '/feedback',
      data: request.toJson(),
      fromJson: (json) => FeedbackModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<FeedbackModel>> getUserFeedback() async {
    return _apiClient.getList<FeedbackModel>(
      '/feedback/my-feedback',
      fromJsonT: (json) => FeedbackModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PaginatedResponse<FeedbackModel>> adminGetAllFeedback({
    FeedbackStatus? status,
    String? postOfficeId,
    int limit = 20,
    int offset = 0,
  }) async {
    final Map<String, dynamic> queryParams = {
      'limit': limit,
      'offset': offset,
    };
    if (status != null) queryParams['status'] = status.toJson();
    if (postOfficeId != null) queryParams['postOfficeId'] = postOfficeId;

    return _apiClient.get<PaginatedResponse<FeedbackModel>>(
      '/feedback/admin/all',
      queryParameters: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(
          json as Map<String, dynamic>,
          (itemJson) =>
              FeedbackModel.fromJson(itemJson)),
    );
  }

  Future<FeedbackModel> adminUpdateFeedbackStatus(
      String feedbackId, AdminUpdateFeedbackStatusRequest request) async {
    return _apiClient.put<FeedbackModel>(
      '/feedback/admin/$feedbackId/status',
      data: request.toJson(),
      fromJson: (json) => FeedbackModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
