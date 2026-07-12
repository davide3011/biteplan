import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biteplan/features/meal_planner/providers/meal_planner_provider.dart';
import 'package:biteplan/features/meal_planner/models/meal_plan.dart';
import 'package:biteplan/core/constants/app_constants.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MealPlannerProvider', () {
    test('inizia con piano vuoto', () async {
      final provider = MealPlannerProvider();
      await provider.load();
      expect(provider.plan.hasAnyMeal, false);
    });

    test('addItem aggiunge nello slot corretto', () async {
      final provider = MealPlannerProvider();
      await provider.load();
      provider.addItem('lunedi', 'colazione', 'latte');
      expect(provider.plan.days['lunedi']!.colazione, ['latte']);
      expect(provider.plan.days['lunedi']!.pranzo, isEmpty);
    });

    test('addItem aggiunge in tutti e tre gli slot', () async {
      final provider = MealPlannerProvider();
      await provider.load();
      provider.addItem('martedi', 'colazione', 'yogurt');
      provider.addItem('martedi', 'pranzo', 'pasta');
      provider.addItem('martedi', 'cena', 'pollo');
      expect(provider.plan.days['martedi']!.colazione, ['yogurt']);
      expect(provider.plan.days['martedi']!.pranzo, ['pasta']);
      expect(provider.plan.days['martedi']!.cena, ['pollo']);
    });

    test('addItem ignora testo vuoto o solo spazi', () async {
      final provider = MealPlannerProvider();
      await provider.load();
      provider.addItem('lunedi', 'colazione', '  ');
      provider.addItem('lunedi', 'colazione', '');
      expect(provider.plan.days['lunedi']!.colazione, isEmpty);
    });

    test('addItem esegue trim del testo', () async {
      final provider = MealPlannerProvider();
      await provider.load();
      provider.addItem('lunedi', 'pranzo', '  pasta  ');
      expect(provider.plan.days['lunedi']!.pranzo, ['pasta']);
    });

    test('removeItem rimuove dalla posizione corretta', () async {
      final provider = MealPlannerProvider();
      await provider.load();
      provider.addItem('lunedi', 'pranzo', 'pasta');
      provider.addItem('lunedi', 'pranzo', 'insalata');
      provider.addItem('lunedi', 'pranzo', 'frutta');
      provider.removeItem('lunedi', 'pranzo', 1);
      expect(provider.plan.days['lunedi']!.pranzo, ['pasta', 'frutta']);
    });

    test('removeItem rimuove dallo slot colazione', () async {
      final provider = MealPlannerProvider();
      await provider.load();
      provider.addItem('lunedi', 'colazione', 'latte');
      provider.addItem('lunedi', 'colazione', 'caffè');
      provider.removeItem('lunedi', 'colazione', 0);
      expect(provider.plan.days['lunedi']!.colazione, ['caffè']);
    });

    test('removeItem rimuove dallo slot cena', () async {
      final provider = MealPlannerProvider();
      await provider.load();
      provider.addItem('lunedi', 'cena', 'pollo');
      provider.addItem('lunedi', 'cena', 'verdure');
      provider.removeItem('lunedi', 'cena', 1);
      expect(provider.plan.days['lunedi']!.cena, ['pollo']);
    });

    test('clearAll svuota tutti i giorni', () async {
      final provider = MealPlannerProvider();
      await provider.load();
      provider.addItem('lunedi', 'colazione', 'latte');
      provider.addItem('venerdi', 'cena', 'pesce');
      provider.clearAll();
      expect(provider.plan.hasAnyMeal, false);
    });

    test('persiste e ricarica i dati', () async {
      final provider1 = MealPlannerProvider();
      await provider1.load();
      provider1.addItem('lunedi', 'cena', 'pollo');
      await Future.delayed(const Duration(milliseconds: 50));

      final provider2 = MealPlannerProvider();
      await provider2.load();
      expect(provider2.plan.days['lunedi']!.cena, ['pollo']);
    });

    test('notifica i listener dopo addItem', () async {
      final provider = MealPlannerProvider();
      await provider.load();
      var notified = false;
      provider.addListener(() => notified = true);
      provider.addItem('lunedi', 'colazione', 'latte');
      expect(notified, true);
    });

    group('importPlan()', () {
      test('sovrascrive il piano corrente', () async {
        final provider = MealPlannerProvider();
        await provider.load();
        provider.addItem('lunedi', 'colazione', 'latte');

        final newPlan = MealPlan({
          ...Map.fromEntries(kDayIds.map((d) => MapEntry(d, DayPlan()))),
          'martedi': DayPlan(pranzo: ['pasta']),
        });
        provider.importPlan(newPlan);

        expect(provider.plan.days['lunedi']!.colazione, isEmpty);
        expect(provider.plan.days['martedi']!.pranzo, ['pasta']);
      });

      test('persiste il piano importato', () async {
        final provider1 = MealPlannerProvider();
        await provider1.load();
        final newPlan = MealPlan({
          ...Map.fromEntries(kDayIds.map((d) => MapEntry(d, DayPlan()))),
          'mercoledi': DayPlan(cena: ['pesce']),
        });
        provider1.importPlan(newPlan);
        await Future.delayed(const Duration(milliseconds: 50));

        final provider2 = MealPlannerProvider();
        await provider2.load();
        expect(provider2.plan.days['mercoledi']!.cena, ['pesce']);
      });

      test('notifica i listener', () async {
        final provider = MealPlannerProvider();
        await provider.load();
        var notified = false;
        provider.addListener(() => notified = true);
        provider.importPlan(MealPlan.empty(kDayIds));
        expect(notified, true);
      });
    });

    test('load gestisce JSON corrotto con piano vuoto', () async {
      SharedPreferences.setMockInitialValues({'meals': 'json non valido {'});
      final provider = MealPlannerProvider();
      await provider.load();
      expect(provider.plan.hasAnyMeal, false);
    });
  });
}
