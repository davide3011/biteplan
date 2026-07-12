import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biteplan/app.dart';
import 'package:biteplan/core/constants/app_constants.dart';
import 'package:biteplan/features/converter/providers/converter_provider.dart';
import 'package:biteplan/features/meal_planner/providers/meal_planner_provider.dart';
import 'package:biteplan/features/shopping_list/providers/shopping_list_provider.dart';

late MealPlannerProvider _meals;
late ConverterProvider _converter;
late ShoppingListProvider _shopping;

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _meals),
        ChangeNotifierProvider.value(value: _converter),
        ChangeNotifierProvider.value(value: _shopping),
      ],
      child: const BitePlanApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _appBarTitle(String text) => find.descendant(
    of: find.byType(AppBar), matching: find.text(text));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // I provider sono creati e caricati nel setUp (fuori dalla zona FakeAsync
  // di testWidgets): il caricamento async dentro il body può bloccare la suite.
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _meals = MealPlannerProvider();
    _converter = ConverterProvider();
    _shopping = ShoppingListProvider();
    await _meals.load();
    await _converter.loadDb();
    await _shopping.load();
  });

  group('BitePlanApp', () {
    testWidgets('parte sul tab Piano Pasti', (tester) async {
      await _pumpApp(tester);
      expect(_appBarTitle('Piano Pasti'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('naviga al tab Convertitore', (tester) async {
      await _pumpApp(tester);
      await tester.tap(find.text('Converti'));
      await tester.pumpAndSettle();
      expect(_appBarTitle('Convertitore'), findsOneWidget);
      expect(find.text('Cerca un alimento per iniziare'), findsOneWidget);
    });

    testWidgets('naviga al tab Lista della spesa', (tester) async {
      await _pumpApp(tester);
      await tester.tap(find.text('Spesa'));
      await tester.pumpAndSettle();
      expect(_appBarTitle('Lista della spesa'), findsOneWidget);
      expect(find.text('Lista vuota'), findsOneWidget);
    });

    testWidgets('il bottone info apre il bottom sheet informazioni',
        (tester) async {
      await _pumpApp(tester);
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();
      expect(find.text('Versione $kAppVersion'), findsOneWidget);
    });
  });
}
