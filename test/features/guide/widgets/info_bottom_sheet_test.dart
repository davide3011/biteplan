import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biteplan/core/constants/app_constants.dart';
import 'package:biteplan/features/guide/presentation/widgets/info_bottom_sheet.dart';
import '../../../helpers/pump_app.dart';

Future<void> _openSheet(WidgetTester tester) async {
  await tester.pumpApp(Scaffold(
    body: Builder(
      builder: (context) => Center(
        child: FilledButton(
          onPressed: () => showInfoBottomSheet(context),
          child: const Text('apri'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('apri'));
  await tester.pumpAndSettle();
}

void main() {
  group('InfoBottomSheet', () {
    testWidgets('mostra nome app, versione, autore e licenza',
        (tester) async {
      await _openSheet(tester);
      expect(find.text('BitePlan'), findsOneWidget);
      expect(find.text('Versione $kAppVersion'), findsOneWidget);
      expect(find.text('Autore'), findsOneWidget);
      expect(find.text('Licenza'), findsOneWidget);
    });

    testWidgets('"Apri" sulla riga Guida naviga alla GuidePage',
        (tester) async {
      await _openSheet(tester);
      await tester.tap(find.text('Apri'));
      await tester.pumpAndSettle();
      expect(find.text('Aggiungere un alimento'), findsOneWidget);
    });
  });
}
