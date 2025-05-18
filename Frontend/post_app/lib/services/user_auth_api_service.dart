// lib/services/user_auth_api_service.dart

import 'dart:io'; // For File type
import 'package:dio/dio.dart'; // For FormData and MultipartFile

import 'package:post_app/models/user_model.dart';
import 'package:post_app/services/api_client.dart';
import 'package:path/path.dart' as p; // For basename

class UserAuthApiService {
  final ApiClient _apiClient;

  UserAuthApiService(this._apiClient);

  Future<UserModel> getUserProfile() async {
    return _apiClient.get<UserModel>(
      '/auth/profile',
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<UserModel> updateUserProfile(UpdateUserProfileRequest request) async {
    return _apiClient.put<UserModel>(
      '/auth/profile',
      data: request.toJson(),
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<UploadProfilePictureResponse> uploadUserProfilePicture(
      File imageFile) async {
    String fileName = p.basename(imageFile.path);
    FormData formData = FormData.fromMap({
      "profilePicture":
          await MultipartFile.fromFile(imageFile.path, filename: fileName),
    });

    return _apiClient.postMultipart<UploadProfilePictureResponse>(
      '/auth/profile/upload-picture',
      formData,
      fromJson: (json) =>
          UploadProfilePictureResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<UserModel> adminUpdateUserRole(
      String userIdToUpdate, AdminUpdateUserRoleRequest request) async {
    return _apiClient.put<UserModel>(
      '/auth/admin/users/$userIdToUpdate/role',
      data: request.toJson(),
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<UserModel>> adminGetAllUsers() async {
    // The backend returns a direct list, not paginated for this endpoint.
    return _apiClient.getList<UserModel>(
      '/auth/admin/users',
      fromJsonT: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
