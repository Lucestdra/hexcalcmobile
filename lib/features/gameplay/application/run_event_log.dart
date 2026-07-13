import '../domain/domain.dart';

/// The kinds of event a run event log records.
enum LoggedEventKind { equation, pause, resume }

/// One captured run event. For [LoggedEventKind.equation], [levelIndex] is the
/// level the equation was committed on and [path] is the swiped cell path; for
/// pause/resume only [tMs] is meaningful. This is the client-side capture that
/// maps to the backend's payloadVersion-1 event log — kept separate from the
/// scoring [RunEvent] (which mirrors the backend replay input and carries no path).
class LoggedRunEvent {
  const LoggedRunEvent.equation({
    required this.tMs,
    required this.levelIndex,
    required this.path,
  }) : kind = LoggedEventKind.equation;

  const LoggedRunEvent.pause(this.tMs)
    : kind = LoggedEventKind.pause,
      levelIndex = 0,
      path = const <AxialCoordinate>[];

  const LoggedRunEvent.resume(this.tMs)
    : kind = LoggedEventKind.resume,
      levelIndex = 0,
      path = const <AxialCoordinate>[];

  final LoggedEventKind kind;
  final int tMs;
  final int levelIndex;
  final List<AxialCoordinate> path;
}

/// The event-log payload version this client emits (must match the backend's
/// supported `RunEventLogParser.SupportedPayloadVersion`).
const int kEventLogPayloadVersion = 1;

/// Maps a captured run into the backend's payloadVersion-1 event-log JSON:
/// `{ payloadVersion, clientTotalScore, events: [...] }`. The submit request wraps
/// this under `eventLog`. Equation paths serialize as `[{q, r}, ...]`; pause/resume
/// carry only `type` + `tMs`.
Map<String, dynamic> buildEventLogPayload({
  required int clientTotalScore,
  required List<LoggedRunEvent> events,
}) {
  return <String, dynamic>{
    'payloadVersion': kEventLogPayloadVersion,
    'clientTotalScore': clientTotalScore,
    'events': <Map<String, dynamic>>[
      for (final LoggedRunEvent e in events) _eventJson(e),
    ],
  };
}

Map<String, dynamic> _eventJson(LoggedRunEvent e) {
  switch (e.kind) {
    case LoggedEventKind.equation:
      return <String, dynamic>{
        'type': 'equation',
        'levelIndex': e.levelIndex,
        'tMs': e.tMs,
        'path': <Map<String, int>>[
          for (final AxialCoordinate c in e.path)
            <String, int>{'q': c.q, 'r': c.r},
        ],
      };
    case LoggedEventKind.pause:
      return <String, dynamic>{'type': 'pause', 'tMs': e.tMs};
    case LoggedEventKind.resume:
      return <String, dynamic>{'type': 'resume', 'tMs': e.tMs};
  }
}
