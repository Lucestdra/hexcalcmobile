/// The app's typed error model. Every failure surfaced to the UI or an
/// application controller is one of these — never a raw `DioException`, socket
/// error, or `ProblemDetails`. Networking maps transport failures and RFC 9457
/// `ProblemDetails` bodies into this hierarchy (see `error_mapper.dart`), so
/// widgets and notifiers can switch on a stable, backend-agnostic shape.
sealed class AppError implements Exception {
  const AppError({required this.message, this.code});

  /// A human-readable, non-enumerating message safe to show the player.
  final String message;

  /// The stable machine token from `ProblemDetails.code` (e.g.
  /// `auth.invalid_credentials`), when the server supplied one.
  final String? code;

  /// True when the failure is a connectivity/timeout condition — the caller can
  /// offer "you're offline" messaging and preserve local work.
  bool get isOffline => this is NetworkError;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

/// No usable connection, a request timeout, or a cancelled request — the device
/// is effectively offline for this operation. Offline-first flows treat this as
/// recoverable and keep local state intact.
final class NetworkError extends AppError {
  const NetworkError({super.message = 'You appear to be offline.', super.code});
}

/// The server failed (HTTP 5xx) or returned an unreadable response.
final class ServerError extends AppError {
  const ServerError({
    super.message = 'Something went wrong on our end.',
    super.code,
  });
}

/// HTTP 400 with field-level validation errors (ASP.NET `ValidationProblemDetails`).
final class ValidationError extends AppError {
  const ValidationError({
    required super.message,
    super.code,
    this.fieldErrors = const <String, List<String>>{},
  });

  /// Field name → messages, keyed as the server reports them (e.g. `Email`).
  final Map<String, List<String>> fieldErrors;

  /// The first message for [field] (case-insensitive), if any.
  String? firstFor(String field) {
    for (final MapEntry<String, List<String>> entry in fieldErrors.entries) {
      if (entry.key.toLowerCase() == field.toLowerCase() &&
          entry.value.isNotEmpty) {
        return entry.value.first;
      }
    }
    return null;
  }
}

/// HTTP 401 — the credentials/token were rejected.
final class UnauthorizedError extends AppError {
  const UnauthorizedError({
    super.message = 'Please sign in again.',
    super.code,
  });
}

/// HTTP 403 — authenticated but not allowed.
final class ForbiddenError extends AppError {
  const ForbiddenError({
    super.message = 'You do not have access to that.',
    super.code,
  });
}

/// HTTP 404 — the resource does not exist.
final class NotFoundError extends AppError {
  const NotFoundError({super.message = 'Not found.', super.code});
}

/// HTTP 409 — a conflicting state (e.g. a guest already linked to an account).
final class ConflictError extends AppError {
  const ConflictError({required super.message, super.code});
}

/// HTTP 429 — rate limited. [retryAfter] comes from the `Retry-After` header when present.
final class RateLimitedError extends AppError {
  const RateLimitedError({
    super.message = 'Too many attempts. Please wait a moment and try again.',
    super.code,
    this.retryAfter,
  });

  final Duration? retryAfter;
}

/// Any failure that does not fit the cases above.
final class UnknownError extends AppError {
  const UnknownError({super.message = 'Something went wrong.', super.code});
}
