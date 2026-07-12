import 'package:dio/dio.dart';

import '../utilities/correlation_id.dart';

/// Attaches a per-request `X-Correlation-ID` (unless the caller already set one),
/// so a single user action can be traced through the backend logs and traces.
class CorrelationInterceptor extends Interceptor {
  static const String headerName = 'X-Correlation-ID';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent(headerName, newCorrelationId);
    handler.next(options);
  }
}
