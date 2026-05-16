import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../../../shared/services/storage_service.dart';
import '../../../core/constants/app_constants.dart';

class ShoppingListProvider extends ChangeNotifier {
  List<ShoppingItem> _items = [];

  List<ShoppingItem> get items => _items;
  List<ShoppingItem> get pendingItems =>
      _items.where((i) => !i.checked).toList();
  List<ShoppingItem> get checkedItems =>
      _items.where((i) => i.checked).toList();

  Future<void> load() async {
    final json = await StorageService.load(kStorageKeyShopping);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        _items = list
            .map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _items = [];
      }
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final json = jsonEncode(_items.map((i) => i.toJson()).toList());
    await StorageService.save(kStorageKeyShopping, json);
  }

  void add(String name) {
    final t = name.trim();
    if (t.isEmpty) return;
    _items = [
      ..._items,
      ShoppingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: t,
      ),
    ];
    notifyListeners();
    _save();
  }

  void addAll(List<String> names) {
    final existing = _items.map((i) => i.name.toLowerCase()).toSet();
    final seen = <String>{};
    final toAdd = <ShoppingItem>[];
    for (final name in names) {
      final key = name.toLowerCase().trim();
      if (key.isNotEmpty && !existing.contains(key) && seen.add(key)) {
        toAdd.add(ShoppingItem(
          id: '${DateTime.now().millisecondsSinceEpoch}_${seen.length}',
          name: name.trim(),
        ));
      }
    }
    if (toAdd.isEmpty) return;
    _items = [..._items, ...toAdd];
    notifyListeners();
    _save();
  }

  void toggle(String id) {
    _items = _items
        .map((i) => i.id == id ? i.copyWith(checked: !i.checked) : i)
        .toList();
    notifyListeners();
    _save();
  }

  void remove(String id) {
    _items = _items.where((i) => i.id != id).toList();
    notifyListeners();
    _save();
  }

  void clearAll() {
    _items = [];
    notifyListeners();
    _save();
  }
}
