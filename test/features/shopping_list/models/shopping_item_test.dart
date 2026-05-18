import 'package:flutter_test/flutter_test.dart';
import 'package:biteplan/features/shopping_list/models/shopping_item.dart';

void main() {
  group('ShoppingItem', () {
    test('checked è false di default', () {
      final item = ShoppingItem(id: '1', name: 'Pollo');
      expect(item.checked, false);
    });

    test('quantity è 1 di default', () {
      final item = ShoppingItem(id: '1', name: 'Pollo');
      expect(item.quantity, 1);
    });

    test('copyWith() aggiorna solo il campo specificato', () {
      final item = ShoppingItem(id: '1', name: 'Pollo');
      final checked = item.copyWith(checked: true);
      expect(checked.checked, true);
      expect(checked.name, 'Pollo');
      expect(checked.id, '1');
    });

    test('copyWith() aggiorna quantity', () {
      final item = ShoppingItem(id: '1', name: 'Zucchine');
      final updated = item.copyWith(quantity: 3);
      expect(updated.quantity, 3);
      expect(updated.name, 'Zucchine');
    });

    test('copyWith() non modifica lorigine', () {
      final item = ShoppingItem(id: '1', name: 'Pollo');
      item.copyWith(checked: true);
      expect(item.checked, false);
    });

    test('JSON round-trip preserva tutti i campi incluso quantity', () {
      const item = ShoppingItem(id: '42', name: 'Riso', checked: true, quantity: 3);
      final restored = ShoppingItem.fromJson(item.toJson());
      expect(restored.id, '42');
      expect(restored.name, 'Riso');
      expect(restored.checked, true);
      expect(restored.quantity, 3);
    });

    test('fromJson gestisce campo checked assente (default false)', () {
      final item = ShoppingItem.fromJson({'id': '1', 'name': 'Pasta'});
      expect(item.checked, false);
    });

    test('fromJson gestisce campo quantity assente (default 1)', () {
      final item = ShoppingItem.fromJson({'id': '1', 'name': 'Pasta', 'checked': false});
      expect(item.quantity, 1);
    });

    test('toJson produce la mappa corretta con quantity', () {
      const item = ShoppingItem(id: '5', name: 'Zucchine', checked: false, quantity: 2);
      final json = item.toJson();
      expect(json['id'], '5');
      expect(json['name'], 'Zucchine');
      expect(json['checked'], false);
      expect(json['quantity'], 2);
    });
  });
}
