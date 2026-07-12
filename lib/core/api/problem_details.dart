/// RFC 9457 ProblemDetails as returned by the backend. The `code` extension is a
/// stable machine token (e.g. `auth.invalid_credentials`); `errors` is present on
/// ASP.NET validation failures (field → messages).
///
/// The backend documents integer fields with the OpenAPI 3.1 multi-type
/// `["integer","string"]`, so numbers may arrive as either — [asInt] tolerates both.
class ProblemDetails {
  const ProblemDetails({
    this.type,
    this.title,
    this.status,
    this.detail,
    this.code,
    this.errors = const <String, List<String>>{},
  });

  final String? type;
  final String? title;
  final int? status;
  final String? detail;
  final String? code;
  final Map<String, List<String>> errors;

  bool get hasFieldErrors => errors.isNotEmpty;

  static ProblemDetails fromJson(Map<String, dynamic> json) {
    final Object? rawErrors = json['errors'];
    final Map<String, List<String>> errors = <String, List<String>>{};
    if (rawErrors is Map) {
      rawErrors.forEach((Object? key, Object? value) {
        if (key is String && value is List) {
          errors[key] = value.map((Object? e) => e.toString()).toList();
        }
      });
    }

    return ProblemDetails(
      type: json['type'] as String?,
      title: json['title'] as String?,
      status: asInt(json['status']),
      detail: json['detail'] as String?,
      code: json['code'] as String?,
      errors: errors,
    );
  }

  /// Parses a value the backend may encode as an integer or a numeric string.
  static int? asInt(Object? value) => switch (value) {
    final int v => v,
    final String v => int.tryParse(v),
    _ => null,
  };
}
