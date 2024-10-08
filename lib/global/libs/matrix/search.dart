import 'dart:async';
import 'dart:convert';

import 'package:katya/global/https.dart';
import 'package:katya/global/values.dart';

class Search {
  static Future<dynamic> searchUsers({
    String? protocol = 'https://',
    String? homeserver = Values.homeserverDefault,
    String? accessToken,
    String? searchText,
    String? since,
  }) async {
    final String url = '$protocol$homeserver/_matrix/client/r0/user_directory/search';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      ...Values.defaultHeaders,
    };

    final Map body = {
      'limit': 10,
      'search_term': searchText,
    };

    final response = await httpClient.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );

    return json.decode(response.body);
  }

  static Future<dynamic> searchRooms({
    String? protocol = 'https://',
    String? homeserver = Values.homeserverDefault,
    String? accessToken,
    String? searchText,
    String? server,
    bool? global,
    String? since,
  }) async {
    String url = '$protocol$homeserver/_matrix/client/r0/publicRooms';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      ...Values.defaultHeaders,
    };

    final Map body = {
      'limit': 20,
      'server': server ?? homeserver,
      'include_all_networks': global,
      'filter': {
        'generic_search_term': searchText,
      },
    };

    if (since != null) {
      body['since'] = since;
    }

    url += '?server=${server ?? homeserver}';

    final response = await httpClient.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );

    return json.decode(response.body);
  }
}
