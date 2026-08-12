class UserMealModel {
  String? campus;
  late dynamic date;
  dynamic mealId;

  UserMealModel({
    this.mealId,
    this.campus,
    this.date,
  });

  UserMealModel.fromJson(Map<String, dynamic> json) {
    mealId = json["meal_id"];
    date = json["meal_date"];
    campus = json["meal_campus"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> refeicaoAceita = {
      "meal_id": mealId,
      "meal_date": date.toString(),
      "meal_campus": campus,
    };
    return {"user_meal": refeicaoAceita};
  }
}
