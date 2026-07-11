import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixture_support.dart';

/// Drift guard: recomputes the SHA-256 of every fixture listed in manifest.sha256
/// and asserts it matches, and that the manifest and on-disk fixture set agree
/// exactly. Mirrors the backend guard. Editing a fixture without re-syncing,
/// deleting a listed fixture, or adding an unlisted fixture all fail this test.
void main() {
  final Directory dir = fixturesDir();
  final File manifestFile = File('${dir.path}/manifest.sha256');

  final Map<String, dynamic> manifest =
      jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
  final Map<String, dynamic> files = manifest['files'] as Map<String, dynamic>;

  test('manifest declares SHA-256', () {
    expect(manifest['algorithm'], 'SHA-256');
  });

  group('every listed file hash matches', () {
    for (final MapEntry<String, dynamic> entry in files.entries) {
      test(entry.key, () {
        final File f = File('${dir.path}/${entry.key}');
        expect(
          f.existsSync(),
          isTrue,
          reason: 'manifest lists missing file: ${entry.key}',
        );
        final String actual = sha256.convert(f.readAsBytesSync()).toString();
        expect(actual, entry.value as String);
      });
    }
  });

  test('manifest and disk fixture sets match exactly', () {
    final Set<String> listed = files.keys.toSet();
    final Set<String> onDisk = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.json'))
        .map(
          (File f) =>
              f.path.substring(dir.path.length + 1).replaceAll(r'\', '/'),
        )
        .toSet();

    expect(
      onDisk.difference(listed),
      isEmpty,
      reason: 'fixtures on disk but not in manifest',
    );
    expect(
      listed.difference(onDisk),
      isEmpty,
      reason: 'fixtures in manifest but not on disk',
    );
  });
}
