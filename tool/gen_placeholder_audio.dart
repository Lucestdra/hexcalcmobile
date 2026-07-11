// Generates the CC0 placeholder sound set for HEX • CALC into assets/audio/.
//
// These are procedurally-synthesised 16-bit PCM WAV tones — deliberately simple,
// royalty-free placeholders so the audio pipeline is wired end to end. They are
// replaced by a licensed/designed sound set in a later phase. Regenerate with:
//
//   dart run tool/gen_placeholder_audio.dart
//
// Deterministic (no RNG), so the committed files are reproducible byte-for-byte.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int _sampleRate = 44100;

void main() {
  final Directory outDir = Directory('assets/audio');
  outDir.createSync(recursive: true);

  // Cell selection tick: a very short, bright blip.
  _write('ui_tap', _tone(freq: 880, ms: 45, attackMs: 2, releaseMs: 30));

  // Rising path notes (a pentatonic run) played as the path grows.
  const List<double> scale = <double>[523.25, 587.33, 659.25, 783.99, 880.0];
  for (int i = 0; i < scale.length; i++) {
    _write(
      'note_${i + 1}',
      _tone(freq: scale[i], ms: 120, attackMs: 4, releaseMs: 90),
    );
  }

  // Completion chord: a major triad summed together.
  _write(
    'correct',
    _chord(<double>[523.25, 659.25, 783.99], ms: 520, releaseMs: 380),
  );

  // Target-match sparkle: an octave up, a touch brighter.
  _write(
    'target',
    _chord(<double>[783.99, 1046.5, 1318.5], ms: 560, releaseMs: 420),
  );

  // Invalid: a short low buzz (square-ish via odd harmonics).
  _write('invalid', _buzz(freq: 155, ms: 220, releaseMs: 120));

  // Fever ignition: an upward sweep.
  _write('fever', _sweep(fromHz: 330, toHz: 1320, ms: 640, releaseMs: 260));

  stdout.writeln('Wrote placeholder audio to ${outDir.path}');
}

void _write(String name, Float64List samples) {
  final File f = File('assets/audio/$name.wav');
  f.writeAsBytesSync(_encodeWav(samples));
  stdout.writeln('  ${f.path} (${samples.length} samples)');
}

/// A single sine tone with a linear attack and an exponential-ish release.
Float64List _tone({
  required double freq,
  required int ms,
  required int attackMs,
  required int releaseMs,
}) {
  final int n = (_sampleRate * ms / 1000).round();
  final Float64List out = Float64List(n);
  for (int i = 0; i < n; i++) {
    final double t = i / _sampleRate;
    out[i] = math.sin(2 * math.pi * freq * t) * _env(i, n, attackMs, releaseMs);
  }
  return out;
}

/// Several sine partials summed and normalised — a simple chord.
Float64List _chord(
  List<double> freqs, {
  required int ms,
  required int releaseMs,
}) {
  final int n = (_sampleRate * ms / 1000).round();
  final Float64List out = Float64List(n);
  for (int i = 0; i < n; i++) {
    final double t = i / _sampleRate;
    double v = 0;
    for (final double f in freqs) {
      v += math.sin(2 * math.pi * f * t);
    }
    out[i] = (v / freqs.length) * _env(i, n, 6, releaseMs);
  }
  return out;
}

/// A gritty low tone built from odd harmonics for an "invalid" cue.
Float64List _buzz({
  required double freq,
  required int ms,
  required int releaseMs,
}) {
  final int n = (_sampleRate * ms / 1000).round();
  final Float64List out = Float64List(n);
  for (int i = 0; i < n; i++) {
    final double t = i / _sampleRate;
    final double v =
        math.sin(2 * math.pi * freq * t) +
        0.5 * math.sin(2 * math.pi * freq * 3 * t) +
        0.25 * math.sin(2 * math.pi * freq * 5 * t);
    out[i] = (v / 1.75) * _env(i, n, 3, releaseMs);
  }
  return out;
}

/// A linear frequency sweep for the Fever ignition.
Float64List _sweep({
  required double fromHz,
  required double toHz,
  required int ms,
  required int releaseMs,
}) {
  final int n = (_sampleRate * ms / 1000).round();
  final Float64List out = Float64List(n);
  double phase = 0;
  for (int i = 0; i < n; i++) {
    final double frac = i / n;
    final double f = fromHz + (toHz - fromHz) * frac;
    phase += 2 * math.pi * f / _sampleRate;
    out[i] = math.sin(phase) * _env(i, n, 8, releaseMs);
  }
  return out;
}

/// Amplitude envelope in [0, 1]: linear attack, then a smooth release tail.
double _env(int i, int n, int attackMs, int releaseMs) {
  final int attack = (_sampleRate * attackMs / 1000).round();
  final int release = (_sampleRate * releaseMs / 1000).round();
  double a = 1;
  if (i < attack && attack > 0) {
    a = i / attack;
  }
  final int fromEnd = n - i;
  if (fromEnd < release && release > 0) {
    final double r = fromEnd / release;
    a *= r * r; // quadratic fade for a softer tail
  }
  return a * 0.6; // headroom so summed partials never clip
}

/// Encodes mono 16-bit PCM WAV.
Uint8List _encodeWav(Float64List samples) {
  final int dataBytes = samples.length * 2;
  final ByteData bd = ByteData(44 + dataBytes);
  void writeStr(int offset, String s) {
    for (int i = 0; i < s.length; i++) {
      bd.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  writeStr(0, 'RIFF');
  bd.setUint32(4, 36 + dataBytes, Endian.little);
  writeStr(8, 'WAVE');
  writeStr(12, 'fmt ');
  bd.setUint32(16, 16, Endian.little); // PCM chunk size
  bd.setUint16(20, 1, Endian.little); // PCM
  bd.setUint16(22, 1, Endian.little); // mono
  bd.setUint32(24, _sampleRate, Endian.little);
  bd.setUint32(28, _sampleRate * 2, Endian.little); // byte rate
  bd.setUint16(32, 2, Endian.little); // block align
  bd.setUint16(34, 16, Endian.little); // bits per sample
  writeStr(36, 'data');
  bd.setUint32(40, dataBytes, Endian.little);

  for (int i = 0; i < samples.length; i++) {
    final double c = samples[i].clamp(-1.0, 1.0);
    bd.setInt16(44 + i * 2, (c * 32767).round(), Endian.little);
  }
  return bd.buffer.asUint8List();
}
