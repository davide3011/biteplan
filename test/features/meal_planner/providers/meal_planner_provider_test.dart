import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biteplan/features/meal_planner/providers/meal_planner_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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
}
