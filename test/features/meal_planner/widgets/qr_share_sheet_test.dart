import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:biteplan/core/constants/app_constants.dart';
import 'package:biteplan/features/meal_planner/models/meal_plan.dart';
import 'package:biteplan/features/meal_planner/presentation/widgets/qr_share_sheet.dart';
import '../../../helpers/pump_app.dart';

MealPlan _planWith(Map<String, DayPlan> overrides) => MealPlan({
      ...Map.fromEntries(kDayIds.map((d) => MapEntry(d, DayPlan()))),
      ...overrides,
    });

Future<void> _openSheet(WidgetTester tester, MealPlan plan) async {
  await tester.pumpApp(Scaffold(
    body: Builder(
      builder: (context) => Center(
        child: FilledButton(
          onPressed: () => showQrShareSheet(context, plan),
          child: const Text('apri'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('apri'));
  await tester.pumpAndSettle();
}

void main() {
  group('QrShareSheet', () {
    testWidgets('piano valido mostra il QR code', (tester) async {
      final plan = _planWith({
        'lunedi': DayPlan(pranzo: ['pasta'])
      });
      await _openSheet(tester, plan);
      expect(find.text('Condividi piano'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('piano troppo grande mostra il messaggio di errore',
        (tester) async {
      final plan = _planWith({
        for (final d in kDayIds)
          d: DayPlan(
            colazione: List.generate(
                30, (i) => 'alimento molto lungo numero $i della colazione'),
            pranzo: List.generate(
                30, (i) => 'alimento molto lungo numero $i del pranzo'),
          ),
      });
      await _openSheet(tester, plan);
      expect(find.textContaining('Dati troppo grandi'), findsOneWidget);
      expect(find.byType(QrImageView), findsNothing);
    });

    testWidgets('il pulsante chiudi fa scomparire il foglio', (tester) async {
      final plan = _planWith({
        'lunedi': DayPlan(pranzo: ['pasta'])
      });
      await _openSheet(tester, plan);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Condividi piano'), findsNothing);
    });
  });
}
