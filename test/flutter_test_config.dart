import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs before every test file. Two jobs:
///  1. Load the bundled Space Grotesk / Space Mono fonts so golden text renders
///     with the real glyphs (deterministic) instead of the Ahem test fallback.
///  2. Install a tolerant golden comparator. Goldens are generated on the dev
///     machine (Windows) but CI runs Linux; a small pixel tolerance absorbs the
///     sub-pixel anti-aliasing differences of a flat neon-on-near-black UI while
///     still catching real regressions.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  await _loadFont('SpaceGrotesk', <String>[
    'assets/fonts/SpaceGrotesk-Variable.ttf',
  ]);
  await _loadFont('SpaceMono', <String>[
    'assets/fonts/SpaceMono-Regular.ttf',
    'assets/fonts/SpaceMono-Bold.ttf',
  ]);

  if (goldenFileComparator is LocalFileComparator) {
    final Uri basedir = (goldenFileComparator as LocalFileComparator).basedir;
    goldenFileComparator = _TolerantGoldenComparator(basedir, tolerance: 0.015);
  }

  await testMain();
}

Future<void> _loadFont(String family, List<String> paths) async {
  final FontLoader loader = FontLoader(family);
  for (final String path in paths) {
    loader.addFont(_readAsByteData(path));
  }
  await loader.load();
}

Future<ByteData> _readAsByteData(String path) async {
  final Uint8List bytes = await File(path).readAsBytes();
  return ByteData.view(bytes.buffer);
}

/// A [LocalFileComparator] that passes when the pixel difference is within
/// [tolerance] (a fraction, 0..1), instead of demanding an exact match.
class _TolerantGoldenComparator extends LocalFileComparator {
  _TolerantGoldenComparator(super.testFile, {required this.tolerance});

  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= tolerance) {
      return true;
    }
    final String error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}
