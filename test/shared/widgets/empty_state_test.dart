import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biteplan/shared/widgets/empty_state.dart';
import '../../helpers/pump_app.dart';

void main() {
  group('EmptyState', () {
    testWidgets('mostra icona e titolo', (tester) async {
      await tester.pumpApp(const Scaffold(
        body: EmptyState(icon: Icons.search, title: 'Nessun elemento'),
      ));
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Nessun elemento'), findsOneWidget);
    });

    testWidgets('mostra il sottotitolo quando presente', (tester) async {
      await tester.pumpApp(const Scaffold(
        body: EmptyState(
          icon: Icons.search,
          title: 'Titolo',
          subtitle: 'Sottotitolo di prova',
        ),
      ));
      expect(find.text('Sottotitolo di prova'), findsOneWidget);
    });

    testWidgets('nessun sottotitolo quando assente', (tester) async {
      await tester.pumpApp(const Scaffold(
        body: EmptyState(icon: Icons.search, title: 'Titolo'),
      ));
      expect(find.byType(Text), findsOneWidget);
    });
  });
}
