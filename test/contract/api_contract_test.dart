import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the hand-authored client (`lib/core/api/`) against drift from the
/// backend contract. It parses the committed OpenAPI document (mirrored from the
/// backend by `tool/generate_api.sh`) and asserts that every endpoint, request
/// field, and response field the client relies on still exists in the spec — the
/// protection a generated client would give. If the backend renames or removes a
/// field, this fails instead of a silent runtime null.
void main() {
  final Map<String, dynamic> spec =
      jsonDecode(File('test/contract/openapi.v1.json').readAsStringSync())
          as Map<String, dynamic>;
  final Map<String, dynamic> paths = spec['paths'] as Map<String, dynamic>;
  final Map<String, dynamic> schemas =
      (spec['components'] as Map<String, dynamic>)['schemas']
          as Map<String, dynamic>;

  Map<String, dynamic> schema(String name) {
    expect(
      schemas.containsKey(name),
      isTrue,
      reason: 'schema $name missing from spec',
    );
    return schemas[name] as Map<String, dynamic>;
  }

  void expectProps(String name, List<String> fields) {
    final Map<String, dynamic> props =
        schema(name)['properties'] as Map<String, dynamic>? ??
        <String, dynamic>{};
    for (final String field in fields) {
      expect(
        props.containsKey(field),
        isTrue,
        reason: '$name.$field missing from spec',
      );
    }
  }

  void expectRequired(String name, List<String> fields) {
    final List<dynamic> required =
        schema(name)['required'] as List<dynamic>? ?? <dynamic>[];
    for (final String field in fields) {
      expect(required.contains(field), isTrue, reason: '$name requires $field');
    }
  }

  // The declared JSON type(s) of a property (OpenAPI 3.1 allows a type array).
  Set<String> typeOf(String name, String field) {
    final Map<String, dynamic> prop =
        (schema(name)['properties'] as Map<String, dynamic>)[field]
            as Map<String, dynamic>;
    final Object? type = prop['type'];
    return switch (type) {
      final String t => <String>{t},
      final List<dynamic> ts => ts.map((Object? e) => e.toString()).toSet(),
      _ => <String>{},
    };
  }

  void expectType(String name, String field, String type) {
    expect(
      typeOf(name, field).contains(type),
      isTrue,
      reason: '$name.$field should be $type in the spec',
    );
  }

  test('every endpoint the client calls exists with the right method', () {
    const Map<String, String> endpoints = <String, String>{
      '/api/v1/auth/guest': 'post',
      '/api/v1/auth/register': 'post',
      '/api/v1/auth/login': 'post',
      '/api/v1/auth/password/forgot': 'post',
      '/api/v1/auth/password/reset': 'post',
      '/api/v1/auth/refresh': 'post',
      '/api/v1/auth/logout': 'post',
      '/api/v1/auth/link-account': 'post',
    };
    endpoints.forEach((String path, String method) {
      expect(paths.containsKey(path), isTrue, reason: 'missing path $path');
      expect(
        (paths[path] as Map<String, dynamic>).containsKey(method),
        isTrue,
        reason: 'missing $method $path',
      );
    });
    // players/me supports both GET and PATCH.
    final Map<String, dynamic> me =
        paths['/api/v1/players/me'] as Map<String, dynamic>;
    expect(me.containsKey('get'), isTrue);
    expect(me.containsKey('patch'), isTrue);
  });

  test('request schemas require the fields the client sends', () {
    expectRequired('RegisterRequest', <String>['email', 'password']);
    expectRequired('LoginRequest', <String>['email', 'password']);
    expectRequired('RefreshRequest', <String>['refreshToken']);
    expectRequired('LogoutRequest', <String>['refreshToken', 'allDevices']);
    expectRequired('ForgotPasswordRequest', <String>['email']);
    expectRequired('ResetPasswordRequest', <String>[
      'email',
      'token',
      'newPassword',
    ]);
    expectRequired('LinkAccountRequest', <String>['email', 'password']);
  });

  test('response schemas expose the fields the client reads', () {
    expectProps('AuthTokens', <String>[
      'accessToken',
      'refreshToken',
      'tokenType',
      'expiresInSeconds',
      'userId',
    ]);
    expectProps('AuthStatusResponse', <String>['status']);
    expectProps('PlayerProfile', <String>[
      'id',
      'displayName',
      'locale',
      'status',
      'createdAtUtc',
    ]);
  });

  test('response fields the client casts non-null are required by the spec', () {
    // The client does non-null casts on these (dtos.dart) — if the backend made
    // any optional, the cast would throw at runtime.
    expectRequired('AuthTokens', <String>[
      'accessToken',
      'refreshToken',
      'expiresInSeconds',
      'userId',
    ]);
    expectRequired('PlayerProfile', <String>['id']);
  });

  test('key response field types match the client casts', () {
    expectType('AuthTokens', 'accessToken', 'string');
    expectType('AuthTokens', 'userId', 'string');
    expectType('AuthTokens', 'expiresInSeconds', 'integer');
    expectType('PlayerProfile', 'id', 'string');
  });
}
