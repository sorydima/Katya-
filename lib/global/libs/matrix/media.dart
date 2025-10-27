import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:katya/global/https.dart';
import 'package:katya/global/values.dart';
import 'package:katya/store/settings/proxy-settings/model.dart';

class MatrixMedia {
  /// Check the maximum upload size allowed by the homeserver
  /// Returns the maximum upload size in bytes, or null if not specified
  static Future<int?> checkMaxUploadSize({
    String? protocol = Values.DEFAULT_PROTOCOL,
    String? homeserver = Values.homeserverDefault,
    String? accessToken,
    ProxySettings? proxySettings,
  }) async {
    try {
      final client = createClient(proxySettings: proxySettings);
      
      final response = await client.get(
        Uri.parse('$protocol$homeserver/_matrix/media/r0/config'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['m.upload.size']?['max_file_size'] as int?;
      }
      
      return null;
    } catch (error) {
      print('Error checking max upload size: $error');
      return null;
    }
  }

  static Future<dynamic> fetchThumbnailThreaded(Map params) async {
    final String? protocol = params['protocol'];
    final String? homeserver = params['homeserver'];
    final String? accessToken = params['accessToken'];
    final String? serverName = params['serverName'];
    final String mediaUri = params['mediaUri'];
    final ProxySettings? proxySettings = params['proxySettings'];

    httpClient = createClient(proxySettings: proxySettings);

    return fetchThumbnail(
      protocol: protocol,
      homeserver: homeserver,
      accessToken: accessToken,
      serverName: serverName,
      mediaUri: mediaUri,
      method: params['method'] ?? 'crop',
      size: params['size'] ?? 96,
    );
  }

  static Future<dynamic> fetchThumbnail({
    String? protocol = Values.DEFAULT_PROTOCOL,
    String? homeserver = Values.homeserverDefault,
    String? accessToken,
    String? serverName,
    required String mediaUri,
    String method = 'crop',
    int size = 96,
  }) async {
    final List<String> mediaUriParts = mediaUri.split('/');

    // Parce the mxc uri for the server location and id
    final String mediaId = mediaUriParts[mediaUriParts.length - 1];
    final String mediaServer = serverName ?? mediaUriParts[mediaUriParts.length - 2];

    String url = '$protocol$homeserver/_matrix/media/r0/thumbnail/$mediaServer/$mediaId';

    // Params
    url += '?height=$size&width=$size&method=$method';

    final Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
    };

    final response = await httpClient.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.headers['content-type'] == 'application/json') {
      final errorData = await json.decode(response.body);
      throw errorData['error'];
    }

    return {'bodyBytes': response.bodyBytes};
  }

  static Future<dynamic> fetchMediaThreaded(Map params) async {
    final String? protocol = params['protocol'];
    final String? homeserver = params['homeserver'];
    final String? accessToken = params['accessToken'];
    final String? serverName = params['serverName'];
    final String mediaUri = params['mediaUri'];
    final ProxySettings? proxySettings = params['proxySettings'];

    httpClient = createClient(proxySettings: proxySettings);

    return fetchMedia(
      protocol: protocol,
      homeserver: homeserver,
      accessToken: accessToken,
      serverName: serverName,
      mediaUri: mediaUri,
      method: params['method'] ?? 'crop',
      size: params['size'] ?? 96,
    );
  }

  static Future<dynamic> fetchMedia({
    String? protocol = Values.DEFAULT_PROTOCOL,
    String? homeserver = Values.homeserverDefault,
    String? accessToken,
    String? serverName,
    required String mediaUri,
    String method = 'crop',
    int size = 52,
  }) async {
    final List<String> mediaUriParts = mediaUri.split('/');

    // Parce the mxc uri for the server location and id
    final mediaId = mediaUriParts[mediaUriParts.length - 1];
    final mediaServer = serverName ?? mediaUriParts[mediaUriParts.length - 2];
    final url = '$protocol$homeserver/_matrix/media/r0/download/$mediaServer/$mediaId';

    final Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
    };

    final response = await httpClient.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.headers['content-type'] == 'application/json') {
      final errorData = await json.decode(response.body);
      throw errorData['error'];
    }

    return {'bodyBytes': response.bodyBytes};
  }


  static Future<dynamic> uploadMedia({
    String? protocol = Values.DEFAULT_PROTOCOL,
    String? homeserver = Values.homeserverDefault,
    String? accessToken,
    String? fileName,
    String fileType = 'application/jpeg', // Content-Type: application/pdf
    required Stream<List<int>> fileStream,
    int? fileLength,
  }) async {
    String url = '$protocol$homeserver/_matrix/media/r0/upload';

    // Params
    url += fileName != null ? '?filename=$fileName' : '';

    final Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': fileType,
      'Content-Length': '$fileLength',
    };

    // POST StreamedRequest for uploading byteStream
    final request = http.StreamedRequest(
      'POST',
      Uri.parse(url),
    );

    request.headers.addAll(headers);
    fileStream.listen(request.sink.add, onDone: () => request.sink.close());

    // Attempting to await the upload response successfully
    final mediaUploadResponseStream = await request.send();
    final mediaUploadResponse = await http.Response.fromStream(
      mediaUploadResponseStream,
    );

    return json.decode(mediaUploadResponse.body);
  }

  static String buildMessageUrl({String? roomId, String? eventId}) {
    return 'https://matrix.to/#/$roomId/$eventId';
  }
}

dynamic buildMediaDownloadRequest({
  String protocol = Values.DEFAULT_PROTOCOL,
  String homeserver = Values.homeserverDefault,
  String? accessToken,
  String? serverName,
  required String mediaUri,
}) {
  final List<String> mediaUriParts = mediaUri.split('/');
  final String mediaId = mediaUriParts[mediaUriParts.length - 1];
  final String mediaOrigin = serverName ?? homeserver;
  final String url = '$protocol$homeserver/_matrix/media/r0/download/$mediaOrigin/$mediaId';

  final Map<String, String> headers = {
    'Authorization': 'Bearer $accessToken',
  };

  return {
    'url': Uri.parse(url),
    'headers': headers,
  };
}

/// https://matrix.org/docs/spec/client_server/latest#id392
///
/// Upload some content to the content repository.
dynamic buildMediaUploadRequest({
  String protocol = Values.DEFAULT_PROTOCOL,
  String homeserver = Values.homeserverDefault,
  String? accessToken,
  String? fileName,
  String fileType = 'application/jpeg', // Content-Type: application/pdf
  int? fileLength,
}) {
  String url = '$protocol$homeserver/_matrix/media/r0/upload';

  // Params
  url += fileName != null ? '?filename=$fileName' : '';

  final Map<String, String> headers = {
    'Authorization': 'Bearer $accessToken',
    'Content-Type': fileType,
    'Content-Length': '$fileLength',
  };

  return {
    'url': Uri.parse(url),
    'headers': headers,
  };
}
