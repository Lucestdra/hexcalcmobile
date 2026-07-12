import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A canned HTTP response for the [FakeHttpAdapter].
class FakeResponse {
  const FakeResponse(
    this.statusCode,
    this.body, {
    this.headers = const <String, List<String>>{},
  });

  factory FakeResponse.json(
    int statusCode,
    Object json, {
    Map<String, List<String>> headers = const <String, List<String>>{},
  }) => FakeResponse(statusCode, jsonEncode(json), headers: headers);

  final int statusCode;
  final String body;
  final Map<String, List<String>> headers;
}

typedef FakeHandler = FakeResponse Function(RequestOptions options);

/// A [HttpClientAdapter] that routes requests to registered handlers and records
/// every call, so networking behaviour (interceptors, single-flight refresh,
/// error mapping) can be tested without a real server.
class FakeHttpAdapter implements HttpClientAdapter {
  final Map<String, FakeHandler> _routes = <String, FakeHandler>{};

  /// Every request as `"METHOD path"`, in order — assert refresh happened once, etc.
  final List<String> calls = <String>[];

  void on(String method, String path, FakeHandler handler) =>
      _routes['${method.toUpperCase()} $path'] = handler;

  int callsTo(String method, String path) =>
      calls.where((String c) => c == '${method.toUpperCase()} $path').length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final String key = '${options.method.toUpperCase()} ${options.path}';
    calls.add(key);
    final FakeHandler? handler = _routes[key];
    final FakeResponse response =
        handler?.call(options) ??
        const FakeResponse(404, '{"title":"not found","status":404}');
    return ResponseBody.fromString(
      response.body,
      response.statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
        ...response.headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Builds a Dio whose adapter is [adapter] — pass as `ApiClient(dioBuilder: ...)`.
/// Timeouts are cleared so no timeout `Timer` is scheduled: the fake resolves on a
/// microtask, and a request still in flight at test teardown would otherwise trip
/// flutter_test's pending-timer check.
Dio Function(BaseOptions) fakeDioBuilder(FakeHttpAdapter adapter) {
  return (BaseOptions options) {
    options
      ..connectTimeout = null
      ..receiveTimeout = null
      ..sendTimeout = null;
    final Dio dio = Dio(options);
    dio.httpClientAdapter = adapter;
    return dio;
  };
}
