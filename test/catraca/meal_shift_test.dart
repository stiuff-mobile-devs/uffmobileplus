import 'package:flutter_test/flutter_test.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/meal_shift.dart';

DateTime _at(int day, int hour, [int minute = 0]) =>
    DateTime(2026, 11, day, hour, minute);

void main() {
  group('isSameMealShift', () {
    test('almoço do mesmo dia é duplicado', () {
      expect(isSameMealShift(_at(23, 11), _at(23, 14, 59)), isTrue);
      expect(isSameMealShift(_at(23, 10), _at(23, 12)), isTrue);
    });

    test('jantar do mesmo dia é duplicado', () {
      expect(isSameMealShift(_at(23, 16), _at(23, 19, 59)), isTrue);
    });

    test('almoço e jantar do mesmo dia não são duplicados', () {
      expect(isSameMealShift(_at(23, 12), _at(23, 17)), isFalse);
      expect(isSameMealShift(_at(23, 17), _at(23, 12)), isFalse);
    });

    test('mesmo turno em dias diferentes não é duplicado', () {
      expect(isSameMealShift(_at(22, 12), _at(23, 12)), isFalse);
    });

    test('fora das janelas nunca é duplicado (regra atual)', () {
      expect(isSameMealShift(_at(23, 15, 30), _at(23, 15, 40)), isFalse);
      expect(isSameMealShift(_at(23, 20), _at(23, 21)), isFalse);
      expect(isSameMealShift(_at(23, 9), _at(23, 9, 30)), isFalse);
    });

    test('limites das janelas', () {
      // 15:00 já está fora do almoço; 20:00 já está fora do jantar.
      expect(isSameMealShift(_at(23, 12), _at(23, 15)), isFalse);
      expect(isSameMealShift(_at(23, 17), _at(23, 20)), isFalse);
    });
  });
}
