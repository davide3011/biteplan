import 'package:flutter_test/flutter_test.dart';
import 'package:biteplan/features/shopping_list/models/shopping_item.dart';

void main() {
  group('ShoppingItem', () {
    test('checked è false di default', () {
      final item = ShoppingItem(id: '1', name: 'Pollo');
      expect(item.checked, false);
    });

    test('copyWith() aggiorna solo il campo specificato', () {
      final item = ShoppingItem(id: '1', name: 'Pollo');
      final checked = item.copyWith(checked: true);
      expect(checked.checked, true);
      expect(checked.name, 'Pollo');
      expect(checked.id, '1');
    });

    test('copyWith() non modifica lorigine', () {
      final item = ShoppingItem(id: '1', name: 'Pollo');
      item.copyWith(checked: true);
      expect(item.checked, false);
    });

    test('JSON round-trip preserva tutti i campi', () {
      const item = ShoppingItem(id: '42', name: 'Riso', checked: true);
      final restored = ShoppingItem.fromJson(item.toJson());
      expect(restored.id, '42');
      expect(restored.name, 'Riso');
      expect(restored.checked, true);
    });

    test('fromJson gestisce campo checked assente (default false)', () {
      final item = ShoppingItem.fromJson({'id': '1', 'name': 'Pasta'});
      expect(item.checked, false);
    });

    test('toJson produce la mappa corretta', () {
      const item = ShoppingItem(id: '5', name: 'Zucchine', checked: false);
      final json = item.toJson();
      expect(json['id'], '5');
      expect(json['name'], 'Zucchine');
      expect(json['checked'], false);
    });
  });
}
