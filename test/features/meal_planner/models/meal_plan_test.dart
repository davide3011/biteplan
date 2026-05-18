import 'package:flutter_test/flutter_test.dart';
import 'package:biteplan/features/meal_planner/models/meal_plan.dart';

void main() {
  group('DayPlan', () {
    test('crea con liste vuote di default', () {
      final day = DayPlan();
      expect(day.colazione, isEmpty);
      expect(day.pranzo, isEmpty);
      expect(day.cena, isEmpty);
    });

    test('slot() ritorna la lista corretta', () {
      final day = DayPlan(
        colazione: ['latte'],
        pranzo: ['pasta'],
        cena: ['pollo'],
      );
      expect(day.slot('colazione'), ['latte']);
      expect(day.slot('pranzo'), ['pasta']);
      expect(day.slot('cena'), ['pollo']);
      expect(day.slot('unknown'), isEmpty);
    });

    test('copyWith() non modifica lorigine', () {
      final day = DayPlan(colazione: ['latte']);
      final updated = day.copyWith(colazione: ['latte', 'caffè']);
      expect(updated.colazione, ['latte', 'caffè']);
      expect(day.colazione, ['latte']);
    });

    test('copyWith() preserva i campi non aggiornati', () {
      final day = DayPlan(colazione: ['latte'], pranzo: ['pasta']);
      final updated = day.copyWith(colazione: ['caffè']);
      expect(updated.pranzo, ['pasta']);
    });

    test('JSON round-trip preserva i dati', () {
      final day = DayPlan(colazione: ['latte', 'biscotti'], cena: ['pollo']);
      final restored = DayPlan.fromJson(day.toJson());
      expect(restored.colazione, ['latte', 'biscotti']);
      expect(restored.cena, ['pollo']);
      expect(restored.pranzo, isEmpty);
    });
  });

  group('MealPlan', () {
    test('empty() crea piano con tutti i giorni', () {
      const days = ['lunedi', 'martedi', 'mercoledi'];
      final plan = MealPlan.empty(days);
      expect(plan.days.keys, containsAll(days));
      for (final d in days) {
        expect(plan.days[d]!.colazione, isEmpty);
      }
    });

    test('hasAnyMeal è false con piano vuoto', () {
      final plan = MealPlan.empty(['lunedi', 'martedi']);
      expect(plan.hasAnyMeal, false);
    });

    test('hasAnyMeal è true con almeno un elemento', () {
      final plan = MealPlan({'lunedi': DayPlan(colazione: ['latte'])});
      expect(plan.hasAnyMeal, true);
    });

    test('allItems ritorna lista appiattita', () {
      final plan = MealPlan({
        'lunedi': DayPlan(colazione: ['latte'], pranzo: ['pasta']),
        'martedi': DayPlan(cena: ['pollo']),
      });
      expect(plan.allItems, containsAll(['latte', 'pasta', 'pollo']));
      expect(plan.allItems.length, 3);
    });

    test('allItems è vuota con piano vuoto', () {
      final plan = MealPlan.empty(['lunedi']);
      expect(plan.allItems, isEmpty);
    });

    test('withUpdatedDay() aggiorna solo il giorno specificato', () {
      final plan = MealPlan.empty(['lunedi', 'martedi']);
      final updated =
          plan.withUpdatedDay('lunedi', DayPlan(colazione: ['latte']));
      expect(updated.days['lunedi']!.colazione, ['latte']);
      expect(updated.days['martedi']!.colazione, isEmpty);
    });

    test('JSON round-trip preserva tutti i dati', () {
      final original = MealPlan({
        'lunedi': DayPlan(colazione: ['latte', 'biscotti'], cena: ['pollo']),
        'martedi': DayPlan(pranzo: ['pasta al pomodoro']),
      });
      final restored = MealPlan.fromJsonString(original.toJsonString());
      expect(restored.days['lunedi']!.colazione, ['latte', 'biscotti']);
      expect(restored.days['lunedi']!.cena, ['pollo']);
      expect(restored.days['martedi']!.pranzo, ['pasta al pomodoro']);
    });
  });
}
