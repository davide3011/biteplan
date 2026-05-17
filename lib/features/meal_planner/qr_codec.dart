import 'dart:convert';
import 'models/meal_plan.dart';
import '../../core/constants/app_constants.dart';

const int kQrMaxBytes = 2953;

/// Serializza il piano in JSON QR. Restituisce null se supera il limite di byte.
String? buildQrPayload(MealPlan plan) {
  final payload = jsonEncode({
    'v': 1,
    'meals': plan.days.map(
      (k, v) => MapEntry(k, {
        'colazione': v.colazione,
        'pranzo': v.pranzo,
        'cena': v.cena,
      }),
    ),
  });
  if (payload.length > kQrMaxBytes) return null;
  return payload;
}

/// Parsa una stringa QR in MealPlan.
/// Restituisce (plan, null) in caso di successo, (null, messaggio) in caso di errore.
(MealPlan?, String?) parseMealPlanFromQr(String raw) {
  try {
    final parsed = jsonDecode(raw) as Map<String, dynamic>;
    if (parsed['v'] != 1 || parsed['meals'] is! Map) {
      return (null, 'QR non valido: dati non riconosciuti.');
    }
    final mealsMap = parsed['meals'] as Map<String, dynamic>;
    for (final day in kDayIds) {
      final dayData = mealsMap[day];
      if (dayData is! Map) {
        return (null, 'QR non valido: struttura dati errata.');
      }
      for (final slot in kMealSlots) {
        if (dayData[slot] is! List) {
          return (null, 'QR non valido: struttura dati errata.');
        }
      }
    }
    final plan = MealPlan(Map.fromEntries(
      kDayIds.map((day) {
        final d = mealsMap[day] as Map<String, dynamic>;
        return MapEntry(
          day,
          DayPlan(
            colazione: List<String>.from(d['colazione'] as List),
            pranzo: List<String>.from(d['pranzo'] as List),
            cena: List<String>.from(d['cena'] as List),
          ),
        );
      }),
    ));
    return (plan, null);
  } catch (_) {
    return (null, 'QR non riconosciuto.');
  }
}
