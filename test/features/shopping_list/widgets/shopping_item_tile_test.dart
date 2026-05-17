import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biteplan/features/shopping_list/presentation/widgets/shopping_item_tile.dart';
import 'package:biteplan/features/shopping_list/models/shopping_item.dart';
import '../../../helpers/pump_app.dart';

Widget _tile({
  required ShoppingItem item,
  VoidCallback? onToggle,
  VoidCallback? onRemove,
}) =>
    Scaffold(
      body: ShoppingItemTile(
        item: item,
        onToggle: onToggle ?? () {},
        onRemove: onRemove ?? () {},
      ),
    );

void main() {
  group('ShoppingItemTile', () {
    testWidgets('mostra il nome dell\'elemento', (tester) async {
      await tester.pumpApp(_tile(item: const ShoppingItem(id: '1', name: 'Pollo')));
      expect(find.text('Pollo'), findsOneWidget);
    });

    testWidgets('checkbox non spuntato quando checked è false', (tester) async {
      await tester.pumpApp(_tile(item: const ShoppingItem(id: '1', name: 'Riso')));
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });

    testWidgets('checkbox spuntato quando checked è true', (tester) async {
      await tester.pumpApp(
          _tile(item: const ShoppingItem(id: '1', name: 'Riso', checked: true)));
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);
    });

    testWidgets('chiama onToggle al tap sul checkbox', (tester) async {
      var toggled = false;
      await tester.pumpApp(_tile(
        item: const ShoppingItem(id: '1', name: 'Pollo'),
        onToggle: () => toggled = true,
      ));
      await tester.tap(find.byType(Checkbox));
      expect(toggled, true);
    });

    testWidgets('chiama onRemove al tap sul pulsante chiudi', (tester) async {
      var removed = false;
      await tester.pumpApp(_tile(
        item: const ShoppingItem(id: '1', name: 'Pasta'),
        onRemove: () => removed = true,
      ));
      await tester.tap(find.byIcon(Icons.close));
      expect(removed, true);
    });

    testWidgets('testo barrato quando elemento è completato', (tester) async {
      await tester.pumpApp(
          _tile(item: const ShoppingItem(id: '1', name: 'Tonno', checked: true)));
      final textWidget = tester.widget<Text>(find.text('Tonno'));
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('non mostra indicatore quantità quando quantity è 1', (tester) async {
      await tester.pumpApp(_tile(item: const ShoppingItem(id: '1', name: 'Riso')));
      expect(find.text('(x1)'), findsNothing);
    });

    testWidgets('mostra (x2) quando quantity è 2', (tester) async {
      await tester.pumpApp(
          _tile(item: const ShoppingItem(id: '1', name: 'Zucchine', quantity: 2)));
      expect(find.text('(x2)'), findsOneWidget);
    });

    testWidgets('mostra (xN) per quantità maggiori', (tester) async {
      await tester.pumpApp(
          _tile(item: const ShoppingItem(id: '1', name: 'Pollo', quantity: 5)));
      expect(find.text('(x5)'), findsOneWidget);
    });
  });
}
