class AreaModel {
  int? id;
  String? nome;

  AreaModel({this.id, this.nome});

  AreaModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nome'] = nome;
    return data;
  }

  @override
  String toString() {
    return 'AreaModel{id: $id, nome: $nome}';
  }
}
