import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

void main() {
  test('stream matches external SHA-256 (independent anchor)', () {
    // Ground truth from sha256sum, matching the backend DrbgTests.
    const String block0 =
        'f4b91fc4685f409d81f73c7b45d7959d3d4dee4f5e73aed15a897bb6a964ebe0';
    const String block1 =
        '5fc276df98325d3a753fcb5ef25146afe1162c155f01184fc497e68d9db45801';

    final Drbg drbg = Drbg('HEXCALC|alpha|rs-v1|gen-v1|0');
    final StringBuffer hex = StringBuffer();
    for (int i = 0; i < 64; i++) {
      hex.write(drbg.nextByte().toRadixString(16).padLeft(2, '0'));
    }

    expect(hex.toString(), '$block0$block1');
  });

  test('same payload yields same stream', () {
    final Drbg a = Drbg('seed-x');
    final Drbg b = Drbg('seed-x');
    for (int i = 0; i < 200; i++) {
      expect(a.nextByte(), b.nextByte());
    }
  });

  test('nextInt is in range', () {
    final Drbg drbg = Drbg('range-test');
    for (int i = 0; i < 5000; i++) {
      expect(drbg.nextInt(10), inInclusiveRange(0, 9));
    }
  });

  test('nextInt bound one is always zero', () {
    final Drbg drbg = Drbg('one');
    for (int i = 0; i < 100; i++) {
      expect(drbg.nextInt(1), 0);
    }
  });
}
