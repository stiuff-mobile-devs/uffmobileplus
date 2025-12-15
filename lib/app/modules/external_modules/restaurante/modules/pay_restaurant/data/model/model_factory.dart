import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/base_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/card_transaction.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/user_balance.dart';

class ModelFactory {
  List<BaseModel> makeModels(String entityName, List<dynamic> maps) {
    List<BaseModel> entityList = [];
    if (entityName == '' || entityName == null || maps == null) {
      return entityList;
    }

    maps.forEach((map) {
      var entity = createInstance(entityName);
      if (entity != null) {
        entity.fromMap(map);
        entityList.add(entity);
      }
    });

    return entityList;
  }

  BaseModel createInstance(entityName) {
    switch (entityName) {
      case 'UserBalance':
        return UserBalance();
        break;
      case 'CardTransaction':
        return CardTransaction();
        break;
      default:
        throw Exception("Modelo não registrado!");
    }
  }
}
