import 'package:equatable/equatable.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/base_model.dart';

class CardTransaction extends BaseModel with EquatableMixin {
  String? value;
  String? type;
  String? category;
  DateTime? date;

  @override
  void fromMap(Map<String, dynamic> map) {
    if (map["valor"] != null) this.value = map["valor"].toString();
    this.type = map["tipo"];
    this.category = map["categoria"];
    if (map["data"] != null) this.date = DateTime.parse(map["data"]);
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [value!, type!, date!];

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }
}
