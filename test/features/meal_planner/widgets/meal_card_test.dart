import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biteplan/features/meal_planner/presentation/widgets/meal_card.dart';
import 'package:biteplan/features/meal_planner/models/meal_plan.dart';
import '../../../helpers/pump_app.dart';

Widget _card({
  DayPlan? dayPlan,
  bool initiallyExpanded = false,
  void Function(String, String)? onAdd,
  void Function(String, int)? onRemove,
}) =>
    Scaffold(
      body: SingleChildScrollView(
        child: MealCard(
          dayId: 'lunedi',
          dayLabel: 'Lunedì',
          dayPlan: dayPlan ?? DayPlan(),
          initiallyExpanded: initiallyExpanded,
          onAdd: onAdd ?? (_, __) {},
          onRemove: onRemove ?? (_, __) {},
        ),
      ),
    );

void main() {
  group('MealCard', () {
    testWidgets('mostra il nome del giorno', (tester) async {
      await tester.pumpApp(_card());
      expect(find.text('Lunedì'), findsOneWidget);
    });

    testWidgets('mostra il conteggio voci nel sottotitolo', (tester) async {
      await tester.pumpApp(_card(
        dayPlan: DayPlan(colazione: ['latte', 'caffè'], pranzo: ['pasta']),
      ));
      expect(find.text('3 voci'), findsOneWidget);
    });

    testWidgets('usa forma singolare per 1 voce', (tester) async {
      await tester.pumpApp(_card(dayPlan: DayPlan(colazione: ['latte'])));
      expect(find.text('1 voce'), findsOneWidget);
    });

    testWidgets('nessun sottotitolo quando il giorno è vuoto', (tester) async {
      await tester.pumpApp(_card());
      expect(find.text('0 voci'), findsNothing);
      expect(find.text('voce'), findsNothing);
    });

    testWidgets('mostra gli elementi quando espanso', (tester) async {
      await tester.pumpApp(_card(
        dayPlan: DayPlan(colazione: ['latte'], cena: ['pollo al forno']),
        initiallyExpanded: true,
      ));
      await tester.pumpAndSettle();
      expect(find.text('latte'), findsOneWidget);
      expect(find.text('pollo al forno'), findsOneWidget);
    });

    testWidgets('chiama onAdd con slot e testo corretti', (tester) async {
      String? capturedSlot;
      String? capturedText;

      await tester.pumpApp(_card(
        initiallyExpanded: true,
        onAdd: (slot, text) {
          capturedSlot = slot;
          capturedText = text;
        },
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'yogurt');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(capturedSlot, 'colazione');
      expect(capturedText, 'yogurt');
    });

    testWidgets('chiama onRemove quando si preme il pulsante elimina',
        (tester) async {
      String? removedSlot;
      int? removedIndex;

      await tester.pumpApp(_card(
        dayPlan: DayPlan(colazione: ['latte']),
        initiallyExpanded: true,
        onRemove: (slot, index) {
          removedSlot = slot;
          removedIndex = index;
        },
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pump();

      expect(removedSlot, 'colazione');
      expect(removedIndex, 0);
    });
  });
}
