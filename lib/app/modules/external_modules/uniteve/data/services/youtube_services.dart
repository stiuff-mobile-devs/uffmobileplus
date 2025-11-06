import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:googleapis/youtube/v3.dart' as youtube;
import 'package:uffmobileplus/app/config/secrets.dart';

const uniteveChannelID = 'UCKEYaoGb16c-ZJZKxA2ND6A';

class YoutubeService {
  // TODO: Por que há duas chamadas?
  YoutubeService._instantiate();
  static final YoutubeService instance = YoutubeService._instantiate();

  final String _baseUrl = 'youtube.googleapis.com';

  Future<List<youtube.PlaylistItem>?> getPlaylistItems({required String playlistId}) async {
    // Monta os parâmetros da query para a API do YouTube.
    // 'part' define quais campos do recurso serão retornados (ex.: snippet, status).
    // 'playlistId' é o identificador da playlist que queremos listar.
    // 'maxResults' limita a quantidade de itens retornados.
    // 'key' é a chave de API (guardada em Secrets.apiKey).
    Map<String, dynamic> parameters = {
      'part': ['snippet', 'status'],
      'playlistId': playlistId,
      'maxResults': '3',
      'key': Secrets.apiKey,
    };

    // Constrói a URI HTTPS para o endpoint /youtube/v3/playlistItems.
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/playlistItems',
      parameters,
    );

    print('Fetching playlist items from URI: $uri');

    // Cabeçalhos da requisição. Aqui indicamos que esperamos/recebemos JSON.
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Executa a requisição GET para a API do YouTube.
    var response = await http.get(uri, headers: headers);

    // Decodifica o corpo JSON da resposta e converte para o modelo gerado
    // youtube.PlaylistItemListResponse. Atenção: se a API retornar um erro
    // (status HTTP diferente de 2xx), o corpo pode conter um objeto de erro
    // em vez do recurso esperado.
    // TODO: implementar tratamento de erros.
    var resource = youtube.PlaylistItemListResponse.fromJson(json.decode(response.body));

    // Retorna a lista de PlaylistItem (pode ser null se não houver itens).
    return resource.items;
  }

  Future<List<String>> getChannelSectionPlaylists() async {
    // Monta os parâmetros da query para obter as seções do canal.
    // 'part=contentDetails' retorna informações sobre conteúdos associados,
    // incluindo listas de playlists referenciadas em cada ChannelSection.
    // 'channelId' especifica o canal do uniteve.
    // 'key' é a chave da API armazenada em Secrets.apiKey.
    Map<String, String> parameters = {
      'part': 'contentDetails',
      'channelId': uniteveChannelID,
      'key': Secrets.apiKey,
    };

    // Constrói a URI para o endpoint /youtube/v3/channelSections.
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/channelSections',
      parameters
    );

    // Executa a requisição GET. Cabeçalhos indicam que esperamos JSON.
    http.Response response = await http.get(
      uri, 
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      }
    );

    // Decodifica a resposta JSON para o modelo gerado ChannelSectionListResponse.
    // TODO: não há aqui tratamento explícito de erros HTTP/JSON.
    var cs_response = youtube.ChannelSectionListResponse.fromJson(
      json.decode(response.body)
    );

    // Lista que irá conter os ids das playlists extraídas das seções do canal.
    List<String> s = [];

    // Para cada ChannelSection retornada:
    // - verifica se contentDetails está presente;
    // - se houver playlists listadas em contentDetails, pega o primeiro ID.
    // Nota: usamos .first por compatibilidade com o formato esperado,
    // mas isso assume que há ao menos uma playlist na lista.
    for (var i in cs_response.items!) {
      if (i.contentDetails != null) {
        s.add(i.contentDetails!.playlists!.first);
      }
    }

    // Retorna a lista de IDs de playlists coletadas (pode estar vazia).
    return s;
  }

  Future<youtube.Playlist?> getPlaylistInfo(String id) async {
    // Monta os parâmetros da query para obter informações da playlist.
    // 'part=snippet' solicita os campos de metadados (título, descrição, thumbnails, etc.).
    // 'id' é o identificador da playlist que queremos consultar.
    // 'key' é a chave da API armazenada em Secrets.apiKey.
    Map<String, String> parameters = {
      'part': 'snippet',
      'id': id,
      'key': Secrets.apiKey
    };

    // Constrói a URI para o endpoint /youtube/v3/playlists.
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/playlists',
      parameters
    );

    // Executa a requisição GET. Cabeçalhos indicam que esperamos JSON.
    http.Response response = await http.get(
      uri,
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      }
    );

    // Decodifica a resposta JSON para o modelo gerado PlaylistListResponse.
    // Observação: se a API retornar erro (status != 2xx), o corpo pode conter
    // um objeto de erro em vez da lista de playlists — não há tratamento explícito aqui.
    var pl_response = youtube.PlaylistListResponse.fromJson(
      json.decode(response.body)
    );

    return pl_response.items!.first;
  }
}