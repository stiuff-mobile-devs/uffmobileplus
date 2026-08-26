import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/models/discipline_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/models/weekday_model.dart';

part 'study_plan_model.g.dart';

@HiveType(typeId: 21)
class StudyPlanModel extends HiveObject {
  @HiveField(0)
  Map<WeekDay, List<Discipline>?>? plan;

  StudyPlanModel({this.plan});

  StudyPlanModel.fromJson(Map<String, dynamic> json) {
    if (json['plan'] == null) {
      plan = null;
      return;
    }

    try {
      plan = {};
      for (var day in WeekDay.values) {
        final data = json['plan']['dias'];
        final list = _getDisciplinesByDay(data[day.description]);
        plan![day] = list;
      }
    } catch (e) {
      plan = null;
      debugPrint("Error on decoding StudyPlanModel json: $e");
    }
  }

  List<Discipline>? _getDisciplinesByDay(Map<String, dynamic> json) {
    List<Discipline> disciplines = [];

    try {
      if (json['disciplinas'] != null && json['disciplinas'].length != 0) {
        json['disciplinas'].forEach((value) {
          disciplines.add(Discipline.fromJson(value));
        });
        
        disciplines.sort((a, b) {
          if (a.startTime == null && b.startTime == null) return 0;
          if (a.startTime == null) return 1;
          if (b.startTime == null) return -1;
          return a.startTime!.compareTo(b.startTime!);
        });
      }
    } catch (e) {
      debugPrint("Error on decoding Discipline list json: $e");
    }

    return disciplines;
  }
}