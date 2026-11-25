import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/models/cdc_chat_room_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/provider/cdc_google_chat_provider.dart';

/// Sala no formato da API (o link é só um texto de teste).
Map<String, dynamic> space(String id, String name, {String? uri}) => {
      'name': 'spaces/$id',
      'displayName': name,
      'spaceType': 'SPACE',
      'spaceUri': ?uri,
    };

void main() {
  group('CdcGoogleChatProvider.getSpaces', () {
    test('pagina, filtra só salas e envia o token', () async {
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        final page = request.url.queryParameters['pageToken'];
        final body = page == null
            ? {
                'spaces': [
                  space('A1', 'Sala A', uri: 'link-a1'),
                ],
                'nextPageToken': 'p2',
              }
            : {
                'spaces': [
                  space('B2', 'Sala B', uri: 'link-b2'),
                  space('C3', 'Sem link'),
                ],
              };
        return http.Response(
          jsonEncode(body),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final rooms = await CdcGoogleChatProvider().getSpaces(
        {'Authorization': 'Bearer teste'},
        inner: client,
      );

      expect(rooms.map((r) => r.id), ['spaces/A1', 'spaces/B2']);
      expect(rooms.every((r) => r.origin == CdcRoomOrigin.googleChat), isTrue);
      expect(rooms.first.chatSpaceId, 'A1');
      expect(requests.length, 2);
      expect(
        requests.first.url.queryParameters['filter'],
        'spaceType = "SPACE"',
      );
      expect(requests.first.headers['Authorization'], 'Bearer teste');
    });

    test('erro da API chega a quem chamou', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'error': {'code': 403, 'message': 'negado'},
          }),
          403,
          headers: {'content-type': 'application/json'},
        ),
      );

      expect(
        () => CdcGoogleChatProvider().getSpaces(const {}, inner: client),
        throwsA(anything),
      );
    });
  });
}
