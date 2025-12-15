import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/base_model.dart';
import 'package:equatable/equatable.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/card_transaction.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/model_factory.dart';

class UserBalance extends BaseModel with EquatableMixin {
  String? idUff;
  String? name;
  String? currentBalance;
  List<CardTransaction>? statement;

  @override
  void fromMap(Map<String, dynamic> map) {
    this.idUff = map["iduff"];
    this.name = map["nome"];
    this.currentBalance = map["saldo_atual"];

    if (map["transacoes"] != null) {
      ModelFactory modelFactory = ModelFactory();
      statement = modelFactory
          .makeModels("CardTransaction", map["transacoes"])
          .cast<CardTransaction>();
    }
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [idUff!, name!, currentBalance!, statement!];

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }
}
