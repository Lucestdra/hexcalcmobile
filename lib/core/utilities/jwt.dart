import 'dart:convert';

/// Reads the `role` claim from a JWT access token without validating its
/// signature — used only to tell a guest token (`guest`) from a full-account
/// token (`user`) for local UI state. The server remains the authority; a token
/// is never trusted for anything security-relevant on the strength of this.
String? readRoleClaim(String jwt) {
  final Map<String, dynamic>? claims = _decodePayload(jwt);
  if (claims == null) {
    return null;
  }
  // The backend emits the role under the ASP.NET ClaimTypes.Role URI.
  const String roleUri =
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';
  final Object? role = claims[roleUri] ?? claims['role'];
  return role is String ? role : null;
}

Map<String, dynamic>? _decodePayload(String jwt) {
  final List<String> parts = jwt.split('.');
  if (parts.length != 3) {
    return null;
  }
  try {
    final String normalized = base64Url.normalize(parts[1]);
    final Object? decoded = jsonDecode(
      utf8.decode(base64Url.decode(normalized)),
    );
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}
