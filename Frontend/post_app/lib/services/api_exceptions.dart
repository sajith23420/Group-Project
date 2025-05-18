// lib/services/api_exceptions.dart

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errorData; // Can hold backend's error details

  ApiException({
    required this.message,
    this.statusCode,
    this.errorData,
  });

  @override
  String toString() {
    return 'ApiException: $message (StatusCode: $statusCode, Data: $errorData)';
  }
}

class NetworkException extends ApiException {
  NetworkException({String message = "Network error occurred. Please check your connection."})
      : super(message: message);
}

class AuthenticationException extends ApiException {
  AuthenticationException({String message = "Authentication failed. Please log in again."})
      : super(message: message, statusCode: 401);
}

class AuthorizationException extends ApiException {
  AuthorizationException({String message = "You are not authorized to perform this action."})
      : super(message: message, statusCode: 403);
}

class ValidationException extends ApiException {
  final List<ValidationErrorDetail> details;

  ValidationException({
    String message = "Input validation failed.",
    required this.details,
  }) : super(message: message, statusCode: 400, errorData: details.map((d) => d.toJson()).toList());

  @override
  String toString() {
    return 'ValidationException: $message, Details: ${details.map((e) => e.toString()).join(', ')}';
  }
}

class ValidationErrorDetail {
  final String message;
  final String? path;
  final String? type;

  ValidationErrorDetail({required this.message, this.path, this.type});

  factory ValidationErrorDetail.fromJson(Map<String, dynamic> json) {
    return ValidationErrorDetail(
      message: json['message'] as String,
      path: json['path'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'path': path,
    'type': type,
  };


  @override
  String toString() {
    return 'Error: $message (Path: $path, Type: $type)';
  }
}

class NotFoundException extends ApiException {
  NotFoundException({String message = "The requested resource was not found."})
      : super(message: message, statusCode: 404);
}

class ServerException extends ApiException {
  ServerException({String message = "An unexpected server error occurred."})
      : super(message: message, statusCode: 500);
}