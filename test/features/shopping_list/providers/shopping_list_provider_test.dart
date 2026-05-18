import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biteplan/features/shopping_list/providers/shopping_list_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ShoppingListProvider', () {
    test('inizia vuota', () async {
      final provider = ShoppingListProvider();
      await provider.load();
      expect(provider.items, isEmpty);
    });

    group('add()', () {
      test('aggiunge un elemento', () async {
        final provider = ShoppingListProvider();
        await provider.load();
        provider.add('Pollo');
        expect(provider.items.length, 1);
        expect(provider.items.first.name, 'Pollo');
        expect(provider.items.first.checked, false);
      });

      test('ignora stringa vuota o solo spazi', () async {
        final provider = ShoppingListProvider();
        await provider.load();
        provider.add('  ');
        provider.add('');
        expect(provider.items, isEmpty);
      });

      test('esegue trim del testo', () async {
        final provider = ShoppingListProvider();
        await provider.load();
        provider.add('  Riso  ');
        expect(provider.items.first.name, 'Riso');
      });
    });

    group('toggle()', () {
      test('inverte lo stato checked', () async {
        final provider = ShoppingListProvider();
        await provider.load();
        provider.add('Riso');
        final id = provider.items.first.id;
        provider.toggle(id);
        expect(provider.items.first.checked, true);
        provider.toggle(id);
        expect(provider.items.first.checked, false);
      });
    });

    group('pendingItems / checkedItems', () {
      test('separano correttamente', () async {
        final provider = ShoppingListProvider();
        await provider.load();
        provider.add('Riso');
        provider.add('Pasta');
        provider.add('Pollo');
        provider.toggle(provider.items[0].id);
        provider.toggle(provider.items[2].id);
        expect(provider.pendingItems.length, 1);
        expect(provider.checkedItems.length, 2);
      });
    });

    group('remove()', () {
      test('elimina per id', () async {
        final provider = ShoppingListProvider();
        await provider.load();
        provider.add('Pollo');
        provider.add('Riso');
        final id = provider.items.first.id;
        provider.remove(id);
        expect(provider.items.length, 1);
        expect(provider.items.first.name, 'Riso');
      });
    });

    group('addAll()', () {
      test('non aggiunge duplicati (case-insensitive)', () async {
        final provider = ShoppingListProvider();
        await provider.load();
        provider.add('Pollo');
        provider.addAll(['pollo', 'Riso', 'RISO', 'Pasta']);
        expect(provider.items.length, 3); // Pollo, Riso, Pasta
      });

      test('ignora elementi già presenti', () async {
        final provider = ShoppingListProvider();
        await provider.load();
        provider.add('Riso');
        provider.addAll(['Riso', 'Pasta']);
        expect(provider.items.length, 2);
      });

      test('aggrega duplicati con quantity', () async {
        final provider = ShoppingListProvider();
        await provider.load();
        provider.addAll(['Zucchine', 'Pollo', 'Zucchine', 'Pollo', 'Pollo']);
        final zucchine = provider.items.firstWhere((i) => i.name.toLowerCase() == 'zucchine');
        final pollo = provider.items.firstWhere((i) => i.name.toLowerCase() == 'pollo');
        expect(zucchine.quantity, 2);
        expect(pollo.quantity, 3);
      });

      test('imposta quantity=1 per elementi non duplicati', () async {
        final provider = ShoppingListProvider();
        await provider.load();
        provider.addAll(['Pasta', 'Riso']);
        for (final item in provider.items) {
          expect(item.quantity, 1);
        }
      });

      test('non aggiunge se tutti già presenti', () async {
        final provider = ShoppingListProvider();
        await provider.load();
        provider.add('Riso');
        provider.addAll(['riso']);
        expect(provider.items.length, 1);
      });
    });

    group('clearAll()', () {
      test('svuota la lista', () async {
        final provider = ShoppingListProvider();
        await provider.load();
        provider.add('Pollo');
        provider.add('Riso');
        provider.clearAll();
        expect(provider.items, isEmpty);
      });
    });

    test('persiste e ricarica i dati', () async {
      final provider1 = ShoppingListProvider();
      await provider1.load();
      provider1.add('Merluzzo');
      await Future.delayed(const Duration(milliseconds: 50));

      final provider2 = ShoppingListProvider();
      await provider2.load();
      expect(provider2.items.first.name, 'Merluzzo');
    });

    test('load gestisce JSON corrotto con lista vuota', () async {
      SharedPreferences.setMockInitialValues({'shopping_list': 'json non valido {'});
      final provider = ShoppingListProvider();
      await provider.load();
      expect(provider.items, isEmpty);
    });
  });
}
