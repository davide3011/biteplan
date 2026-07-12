import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biteplan/features/meal_planner/presentation/pages/meal_planner_page.dart';
import 'package:biteplan/features/meal_planner/presentation/widgets/meal_card.dart';
import 'package:biteplan/features/meal_planner/providers/meal_planner_provider.dart';
import 'package:biteplan/features/shopping_list/providers/shopping_list_provider.dart';
import '../../../helpers/pump_app.dart';

Widget _page({
  required MealPlannerProvider meals,
  required ShoppingListProvider shopping,
  VoidCallback? onGoShopping,
}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: meals),
        ChangeNotifierProvider.value(value: shopping),
      ],
      child: Scaffold(
        body: MealPlannerPage(onGoShopping: onGoShopping ?? () {}),
      ),
    );

String get _todayId {
  const ids = [
    '',
    'lunedi',
    'martedi',
    'mercoledi',
    'giovedi',
    'venerdi',
    'sabato',
    'domenica',
  ];
  return ids[DateTime.now().weekday];
}

void main() {
  late MealPlannerProvider meals;
  late ShoppingListProvider shopping;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    meals = MealPlannerProvider();
    shopping = ShoppingListProvider();
    await meals.load();
    await shopping.load();
  });

  Future<void> pumpPage(WidgetTester tester, {VoidCallback? onGoShopping}) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpApp(
        _page(meals: meals, shopping: shopping, onGoShopping: onGoShopping));
  }

  group('MealPlannerPage', () {
    testWidgets('mostra le 7 card dei giorni', (tester) async {
      await pumpPage(tester);
      expect(find.byType(MealCard), findsNWidgets(7));
    });

    testWidgets('solo la card di oggi è inizialmente espansa', (tester) async {
      await pumpPage(tester);
      for (final card in
          tester.widgetList<MealCard>(find.byType(MealCard))) {
        expect(card.initiallyExpanded, card.dayId == _todayId,
            reason: card.dayId);
      }
    });

    testWidgets('"Condividi" è disabilitato con piano vuoto', (tester) async {
      await pumpPage(tester);
      final button = tester.widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Condividi'));
      expect(button.onPressed, isNull);
    });

    testWidgets('"Condividi" è abilitato con almeno un pasto', (tester) async {
      meals.addItem('lunedi', 'pranzo', 'pasta');
      await pumpPage(tester);
      final button = tester.widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Condividi'));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('"Svuota piano" appare solo con pasti presenti',
        (tester) async {
      await pumpPage(tester);
      expect(find.text('Svuota piano'), findsNothing);

      meals.addItem('lunedi', 'pranzo', 'pasta');
      await tester.pump();
      expect(find.text('Svuota piano'), findsOneWidget);
    });

    testWidgets('"Genera lista" popola la spesa e chiama onGoShopping',
        (tester) async {
      meals.addItem('lunedi', 'pranzo', 'pasta');
      meals.addItem('martedi', 'cena', 'pollo');
      var navigated = false;
      await pumpPage(tester, onGoShopping: () => navigated = true);

      await tester.tap(find.text('Genera lista della spesa'));
      await tester.pump();

      expect(navigated, isTrue);
      expect(shopping.items.map((i) => i.name),
          containsAll(['pasta', 'pollo']));
    });

    testWidgets('"Svuota piano" con Annulla mantiene i pasti', (tester) async {
      meals.addItem('lunedi', 'pranzo', 'pasta');
      await pumpPage(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Svuota piano'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();
      expect(meals.plan.hasAnyMeal, isTrue);
    });

    testWidgets('"Svuota piano" con Svuota azzera il piano', (tester) async {
      meals.addItem('lunedi', 'pranzo', 'pasta');
      await pumpPage(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Svuota piano'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Svuota'));
      await tester.pumpAndSettle();
      expect(meals.plan.hasAnyMeal, isFalse);
    });
  });
}
