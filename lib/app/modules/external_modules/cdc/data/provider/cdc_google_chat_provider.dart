import 'package:googleapis/chat/v1.dart' as chat;
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/data/connections/google_auth_client.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/models/cdc_chat_room_model.dart';

/// Salas do Google Chat em que o usuário está, lidas em nome dele
/// (escopo [scope]).
class CdcGoogleChatProvider {
  static const String scope = chat.HangoutsChatApi.chatSpacesReadonlyScope;

  /// Só salas com nome: sem conversas em grupo e sem conversas individuais.
  static const String _filter = 'spaceType = "SPACE"';
  static const int _pageSize = 100;
  static const int _maxPages = 10;

  /// [inner] só para testes (cliente HTTP falso).
  Future<List<CdcChatRoomModel>> getSpaces(
    Map<String, String> authHeaders, {
    http.Client? inner,
  }) async {
    final client = GoogleAuthClient(authHeaders, inner: inner);
    try {
      final api = chat.HangoutsChatApi(client);
      final rooms = <CdcChatRoomModel>[];
      String? pageToken;
      var page = 0;
      do {
        final response = await api.spaces.list(
          filter: _filter,
          pageSize: _pageSize,
          pageToken: pageToken,
        );
        rooms.addAll(
          (response.spaces ?? const <chat.Space>[])
              .map(fromSpace)
              .whereType<CdcChatRoomModel>(),
        );
        pageToken = response.nextPageToken;
        page++;
      } while (pageToken != null && pageToken.isNotEmpty && page < _maxPages);
      return rooms;
    } finally {
      client.close();
    }
  }

  /// Converte uma sala da API. Descarta a que não tem nome, id ou link
  /// (`spaceUri`, que a própria API devolve; nenhum link é montado aqui).
  static CdcChatRoomModel? fromSpace(chat.Space space) {
    final id = (space.name ?? '').trim();
    final name = (space.displayName ?? '').trim();
    final link = (space.spaceUri ?? '').trim();
    if (id.isEmpty || name.isEmpty || link.isEmpty) return null;
    return CdcChatRoomModel(
      id: id,
      name: name,
      link: link,
      type: '',
      allCourses: true,
      courses: const [],
      origin: CdcRoomOrigin.googleChat,
    );
  }
}
