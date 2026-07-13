import '../domain/domain.dart';

class LoggedV2RunEvent {
  const LoggedV2RunEvent.chain({
    required this.tMs,
    required this.boardRevision,
    required this.path,
  });

  final int tMs;
  final int boardRevision;
  final List<AxialCoordinate> path;
}

const int kEventLogPayloadVersionV2 = 2;

Map<String, dynamic> buildEventLogPayloadV2({
  required int clientTotalScore,
  required List<LoggedV2RunEvent> events,
}) => <String, dynamic>{
  'payloadVersion': kEventLogPayloadVersionV2,
  'clientTotalScore': clientTotalScore,
  'events': <Map<String, dynamic>>[
    for (final LoggedV2RunEvent event in events) _eventJson(event),
  ],
};

Map<String, dynamic> _eventJson(LoggedV2RunEvent event) {
  return <String, dynamic>{
    'type': 'chain',
    'tMs': event.tMs,
    'boardRevision': event.boardRevision,
    'path': <Map<String, int>>[
      for (final AxialCoordinate cell in event.path)
        <String, int>{'q': cell.q, 'r': cell.r},
    ],
  };
}
