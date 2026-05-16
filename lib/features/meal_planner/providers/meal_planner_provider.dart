import 'package:flutter/material.dart';
import '../models/meal_plan.dart';
import '../../../shared/services/storage_service.dart';
import '../../../core/constants/app_constants.dart';

class MealPlannerProvider extends ChangeNotifier {
  MealPlan _plan = MealPlan.empty(kDayIds);

  MealPlan get plan => _plan;

  Future<void> load() async {
    final json = await StorageService.load(kStorageKeyMeals);
    if (json != null) {
      try {
        _plan = MealPlan.fromJsonString(json);
      } catch (_) {
        _plan = MealPlan.empty(kDayIds);
      }
    }
    notifyListeners();
  }

  Future<void> _save() =>
      StorageService.save(kStorageKeyMeals, _plan.toJsonString());

  void addItem(String dayId, String slot, String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    final day = _plan.days[dayId]!;
    final updated = switch (slot) {
      'colazione' => day.copyWith(colazione: [...day.colazione, t]),
      'pranzo' => day.copyWith(pranzo: [...day.pranzo, t]),
      'cena' => day.copyWith(cena: [...day.cena, t]),
      _ => day,
    };
    _plan = _plan.withUpdatedDay(dayId, updated);
    notifyListeners();
    _save();
  }

  void removeItem(String dayId, String slot, int index) {
    final day = _plan.days[dayId]!;
    final updated = switch (slot) {
      'colazione' =>
        day.copyWith(colazione: List.of(day.colazione)..removeAt(index)),
      'pranzo' =>
        day.copyWith(pranzo: List.of(day.pranzo)..removeAt(index)),
      'cena' =>
        day.copyWith(cena: List.of(day.cena)..removeAt(index)),
      _ => day,
    };
    _plan = _plan.withUpdatedDay(dayId, updated);
    notifyListeners();
    _save();
  }

  void clearAll() {
    _plan = MealPlan.empty(kDayIds);
    notifyListeners();
    _save();
  }
}
