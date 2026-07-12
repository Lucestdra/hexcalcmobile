import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/core/errors/app_error.dart';
import 'package:hexcalc/core/networking/error_mapper.dart';

void main() {
  Map<String, dynamic> fixture(String name) =>
      jsonDecode(
            File('test/contract/problem_details/$name.json').readAsStringSync(),
          )
          as Map<String, dynamic>;

  DioException badResponse(
    int status,
    Object? data, {
    Map<String, List<String>> headers = const <String, List<String>>{},
  }) {
    final RequestOptions options = RequestOptions(path: '/x');
    return DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(
        requestOptions: options,
        statusCode: status,
        data: data,
        headers: Headers.fromMap(headers),
      ),
    );
  }

  test('400 maps to ValidationError with field-level errors', () {
    final AppError error = toAppError(
      badResponse(400, fixture('validation_400')),
    );
    expect(error, isA<ValidationError>());
    final ValidationError v = error as ValidationError;
    expect(v.firstFor('email'), 'The Email field is required.');
    expect(v.firstFor('password'), contains('minimum length'));
  });

  test('401 maps to UnauthorizedError with the stable code', () {
    final AppError error = toAppError(
      badResponse(401, fixture('unauthorized_401')),
    );
    expect(error, isA<UnauthorizedError>());
    expect(error.code, 'auth.invalid_credentials');
    expect(error.message, 'Email or password is incorrect.');
  });

  test('409 maps to ConflictError', () {
    final AppError error = toAppError(
      badResponse(409, fixture('conflict_409')),
    );
    expect(error, isA<ConflictError>());
    expect(error.code, 'auth.guest_already_linked');
  });

  test('429 maps to RateLimitedError and reads Retry-After', () {
    final AppError error = toAppError(
      badResponse(
        429,
        fixture('rate_limited_429'),
        headers: <String, List<String>>{
          'retry-after': <String>['30'],
        },
      ),
    );
    expect(error, isA<RateLimitedError>());
    expect((error as RateLimitedError).retryAfter, const Duration(seconds: 30));
    expect(error.code, 'auth.rate_limited');
  });

  test('5xx maps to ServerError', () {
    final AppError error = toAppError(
      badResponse(503, <String, dynamic>{'status': 503}),
    );
    expect(error, isA<ServerError>());
  });

  test('connection failures map to an offline NetworkError', () {
    final DioException offline = DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.connectionError,
    );
    final AppError error = toAppError(offline);
    expect(error, isA<NetworkError>());
    expect(error.isOffline, isTrue);
  });

  test('a non-Dio error maps to UnknownError', () {
    expect(toAppError(Exception('boom')), isA<UnknownError>());
  });
}
