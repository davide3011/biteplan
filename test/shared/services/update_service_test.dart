import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:biteplan/core/constants/app_constants.dart';
import 'package:biteplan/shared/services/update_service.dart';

void main() {
  group('UpdateService.checkUpdate', () {
    tearDown(() => HttpOverrides.global = null);

    test('ritorna la versione quando il tag remoto è più recente', () async {
      HttpOverrides.global =
          _FakeHttpOverrides(body: '{"tag_name":"v99.0.0"}');
      expect(await UpdateService.checkUpdate(), '99.0.0');
    });

    test('ritorna null quando il tag remoto è uguale alla versione corrente',
        () async {
      HttpOverrides.global =
          _FakeHttpOverrides(body: '{"tag_name":"v$kAppVersion"}');
      expect(await UpdateService.checkUpdate(), isNull);
    });

    test('ritorna null quando il tag remoto è più vecchio', () async {
      HttpOverrides.global = _FakeHttpOverrides(body: '{"tag_name":"v0.0.1"}');
      expect(await UpdateService.checkUpdate(), isNull);
    });

    test('ritorna null con status diverso da 200', () async {
      HttpOverrides.global = _FakeHttpOverrides(
          statusCode: 404, body: '{"message":"Not Found"}');
      expect(await UpdateService.checkUpdate(), isNull);
    });

    test('ritorna null con body malformato', () async {
      HttpOverrides.global = _FakeHttpOverrides(body: 'non json');
      expect(await UpdateService.checkUpdate(), isNull);
    });

    test('ritorna null se la connessione fallisce', () async {
      HttpOverrides.global = _FakeHttpOverrides(fail: true);
      expect(await UpdateService.checkUpdate(), isNull);
    });
  });

  group('UpdateService.parseTagName', () {
    test('strips v prefix from tag_name', () {
      expect(UpdateService.parseTagName('{"tag_name":"v2.1.0"}'), '2.1.0');
    });

    test('works without v prefix', () {
      expect(UpdateService.parseTagName('{"tag_name":"2.1.0"}'), '2.1.0');
    });

    test('returns null for malformed JSON', () {
      expect(UpdateService.parseTagName('not json'), isNull);
    });

    test('returns null when tag_name is missing', () {
      expect(UpdateService.parseTagName('{"message":"Not Found"}'), isNull);
    });

    test('returns null for empty body', () {
      expect(UpdateService.parseTagName(''), isNull);
    });
  });

  group('UpdateService.parseVersion', () {
    test('parses standard semver', () {
      expect(UpdateService.parseVersion('2.1.3'), [2, 1, 3]);
    });

    test('pads missing parts with zeros', () {
      expect(UpdateService.parseVersion('2.1'), [2, 1, 0]);
      expect(UpdateService.parseVersion('2'), [2, 0, 0]);
    });

    test('handles non-numeric parts as zero', () {
      expect(UpdateService.parseVersion('2.x.3'), [2, 0, 3]);
    });
  });

  group('UpdateService.isNewer', () {
    test('patch bump is newer', () {
      expect(UpdateService.isNewer('2.0.1', '2.0.0'), isTrue);
    });

    test('minor bump is newer', () {
      expect(UpdateService.isNewer('2.1.0', '2.0.9'), isTrue);
    });

    test('major bump is newer', () {
      expect(UpdateService.isNewer('3.0.0', '2.9.9'), isTrue);
    });

    test('same version is not newer', () {
      expect(UpdateService.isNewer('2.0.0', '2.0.0'), isFalse);
    });

    test('older remote is not newer', () {
      expect(UpdateService.isNewer('1.9.9', '2.0.0'), isFalse);
    });

    test('remote with v-prefix stripped is handled correctly', () {
      // tag_name comes in already stripped of 'v' by checkUpdate
      expect(UpdateService.isNewer('2.0.1', '2.0.0'), isTrue);
    });

    test('multi-digit version components', () {
      expect(UpdateService.isNewer('2.0.10', '2.0.9'), isTrue);
      expect(UpdateService.isNewer('2.10.0', '2.9.0'), isTrue);
    });
  });
}

// ── Fake HTTP per checkUpdate ────────────────────────────────────────────────

class _FakeHttpOverrides extends HttpOverrides {
  _FakeHttpOverrides({this.statusCode = 200, this.body = '', this.fail = false});
  final int statusCode;
  final String body;
  final bool fail;

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _FakeHttpClient(statusCode: statusCode, body: body, fail: fail);
}

class _FakeHttpClient extends Fake implements HttpClient {
  _FakeHttpClient(
      {required this.statusCode, required this.body, required this.fail});
  final int statusCode;
  final String body;
  final bool fail;

  @override
  set connectionTimeout(Duration? value) {}

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    if (fail) throw const SocketException('rete assente');
    return _FakeHttpClientRequest(statusCode: statusCode, body: body);
  }

  @override
  void close({bool force = false}) {}
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  _FakeHttpClientRequest({required this.statusCode, required this.body});
  final int statusCode;
  final String body;

  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async =>
      _FakeHttpClientResponse(statusCode: statusCode, body: body);
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  _FakeHttpClientResponse({required this.statusCode, required this.body});

  @override
  final int statusCode;
  final String body;

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> streamTransformer) =>
      Stream<List<int>>.value(utf8.encode(body)).transform(streamTransformer);
}
