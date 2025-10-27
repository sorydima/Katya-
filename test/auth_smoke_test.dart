import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:katya/global/https.dart';
import 'package:katya/global/libs/matrix/auth.dart';
import 'package:test/test.dart';

class _MockClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.url.path.endsWith('/_matrix/client/versions')) {
      final body = json.encode({
        'versions': ['r0.6.1'],
        'unstable_features': {},
      });
      final stream = Stream<List<int>>.fromIterable([utf8.encode(body)]);
      return http.StreamedResponse(stream, 200, request: request);
    }
    final stream = Stream<List<int>>.fromIterable([utf8.encode('{}')]);
    return http.StreamedResponse(stream, 404, request: request);
  }
}

void main() {
  test('checkVersion returns versions structure', () async {
    // Swap the global httpClient in auth.dart if exposed; otherwise rely on default.
    // Here we call the method with a known good host expectation and mock client.

    // Using the global http client from auth.dart is assumed; this test validates parsing
    // by calling the method and asserting keys. If networking is unavailable, this mock ensures stability.
    httpClient = _MockClient();

    final data = await Auth.checkVersion(
      protocol: 'https://',
      homeserver: 'example.com',
    );

    expect(data is Map, isTrue);
    expect((data as Map).containsKey('versions'), isTrue);
  });
}
