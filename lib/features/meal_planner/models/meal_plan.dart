import 'dart:convert';

class DayPlan {
  final List<String> colazione;
  final List<String> pranzo;
  final List<String> cena;

  DayPlan({
    List<String>? colazione,
    List<String>? pranzo,
    List<String>? cena,
  })  : colazione = colazione ?? [],
        pranzo = pranzo ?? [],
        cena = cena ?? [];

  DayPlan copyWith({
    List<String>? colazione,
    List<String>? pranzo,
    List<String>? cena,
  }) =>
      DayPlan(
        colazione: colazione ?? List.of(this.colazione),
        pranzo: pranzo ?? List.of(this.pranzo),
        cena: cena ?? List.of(this.cena),
      );

  List<String> slot(String name) => switch (name) {
        'colazione' => colazione,
        'pranzo' => pranzo,
        'cena' => cena,
        _ => const [],
      };

  Map<String, dynamic> toJson() => {
        'colazione': colazione,
        'pranzo': pranzo,
        'cena': cena,
      };

  factory DayPlan.fromJson(Map<String, dynamic> json) => DayPlan(
        colazione: List<String>.from(json['colazione'] ?? []),
        pranzo: List<String>.from(json['pranzo'] ?? []),
        cena: List<String>.from(json['cena'] ?? []),
      );
}

class MealPlan {
  final Map<String, DayPlan> days;

  const MealPlan(this.days);

  factory MealPlan.empty(List<String> dayIds) =>
      MealPlan({for (final d in dayIds) d: DayPlan()});

  MealPlan withUpdatedDay(String dayId, DayPlan updated) =>
      MealPlan({...days, dayId: updated});

  bool get hasAnyMeal => days.values.any(
        (d) =>
            d.colazione.isNotEmpty ||
            d.pranzo.isNotEmpty ||
            d.cena.isNotEmpty,
      );

  List<String> get allItems => days.values
      .expand((d) => [...d.colazione, ...d.pranzo, ...d.cena])
      .toList();

  Map<String, dynamic> toJson() =>
      {for (final e in days.entries) e.key: e.value.toJson()};

  factory MealPlan.fromJson(Map<String, dynamic> json) => MealPlan({
        for (final e in json.entries)
          e.key: DayPlan.fromJson(e.value as Map<String, dynamic>),
      });

  String toJsonString() => jsonEncode(toJson());

  factory MealPlan.fromJsonString(String s) =>
      MealPlan.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
