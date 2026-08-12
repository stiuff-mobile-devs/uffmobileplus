import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Campus {
  final String name;
  final double? latitude;
  final double? longitude;
  final String address;
  final String? iconImgPath;
  final String? panelImgPath;
  final LocationColor colorId;

  Campus({
    required this.name,
    this.latitude,
    this.longitude,
    required this.address,
    this.iconImgPath,
    this.panelImgPath,
    required this.colorId,
  });

  String get shortAddress {
    const int maxLength = 30;
    return address.length <= maxLength
        ? address
        : '${address.substring(0, maxLength)}...';
  }

  static String getShift(DateTime date) {
    switch (date.hour) {
      case (11):
        return 'Almoço';
      case (12):
        return 'Almoço';
      case (17):
        return 'Jantar';
      default:
        return 'undefined';
    }
  }

  static bool isActive(String sigla) {
    DateFormat('yyyy-MM-dd').format(DateTime.now());
    // DateTime curDateTime = DateTime.parse("$formattedDate 13:30:00");
    DateTime curDateTime = DateTime.now();
    if (curDateTime.weekday == 6 || curDateTime.weekday == 7) return false;
    switch (sigla) {
      case "gr":
        if (curDateTime.isAfter(DateTime.parse(getSchedule('gr')[0])) &&
            curDateTime.isBefore(DateTime.parse(getSchedule('gr')[1]))) {
          return true;
        }
        if (curDateTime.hour >= DateTime.parse(getSchedule('gr')[2]).hour &&
            curDateTime.hour < DateTime.parse(getSchedule('gr')[3]).hour) {
          return true;
        }
        return false;
      case "pv":
        if ((curDateTime.hour >= DateTime.parse(getSchedule('pv')[0]).hour &&
                curDateTime.hour < DateTime.parse(getSchedule('pv')[1]).hour) ||
            (curDateTime.hour >= DateTime.parse(getSchedule('pv')[2]).hour &&
                curDateTime.hour < DateTime.parse(getSchedule('pv')[3]).hour)) {
          return true;
        }
        return false;
      case "re":
        if (curDateTime.hour >= DateTime.parse(getSchedule('re')[0]).hour &&
            curDateTime.hour < DateTime.parse(getSchedule('re')[1]).hour) {
          return true;
        }
        return false;
      case "ve":
        if (curDateTime.hour >= DateTime.parse(getSchedule('ve')[0]).hour &&
            curDateTime.hour < DateTime.parse(getSchedule('ve')[1]).hour) {
          return true;
        }
        return false;
      case "hu":
        if (curDateTime.hour >= DateTime.parse(getSchedule('hu')[0]).hour &&
            curDateTime.hour < DateTime.parse(getSchedule('hu')[1]).hour) {
          return true;
        }
        return false;
      default:
        return false;
    }
  }

  static List<String> getSchedule(String sigla) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    switch (sigla) {
      case "gr":
        return [
          '$formattedDate 11:15:00',
          '$formattedDate 14:30:00',
          '$formattedDate 17:00:00',
          '$formattedDate 19:00:00'
        ];
      case "pv":
        return [
          '$formattedDate 12:00:00',
          '$formattedDate 14:00:00',
          '$formattedDate 17:00:00',
          '$formattedDate 19:00:00'
        ];
      case "re":
        return [
          '$formattedDate 12:00:00',
          '$formattedDate 14:00:00',
          'null',
          'null'
        ];
      case "ve":
        return [
          '$formattedDate 12:00:00',
          '$formattedDate 14:00:00',
          'null',
          'null'
        ];
      case "hu":
        return [
          '$formattedDate 12:00:00',
          '$formattedDate 14:00:00',
          'null',
          'null'
        ];
      default:
        return ['null', 'null', 'null', 'null'];
    }
  }

  static Color getColor(String sigla) {
    switch (sigla) {
      case "gr":
        return Colors.orange;
      case "pv":
        return Colors.green;
      case "re":
        return Colors.red;
      case "ve":
        return Colors.blue;
      case "hu":
        return Colors.purple;
      default:
        return Colors.transparent;
    }
  }

  static String getName(String sigla) {
    switch (sigla) {
      case "gr":
        return 'Gragoatá';
      case "pv":
        return 'Praia Vermelha';
      case "re":
        return 'Reitoria';
      case "ve":
        return 'Veterinária';
      case "hu":
        return 'HUAP';
      default:
        return '';
    }
  }

  static String getSigla(String campus) {
    switch (campus) {
      case "Gragoatá":
        return 'gr';
      case "Praia Vermelha":
        return 'pv';
      case "Reitoria":
        return 're';
      case "Veterinária":
        return 've';
      case "HUAP":
        return 'hu';
      default:
        return '';
    }
  }
}

enum LocationColor {
  orange, // Gragoatá
  green, // Praia Vermelha
  red, // Reitoria
  blue, // Veterinária
  purple, // HUAP
}

extension LocationColorExtension on LocationColor {
  String get shouldReference {
    switch (this) {
      case LocationColor.orange:
        return 'Gragoatá';
      case LocationColor.green:
        return 'Praia Vermelha';
      case LocationColor.red:
        return 'Reitoria';
      case LocationColor.blue:
        return 'Veterinária';
      case LocationColor.purple:
        return 'HUAP';
      default:
        return '';
    }
  }

  Color get color {
    switch (this) {
      case LocationColor.orange:
        return Colors.orange;
      case LocationColor.green:
        return Colors.green;
      case LocationColor.red:
        return Colors.red;
      case LocationColor.blue:
        return Colors.blue;
      case LocationColor.purple:
        return Colors.purple;
      default:
        return Colors.transparent;
    }
  }
}
