import 'package:dio/dio.dart';

import '../api/problem_details.dart';
import '../errors/app_error.dart';

/// Translates a low-level failure (a [DioException] or anything else) into the
/// app's typed [AppError]. Transport failures become [NetworkError]; an HTTP
/// error response is mapped by status code, reading the RFC 9457 `ProblemDetails`
/// body (with its stable `code` and field `errors`) when present.
AppError toAppError(Object error) {
  if (error is AppError) {
    return error;
  }
  if (error is! DioException) {
    return const UnknownError();
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
      return const NetworkError();
    case DioExceptionType.cancel:
      return const NetworkError(message: 'The request was cancelled.');
    case DioExceptionType.badCertificate:
      return const NetworkError(
        message: 'Could not establish a secure connection.',
      );
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      break;
  }

  final Response<dynamic>? response = error.response;
  if (response == null) {
    // No response body but not a recognized transport type — treat as offline.
    return const NetworkError();
  }

  final ProblemDetails problem = _problemFrom(response.data);
  final int status = response.statusCode ?? problem.status ?? 0;
  final String? detail = _cleanDetail(problem.detail);

  return switch (status) {
    400 => ValidationError(
      message:
          detail ??
          (problem.hasFieldErrors
              ? 'Please check the highlighted fields.'
              : 'Invalid request.'),
      code: problem.code,
      fieldErrors: problem.errors,
    ),
    401 => UnauthorizedError(
      message: detail ?? 'Please sign in again.',
      code: problem.code,
    ),
    403 => ForbiddenError(
      message: detail ?? 'You do not have access to that.',
      code: problem.code,
    ),
    404 => NotFoundError(message: detail ?? 'Not found.', code: problem.code),
    409 => ConflictError(
      message: detail ?? 'That conflicts with the current state.',
      code: problem.code,
    ),
    429 => RateLimitedError(
      message:
          detail ?? 'Too many attempts. Please wait a moment and try again.',
      code: problem.code,
      retryAfter: _retryAfter(response),
    ),
    >= 500 => ServerError(
      message: detail ?? 'Something went wrong on our end.',
      code: problem.code,
    ),
    _ => UnknownError(
      message: detail ?? 'Something went wrong.',
      code: problem.code,
    ),
  };
}

ProblemDetails _problemFrom(Object? data) {
  if (data is Map<String, dynamic>) {
    return ProblemDetails.fromJson(data);
  }
  if (data is Map) {
    return ProblemDetails.fromJson(data.cast<String, dynamic>());
  }
  return const ProblemDetails();
}

/// The backend `detail` is safe, non-enumerating text; still, drop empties.
String? _cleanDetail(String? detail) {
  final String? trimmed = detail?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}

Duration? _retryAfter(Response<dynamic> response) {
  final String? header = response.headers.value('retry-after');
  if (header == null) {
    return null;
  }
  final int? seconds = int.tryParse(header.trim());
  return seconds == null ? null : Duration(seconds: seconds);
}
