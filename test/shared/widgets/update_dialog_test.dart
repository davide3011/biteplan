import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biteplan/shared/widgets/update_dialog.dart';

import '../../helpers/pump_app.dart';

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.davide.biteplan/launcher'),
      (call) async => null,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.davide.biteplan/launcher'),
      null,
    );
  });

  Future<void> openDialog(WidgetTester tester, String version) async {
    await tester.pumpApp(
      Builder(
        builder: (ctx) => TextButton(
          onPressed: () => showUpdateDialog(ctx, version),
          child: const Text('apri'),
        ),
      ),
    );
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
  }

  testWidgets('mostra il titolo corretto', (tester) async {
    await openDialog(tester, '2.1.0');
    expect(find.text('Aggiornamento disponibile'), findsOneWidget);
  });

  testWidgets('mostra la versione nel contenuto', (tester) async {
    await openDialog(tester, '2.1.0');
    expect(find.textContaining('2.1.0'), findsOneWidget);
  });

  testWidgets('ha i pulsanti Più tardi e Scarica', (tester) async {
    await openDialog(tester, '2.1.0');
    expect(find.text('Più tardi'), findsOneWidget);
    expect(find.text('Scarica'), findsOneWidget);
  });

  testWidgets('Più tardi chiude il dialog', (tester) async {
    await openDialog(tester, '2.1.0');
    await tester.tap(find.text('Più tardi'));
    await tester.pumpAndSettle();
    expect(find.text('Aggiornamento disponibile'), findsNothing);
  });

  testWidgets('Scarica chiude il dialog e chiama il launcher', (tester) async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.davide.biteplan/launcher'),
      (call) async {
        calls.add(call);
        return null;
      },
    );

    await openDialog(tester, '2.1.0');
    await tester.tap(find.text('Scarica'));
    await tester.pumpAndSettle();

    expect(find.text('Aggiornamento disponibile'), findsNothing);
    expect(calls, hasLength(1));
    expect(calls.first.method, 'launch');
    expect(calls.first.arguments['url'],
        contains('github.com/davide3011/biteplan'));
  });
}
