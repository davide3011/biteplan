import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:biteplan/features/converter/models/conversion_entry.dart';
import 'package:biteplan/features/converter/presentation/pages/converter_page.dart';
import 'package:biteplan/features/converter/providers/converter_provider.dart';
import '../../../helpers/pump_app.dart';

Widget _page(ConverterProvider provider) => ChangeNotifierProvider.value(
      value: provider,
      child: const Scaffold(body: ConverterPage()),
    );

const _riso =
    ConversionEntry(food: 'riso', method: 'bollitura', yieldFactor: 3.0);

void main() {
  late ConverterProvider provider;

  setUp(() {
    provider = ConverterProvider();
  });

  group('ConverterPage — ricerca', () {
    testWidgets('mostra lo stato vuoto iniziale', (tester) async {
      await tester.pumpApp(_page(provider));
      expect(find.text('Cerca un alimento per iniziare'), findsOneWidget);
    });

    testWidgets('la ricerca mostra risultati dal database', (tester) async {
      await provider.loadDb();
      await tester.pumpApp(_page(provider));
      await tester.enterText(find.byType(TextField), 'riso');
      await tester.pump();
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('ricerca senza corrispondenze mostra "Nessun risultato"',
        (tester) async {
      await provider.loadDb();
      await tester.pumpApp(_page(provider));
      await tester.enterText(find.byType(TextField), 'xyzabc');
      await tester.pump();
      expect(find.text('Nessun risultato'), findsOneWidget);
    });

    testWidgets('tap su un risultato apre la card di conversione',
        (tester) async {
      await provider.loadDb();
      await tester.pumpApp(_page(provider));
      await tester.enterText(find.byType(TextField), 'riso');
      await tester.pump();
      await tester.tap(find.byType(ListTile).first);
      await tester.pump();
      expect(find.text('Cambia'), findsOneWidget);
      expect(find.text('CRUDO'), findsOneWidget);
      expect(find.text('COTTO'), findsOneWidget);
    });
  });

  group('ConverterPage — card di conversione', () {
    testWidgets('calcola e mostra il risultato formattato', (tester) async {
      provider.select(_riso);
      await tester.pumpApp(_page(provider));
      await tester.enterText(find.byType(TextField), '100');
      await tester.pump();
      // 100 * 3.0 = 300, intero → senza decimali
      expect(find.text('300'), findsOneWidget);
      expect(find.textContaining('fattore di resa 3.0'), findsOneWidget);
    });

    testWidgets('input non numerico mostra il placeholder —', (tester) async {
      provider.select(_riso);
      await tester.pumpApp(_page(provider));
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('swap inverte la direzione e azzera il risultato',
        (tester) async {
      provider.select(_riso);
      await tester.pumpApp(_page(provider));
      await tester.enterText(find.byType(TextField), '100');
      await tester.pump();
      expect(find.text('300'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pump();
      expect(provider.rawToCooked, isFalse);
      expect(find.text('300'), findsNothing);
    });

    testWidgets('"Cambia" torna alla ricerca', (tester) async {
      provider.select(_riso);
      await tester.pumpApp(_page(provider));
      await tester.tap(find.text('Cambia'));
      await tester.pump();
      expect(find.text('Cerca un alimento per iniziare'), findsOneWidget);
      expect(provider.selected, isNull);
    });
  });
}
