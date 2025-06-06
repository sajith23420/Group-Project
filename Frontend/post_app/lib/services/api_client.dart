// lib/services/api_client.dart
 
import 'package:dio/dio.dart';
import 'dart:core'; // Import dart:core for Void
import 'package:post_app/services/api_exceptions.dart';
import 'package:post_app/services/token_provider.dart';

class ApiClient {
  late final Dio _dio;
  final TokenProvider _tokenProvider;
  static const String _baseUrl =
      "http://localhost:3000/api"; // Replace with your actual base URL

  ApiClient(this._tokenProvider) {
    final options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10), // 10 seconds
      receiveTimeout: const Duration(seconds: 10), // 10 seconds
    );
    _dio = Dio(options);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenProvider.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options); // continue
      },
      onResponse: (response, handler) {
        // You can process responses here if needed
        return handler.next(response); // continue
      },
      onError: (DioException e, handler) {
        // Handle Dio-specific errors and API errors
        if (e.response != null) {
          // The request was made and the server responded with a status code
          // that falls out of the range of 2xx
          final statusCode = e.response!.statusCode;
          final responseData = e.response!.data;

          String errorMessage = "An API error occurred.";
          List<ValidationErrorDetail> validationDetails = [];

          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['error'] as String? ??
                responseData['message'] as String? ??
                errorMessage;
            if (responseData['details'] is List) {
              validationDetails = (responseData['details'] as List)
                  .map((detail) => ValidationErrorDetail.fromJson(
                      detail as Map<String, dynamic>))
                  .toList();
            }
          } else if (responseData is String) {
            errorMessage = responseData;
          }

          if (statusCode == 400 && validationDetails.isNotEmpty) {
            return handler.next(DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              error: ValidationException(
                  message: errorMessage, details: validationDetails),
              type: e.type,
            ));
          }
          if (statusCode == 401) {
            return handler.next(DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              error: AuthenticationException(message: errorMessage),
              type: e.type,
            ));
          }
          if (statusCode == 403) {
            return handler.next(DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              error: AuthorizationException(message: errorMessage),
              type: e.type,
            ));
          }
          if (statusCode == 404) {
            return handler.next(DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              error: NotFoundException(message: errorMessage),
              type: e.type,
            ));
          }
          if (statusCode != null && statusCode >= 500) {
            return handler.next(DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              error: ServerException(message: errorMessage),
              type: e.type,
            ));
          }
          // Fallback for other non-2xx status codes
          return handler.next(DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            error: ApiException(
                message: errorMessage,
                statusCode: statusCode,
                errorData: responseData),
            type: e.type,
          ));
        } else {
          // Something happened in setting up or sending the request that triggered an Error
          // This is likely a network error (DioExceptionType.connectionTimeout, .sendTimeout, .receiveTimeout, .connectionError, .cancel)
          return handler.next(DioException(
            requestOptions: e.requestOptions,
            error: NetworkException(
                message:
                    "Network error: ${e.message ?? 'Please check your connection.'}"),
            type: e.type,
          ));
        }
      },
    ));
  }

  Future<T> _handleRequest<T>(
      Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      // Remove invalid void check. Just return response.data as T.
      return response.data as T;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      print("Unhandled DioException in _handleRequest: [33m");
      throw ApiException(
          message: e.message ?? "An unexpected error occurred",
          statusCode: e.response?.statusCode);
    } catch (e) {
      print("Generic error in _handleRequest: $e");
      throw ApiException(message: "An unknown error occurred: $e");
    }
  }

  // Generic GET
  Future<T> get<T>(String path,
      {Map<String, dynamic>? queryParameters,
      T Function(dynamic json)? fromJson}) async {
    // Define the operation that returns Future<Response<dynamic>>
    Future<Response<dynamic>> dioOperation() async {
      return _dio.get(path, queryParameters: queryParameters);
    }

    // _handleRequest executes dioOperation and returns response.data.
    // We specify 'dynamic' as the expected type of response.data from _handleRequest.
    final dynamic responseData = await _handleRequest<dynamic>(dioOperation);

    if (fromJson != null) {
      if (responseData != null) {
        return fromJson(responseData); // fromJson returns T
      } else {
        // If API returns null data but fromJson expects non-null (common for models).
        throw ApiException(
          message:
              "API returned null data, but fromJson expected non-null data for type $T at path $path (GET)",
          statusCode: null,
        );
      }
    } else {
      // No fromJson. Cast responseData to T.
      // If responseData is null and T is non-nullable, 'null as T' will throw.
      return responseData as T;
    }
  }

  Future<List<T>> getList<T>(String path,
      {Map<String, dynamic>? queryParameters,
      required T Function(dynamic json) fromJsonT}) async {
    final responseData = await _handleRequest<dynamic>(() async {
      return await _dio.get(path, queryParameters: queryParameters);
    });

    if (responseData is List) {
      return (responseData).map((item) => fromJsonT(item)).toList();
    } else if (responseData is Map &&
        responseData.containsKey('data') &&
        responseData['data'] is List) {
      // Handling paginated-like structures where data is under a 'data' key
      return (responseData['data'] as List)
          .map((item) => fromJsonT(item))
          .toList();
    }
    throw ApiException(
        message:
            "Expected a list or paginated data structure but got ${responseData.runtimeType}");
  }

  // Generic POST
  Future<T> post<T>(String path,
      {dynamic data, T Function(dynamic json)? fromJson}) async {
    // Define the operation that returns Future<Response<dynamic>>
    Future<Response<dynamic>> dioOperation() async {
      return _dio.post(path, data: data);
    }

    final dynamic responseData = await _handleRequest<dynamic>(dioOperation);

    if (fromJson != null) {
      if (responseData != null) {
        return fromJson(responseData);
      } else {
        throw ApiException(
          message:
              "API returned null data, but fromJson expected non-null data for type $T at path $path (POST)",
          statusCode: null,
        );
      }
    } else {
      return responseData as T;
    }
  }

  // Generic PUT
  Future<T> put<T>(String path,
      {dynamic data, T Function(dynamic json)? fromJson}) async {
    // Define the operation that returns Future<Response<dynamic>>
    Future<Response<dynamic>> dioOperation() async {
      return _dio.put(path, data: data);
    }

    final dynamic responseData = await _handleRequest<dynamic>(dioOperation);

    if (fromJson != null) {
      if (responseData != null) {
        return fromJson(responseData);
      } else {
        throw ApiException(
          message:
              "API returned null data, but fromJson expected non-null data for type $T at path $path (PUT)",
          statusCode: null,
        );
      }
    } else {
      return responseData as T;
    }
  }

  // Generic DELETE
  Future<T> delete<T>(String path,
      {dynamic data, T Function(dynamic json)? fromJson}) async {
    return _handleRequest<T>(() async {
      final response = await _dio.delete(path, data: data);
      // Remove invalid void check. Just return response.data as T.
      if (fromJson != null && response.data != null) {
        return fromJson(response.data) as dynamic;
      }
      return response.data;
    });
  }

  // For file uploads
  Future<T> postMultipart<T>(String path, FormData formData,
      {T Function(dynamic json)? fromJson}) async {
    return _handleRequest<T>(() async {
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      if (fromJson != null && response.data != null) {
        return fromJson(response.data) as dynamic;
      }
      return response.data;
    });
  }
}
