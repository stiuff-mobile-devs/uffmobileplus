import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/atividade.dart';
import 'dart:async';
//import 'dart:io'; -> se tiver httpheaders


Future<List<Atividade>> fetchAtividades() async {
  final response = await http.get(
    
    Uri.parse('https://renataverasventurim.github.io/mockup_json_api_proex/atividades.json'),
    //headers: {HttpHeaders.authorizationHeader: 'Basic your_api_token_here'},
  );

  if (response.statusCode == 200) {
    final body = utf8.decode(response.bodyBytes);
    final List<dynamic> jsonList = jsonDecode(body);
    return jsonList 
        .map((atividade) => Atividade.fromJson(atividade))
        .where((atividade) =>
            atividade.vagasDisponiveis != null)
        .toList();
  } else {
    throw Exception("Erro ao carregar dados: ${response.statusCode}");
  }
}
