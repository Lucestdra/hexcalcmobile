import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/gameplay/domain/domain.dart';

/// The active gameplay ruleset, loaded from the bundled canonical JSON at
/// bootstrap and injected here. Overridden in [main].
final rulesetProvider = Provider<Ruleset>((ref) {
  throw UnimplementedError('rulesetProvider must be overridden at bootstrap');
});
