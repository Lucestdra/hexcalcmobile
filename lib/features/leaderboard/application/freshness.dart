/// Formats a compact, locale-independent "how long ago" label for a freshness
/// stamp (e.g. the cached leaderboard's fetch time). Pure so it is unit-testable
/// and deterministic in goldens. [thenMs] and [nowMs] are epoch milliseconds.
String freshnessLabel(int thenMs, int nowMs) {
  final int deltaMs = nowMs - thenMs;
  if (deltaMs < 0) {
    // Clock skew (cache stamped slightly ahead): treat as fresh, never negative.
    return 'just now';
  }
  final int seconds = deltaMs ~/ 1000;
  if (seconds < 45) {
    return 'just now';
  }
  final int minutes = seconds ~/ 60;
  if (minutes < 60) {
    return '${minutes.clamp(1, 59)}m ago';
  }
  final int hours = minutes ~/ 60;
  if (hours < 24) {
    return '${hours}h ago';
  }
  final int days = hours ~/ 24;
  return '${days}d ago';
}
