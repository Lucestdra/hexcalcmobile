import 'dart:math';

/// Generates a random UUIDv4 (hyphenated hex) used as a request correlation id,
/// propagated to the backend via the `X-Correlation-ID` header so a request can
/// be traced end-to-end. Uses a cryptographic RNG; no external package needed.
String newCorrelationId() {
  final Random rng = Random.secure();
  final List<int> bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  // Set the version (4) and variant (10xx) bits per RFC 4122.
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  String hex(int start, int end) {
    final StringBuffer sb = StringBuffer();
    for (int i = start; i < end; i++) {
      sb.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }

  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
