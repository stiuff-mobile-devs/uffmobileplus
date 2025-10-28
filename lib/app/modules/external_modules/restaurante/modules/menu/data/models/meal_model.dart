import 'package:xml/xml.dart';

class MealModel {
  dynamic date;
  String? campus;
  String? main;
  String? mainIngr;
  String? garnish;
  String? garnishIngr;
  String? side;
  String? sideIngr;
  String? salad1;
  String? salad2;
  String? dessert;
  String? observ;
  dynamic createdAt;
  dynamic open;
  dynamic id;

  MealModel(
      {this.date,
        this.campus,
        this.main,
        this.mainIngr,
        this.garnish,
        this.garnishIngr,
        this.side,
        this.sideIngr,
        this.salad1,
        this.salad2,
        this.dessert,
        this.observ,
        this.createdAt,
        this.open,
        this.id});

  MealModel.fromJson(Map<String, dynamic> json) {
    date = json["date"];
    campus = json["campus"];
    main = json["main"];
    mainIngr = json["main_ingr"];
    garnish = json["garnish"];
    garnishIngr = json["garnish_ingr"];
    side = json["side"];
    sideIngr = json["side_ingr"];
    salad1 = json["salad1"];
    salad2 = json["salad2"];
    dessert = json["dessert"];
    observ = json["observ"];
    open = json["open"];
    createdAt = json["created_at"];
    id = json["id"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> refeicao = {
      "date": date.toString(),
      "campus": campus,
      "main": main,
      "main_ingr": mainIngr,
      "garnish": garnish,
      "garnish_ingr": garnishIngr,
      "side": side,
      "side_ingr": sideIngr,
      "salad1": salad1,
      "salad2": salad2,
      "dessert": dessert,
      "observ": observ,
      "open": open,
    };
    return {"meal": refeicao};
  }
}

class LegacyMeal {
  String? date;
  String? type;
  String? mainDish;
  String? garnish;
  String? sideDish;
  String? salad1;
  String? salad2;
  String? dessert;
  String? juice;
  String? observations;

  LegacyMeal({
    this.date,
    this.type,
    this.mainDish,
    this.garnish,
    this.sideDish,
    this.salad1,
    this.salad2,
    this.juice,
    this.observations,
  });

  LegacyMeal.fromXml(XmlElement xmlElement) {
    date = xmlElement.getElement('no-name')!.innerText;
    type = xmlElement.getElement('Tipo-de-refei-o')!.innerText;
    mainDish = xmlElement.getElement('Prato-principal')!.innerText;
    garnish = xmlElement.getElement('Guarni-o')!.innerText;
    sideDish = xmlElement.getElement('Acompanhamentos')!.innerText;
    salad1 = xmlElement.getElement('Salada-1')!.innerText;
    salad2 = xmlElement.getElement('Salada-2')!.innerText;
    dessert = xmlElement.getElement('Sobremesa')!.innerText;
    juice = xmlElement.getElement('Refresco')!.innerText;
    observations = xmlElement.getElement('Observa-es')!.innerText;
  }

  MealModel? toMealModel(LegacyMeal? inMeal) {
    if (inMeal == null) return null;
    return MealModel(
      createdAt: inMeal.date,
      campus: 'gr',
      main: inMeal.mainDish,
      mainIngr: '-',
      garnish: inMeal.garnish,
      garnishIngr: '-',
      side: inMeal.sideDish,
      sideIngr: '-',
      salad1: inMeal.salad1,
      salad2: inMeal.salad2,
      dessert: inMeal.dessert,
      observ: inMeal.observations,
      open: 1,
    );
  }
}
