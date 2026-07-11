import 'package:drift_flutter/drift_flutter.dart';

import 'app_database.dart';

/// Opens the on-device [AppDatabase] backed by a native SQLite file.
///
/// This is the only file that imports `drift_flutter` (which brings the native
/// sqlite build hooks). It is kept apart from `app_database.dart` so the schema —
/// and its generated code — depend only on `package:drift`, and so the Drift
/// generator can run in a hook-free package (see README "Regenerating Drift code").
AppDatabase openAppDatabase() => AppDatabase(driftDatabase(name: 'hexcalc'));
