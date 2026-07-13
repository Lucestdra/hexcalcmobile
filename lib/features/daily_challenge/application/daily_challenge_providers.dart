import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/dtos.dart';
import '../../../core/auth/auth_session.dart';

/// The current daily challenge card. Auto-disposed so re-entering the screen (or
/// returning after an attempt) re-fetches the up-to-date `attempted` state; retry
/// is `ref.invalidate(dailyChallengeProvider)`. A thrown [NetworkError] surfaces
/// as the offline state (issuing a daily attempt requires connectivity).
final dailyChallengeProvider = FutureProvider.autoDispose<DailyChallengeView>((
  ref,
) {
  return ref.read(hexcalcApiProvider).getDailyChallenge();
});
