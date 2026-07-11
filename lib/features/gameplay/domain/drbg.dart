/// Deterministic byte stream — Dart twin of the C# Drbg.
/// SHA-256 over (seedPayload ++ bigEndianUInt32(counter)), refilled block by
/// block. See the backend spec docs/gameplay/board-generation.md §2.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class Drbg {
  Drbg(String seedPayload)
    : _seedPayload = Uint8List.fromList(utf8.encode(seedPayload));

  static const int _two32 = 4294967296; // 2^32

  final Uint8List _seedPayload;
  Uint8List _buffer = Uint8List(0);
  int _bufferPos = 0;
  int _counter = 0; // unsigned 32-bit

  int nextByte() {
    if (_bufferPos >= _buffer.length) {
      final Uint8List input = Uint8List(_seedPayload.length + 4);
      input.setRange(0, _seedPayload.length, _seedPayload);
      final int c = _counter & 0xFFFFFFFF;
      input[_seedPayload.length] = (c >> 24) & 0xFF;
      input[_seedPayload.length + 1] = (c >> 16) & 0xFF;
      input[_seedPayload.length + 2] = (c >> 8) & 0xFF;
      input[_seedPayload.length + 3] = c & 0xFF;

      _buffer = Uint8List.fromList(sha256.convert(input).bytes);
      _bufferPos = 0;
      _counter++;
    }

    return _buffer[_bufferPos++];
  }

  /// Reads four bytes big-endian into a value in [0, 2^32).
  int nextUInt32() {
    final int b0 = nextByte();
    final int b1 = nextByte();
    final int b2 = nextByte();
    final int b3 = nextByte();
    return (b0 << 24) | (b1 << 16) | (b2 << 8) | b3;
  }

  /// Uniform integer in [0, bound) by rejection sampling. bound in [1, 2^32].
  int nextInt(int bound) {
    final int limit = _two32 - (_two32 % bound);
    while (true) {
      final int x = nextUInt32();
      if (x < limit) {
        return x % bound;
      }
    }
  }
}
