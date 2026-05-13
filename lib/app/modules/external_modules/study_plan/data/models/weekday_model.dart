import 'package:get/get.dart';
import 'package:hive/hive.dart';

part 'weekday_model.g.dart';

@HiveType(typeId: 19)
enum WeekDay {
  @HiveField(0)
  monday("segunda"),
  @HiveField(1)
  tuesday("terca"),
  @HiveField(2)
  wednesday("quarta"),
  @HiveField(3)
  thursday("quinta"),
  @HiveField(4)
  friday("sexta"),
  @HiveField(5)
  saturday("sabado");

  final String description;
  const WeekDay(this.description);
}

String weekdayToString(WeekDay day) {
  Get.appendTranslations({
    'pt_BR' : {
      'segunda' : 'Segunda',
      'terca' : 'Terça',
      'quarta' : 'Quarta',
      'quinta' : 'Quinta',
      'sexta' : 'Sexta',
      'sabado' : 'Sábado'
    },
    'en_US' : {
      'segunda' : 'Monday',
      'terca' : 'Tuesday',
      'quarta' : 'Wednesday',
      'quinta' : 'Thursday',
      'sexta' : 'Friday',
      'sabado' : 'Saturday'
    },
    'it_IT' : {

    }
  });
  switch (day) {
    case WeekDay.monday:
      return "segunda".tr;

    case WeekDay.tuesday:
      return "terca".tr;

    case WeekDay.wednesday:
      return "quarta".tr;

    case WeekDay.thursday:
      return "quinta".tr;

    case WeekDay.friday:
      return "sexta".tr;

    case WeekDay.saturday:
      return "sabado".tr;
  }
}
