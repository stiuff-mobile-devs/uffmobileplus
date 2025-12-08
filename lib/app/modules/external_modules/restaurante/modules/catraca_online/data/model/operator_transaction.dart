class OperatorTransactionModel {
  String? name;
  String? value;
  String? area;
  DateTime? date;

  OperatorTransactionModel({this.name, this.value, this.area, this.date});

  OperatorTransactionModel.fromJson(Map<String, dynamic> json) {
    name = json['nome'];
    value = json['valor'];
    area = json['area'];
    final dateStr = json['data_hora'];
    if (dateStr != null && dateStr is String && dateStr.isNotEmpty) {
      date = DateTime.tryParse(dateStr.replaceFirst(' ', 'T'));
    } else {
      date = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nome'] = name;
    data['valor'] = value;
    data['area'] = area;
    data['data_hora'] = date
        ?.toIso8601String()
        .replaceFirst('T', ' ')
        .split('.')
        .first;
    return data;
  }

  @override
  String toString() {
    return 'OperatorTransactionModel(nome: $name, valor: $value, area: $area, data: $date)';
  }
}
