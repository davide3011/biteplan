import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biteplan/features/shopping_list/presentation/pages/shopping_list_page.dart';
import 'package:biteplan/features/shopping_list/providers/shopping_list_provider.dart';
import '../../../helpers/pump_app.dart';

Widget _page(ShoppingListProvider provider) => ChangeNotifierProvider.value(
      value: provider,
      child: const Scaffold(body: ShoppingListPage()),
    );

void main() {
  late ShoppingListProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    provider = ShoppingListProvider();
    await provider.load();
  });

  group('ShoppingListPage', () {
    testWidgets('lista vuota mostra EmptyState', (tester) async {
      await tester.pumpApp(_page(provider));
      expect(find.text('Lista vuota'), findsOneWidget);
    });

    testWidgets('aggiunge un elemento con il pulsante +', (tester) async {
      await tester.pumpApp(_page(provider));
      await tester.enterText(find.byType(TextField), 'pane');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('pane'), findsOneWidget);
      expect(provider.items, hasLength(1));
    });

    testWidgets('aggiunge un elemento con Invio', (tester) async {
      await tester.pumpApp(_page(provider));
      await tester.enterText(find.byType(TextField), 'latte');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('latte'), findsOneWidget);
    });

    testWidgets('testo vuoto o solo spazi non aggiunge nulla', (tester) async {
      await tester.pumpApp(_page(provider));
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('Lista vuota'), findsOneWidget);
      expect(provider.items, isEmpty);
    });

    testWidgets('il contatore usa il singolare con 1 completato',
        (tester) async {
      provider.add('pane');
      provider.add('latte');
      provider.toggle(provider.items.first.id);
      await tester.pumpApp(_page(provider));
      expect(find.text('1 / 2 completato'), findsOneWidget);
    });

    testWidgets('il contatore usa il plurale con più completati',
        (tester) async {
      provider.add('pane');
      provider.add('latte');
      for (final item in [...provider.items]) {
        provider.toggle(item.id);
      }
      await tester.pumpApp(_page(provider));
      expect(find.text('2 / 2 completati'), findsOneWidget);
    });

    testWidgets('la sezione COMPLETATI appare solo con elementi spuntati',
        (tester) async {
      provider.add('pane');
      await tester.pumpApp(_page(provider));
      expect(find.textContaining('COMPLETATI'), findsNothing);

      provider.toggle(provider.items.first.id);
      await tester.pump();
      expect(find.text('COMPLETATI (1)'), findsOneWidget);
    });

    testWidgets('"Svuota lista" con Annulla non svuota', (tester) async {
      provider.add('pane');
      await tester.pumpApp(_page(provider));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Svuota lista'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();
      expect(provider.items, hasLength(1));
      expect(find.text('pane'), findsOneWidget);
    });

    testWidgets('"Svuota lista" con Svuota svuota tutto', (tester) async {
      provider.add('pane');
      await tester.pumpApp(_page(provider));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Svuota lista'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Svuota'));
      await tester.pumpAndSettle();
      expect(provider.items, isEmpty);
      expect(find.text('Lista vuota'), findsOneWidget);
    });
  });
}
