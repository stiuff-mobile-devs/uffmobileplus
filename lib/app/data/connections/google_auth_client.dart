import 'package:http/http.dart' as http;

/// Cliente HTTP que envia os headers de autorização da conta Google
/// (obtidos pelo google_sign_in) em toda requisição. Usado com as APIs do
/// pacote `googleapis` (Drive, Chat...).
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client;

  GoogleAuthClient(this._headers, {http.Client? inner})
      : _client = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() => _client.close();
}
