import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:biteplan/app.dart';
import 'package:biteplan/features/meal_planner/providers/meal_planner_provider.dart';
import 'package:biteplan/features/converter/providers/converter_provider.dart';
import 'package:biteplan/features/shopping_list/providers/shopping_list_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildApp() => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => MealPlannerProvider()..load()),
          ChangeNotifierProvider(
              create: (_) => ConverterProvider()..loadDb()),
          ChangeNotifierProvider(
              create: (_) => ShoppingListProvider()..load()),
        ],
        child: const BitePlanApp(),
      );

  // ── Navigazione ────────────────────────────────────────────────────────────

  group('Navigazione', () {
    testWidgets('il tab iniziale è Piano Pasti', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Piano Pasti'), findsOneWidget);
    });

    testWidgets('passa al tab Convertitore', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Converti'));
      await tester.pumpAndSettle();
      expect(find.text('Convertitore'), findsOneWidget);
    });

    testWidgets('passa al tab Lista della spesa', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spesa'));
      await tester.pumpAndSettle();
      expect(find.text('Lista della spesa'), findsOneWidget);
    });

    testWidgets('naviga tra tutti e tre i tab', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Converti'));
      await tester.pumpAndSettle();
      expect(find.text('Convertitore'), findsOneWidget);

      await tester.tap(find.text('Spesa'));
      await tester.pumpAndSettle();
      expect(find.text('Lista della spesa'), findsOneWidget);

      await tester.tap(find.text('Pasti'));
      await tester.pumpAndSettle();
      expect(find.text('Piano Pasti'), findsOneWidget);
    });
  });

  // ── Lista della spesa ──────────────────────────────────────────────────────

  group('Lista della spesa', () {
    testWidgets('aggiunge un elemento e lo mostra', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spesa'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Pollo');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Pollo'), findsOneWidget);
    });

    testWidgets('rimuove un elemento con il pulsante chiudi', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spesa'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Riso');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      expect(find.text('Riso'), findsNothing);
    });

    testWidgets('spuntare un elemento lo sposta in Completati', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spesa'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Pasta');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      expect(find.text('COMPLETATI (1)'), findsOneWidget);
    });

    testWidgets('aggiorna il contatore completati/totale', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spesa'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Pollo');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Riso');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      expect(find.text('1 / 2 completato'), findsOneWidget);
    });
  });

  // ── Convertitore ──────────────────────────────────────────────────────────

  group('Convertitore', () {
    testWidgets('mostra hint iniziale', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Converti'));
      await tester.pumpAndSettle();

      expect(find.text('Cerca un alimento per iniziare'), findsOneWidget);
    });

    testWidgets('la ricerca mostra risultati pertinenti', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Converti'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'pollo');
      await tester.pumpAndSettle();

      expect(find.textContaining('Pollo'), findsWidgets);
    });

    testWidgets('selezionare un alimento mostra la card del convertitore',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Converti'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'riso basmati');
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Riso basmati').first);
      await tester.pumpAndSettle();

      expect(find.text('CRUDO'), findsOneWidget);
      expect(find.text('COTTO'), findsOneWidget);
      expect(find.text('Cambia'), findsOneWidget);
    });

    testWidgets('il pulsante Cambia resetta la selezione', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Converti'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'riso basmati');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Riso basmati').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cambia'));
      await tester.pumpAndSettle();

      expect(find.text('Cerca un alimento per iniziare'), findsOneWidget);
    });
  });

  // ── Meal Planner ───────────────────────────────────────────────────────────

  group('Piano Pasti', () {
    testWidgets('genera lista della spesa e naviga al tab Spesa',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Trova il giorno corrente espanso e aggiungi un elemento
      final addButtons = find.byIcon(Icons.add);
      if (addButtons.evaluate().isNotEmpty) {
        final firstTextField = find.byType(TextField).first;
        await tester.enterText(firstTextField, 'Broccoli');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Genera lista della spesa'));
      await tester.pumpAndSettle();

      // Deve essere atterrato sul tab Spesa
      expect(find.text('Lista della spesa'), findsOneWidget);
    });
  });
}
