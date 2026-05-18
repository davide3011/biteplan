import 'package:flutter_test/flutter_test.dart';
import 'package:biteplan/features/meal_planner/qr_codec.dart';
import 'package:biteplan/features/meal_planner/models/meal_plan.dart';
import 'package:biteplan/core/constants/app_constants.dart';

void main() {
  group('buildQrPayload', () {
    test('genera payload non nullo per piano vuoto', () {
      final plan = MealPlan.empty(kDayIds);
      expect(buildQrPayload(plan), isNotNull);
    });

    test('il payload contiene versione e dati pasti', () {
      final plan = MealPlan.empty(kDayIds);
      final payload = buildQrPayload(plan)!;
      expect(payload, contains('"v":1'));
      expect(payload, contains('"meals"'));
    });

    test('il payload include i dati inseriti', () {
      final plan = MealPlan({
        ...Map.fromEntries(kDayIds.map((d) => MapEntry(d, DayPlan()))),
        'lunedi': DayPlan(colazione: ['latte', 'biscotti'], pranzo: ['pasta']),
      });
      final payload = buildQrPayload(plan)!;
      expect(payload, contains('latte'));
      expect(payload, contains('biscotti'));
      expect(payload, contains('pasta'));
    });

    test('restituisce null se payload supera 2953 byte', () {
      final longName = 'a' * 400;
      final plan = MealPlan(Map.fromEntries(kDayIds.map((d) => MapEntry(
        d,
        DayPlan(
          colazione: List.generate(5, (_) => longName),
          pranzo: List.generate(5, (_) => longName),
          cena: List.generate(5, (_) => longName),
        ),
      ))));
      expect(buildQrPayload(plan), isNull);
    });
  });

  group('parseMealPlanFromQr', () {
    test('round-trip: parse di payload generato da buildQrPayload', () {
      final plan = MealPlan.empty(kDayIds);
      final payload = buildQrPayload(plan)!;
      final (parsed, error) = parseMealPlanFromQr(payload);
      expect(error, isNull);
      expect(parsed, isNotNull);
      for (final day in kDayIds) {
        expect(parsed!.days.containsKey(day), true);
      }
    });

    test('round-trip preserva tutti i pasti', () {
      final original = MealPlan({
        ...Map.fromEntries(kDayIds.map((d) => MapEntry(d, DayPlan()))),
        'lunedi': DayPlan(colazione: ['latte'], pranzo: ['pasta'], cena: ['pollo']),
        'martedi': DayPlan(cena: ['pesce']),
      });
      final payload = buildQrPayload(original)!;
      final (parsed, error) = parseMealPlanFromQr(payload);

      expect(error, isNull);
      expect(parsed!.days['lunedi']!.colazione, ['latte']);
      expect(parsed.days['lunedi']!.pranzo, ['pasta']);
      expect(parsed.days['lunedi']!.cena, ['pollo']);
      expect(parsed.days['martedi']!.cena, ['pesce']);
      expect(parsed.days['mercoledi']!.colazione, isEmpty);
    });

    test('errore su stringa non JSON', () {
      final (plan, error) = parseMealPlanFromQr('testo non json');
      expect(plan, isNull);
      expect(error, isNotNull);
    });

    test('errore se versione non è 1', () {
      final (plan, error) = parseMealPlanFromQr('{"v":2,"meals":{}}');
      expect(plan, isNull);
      expect(error, contains('non valido'));
    });

    test('errore se meals è una lista invece di una mappa', () {
      final (plan, error) = parseMealPlanFromQr('{"v":1,"meals":[]}');
      expect(plan, isNull);
      expect(error, isNotNull);
    });

    test('errore se struttura di un giorno non è valida', () {
      final (plan, error) = parseMealPlanFromQr('{"v":1,"meals":{"lunedi":"stringa"}}');
      expect(plan, isNull);
      expect(error, isNotNull);
    });

    test('errore se campo v è assente', () {
      final (plan, error) = parseMealPlanFromQr('{"meals":{}}');
      expect(plan, isNull);
      expect(error, isNotNull);
    });
  });
}
