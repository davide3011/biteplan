import 'package:flutter_test/flutter_test.dart';
import 'package:biteplan/features/guide/presentation/pages/guide_page.dart';
import '../../../helpers/pump_app.dart';

void main() {
  group('GuidePage', () {
    testWidgets('mostra titolo e le tre tab', (tester) async {
      await tester.pumpApp(const GuidePage());
      expect(find.text('Guida'), findsOneWidget);
      expect(find.text('Pasti'), findsOneWidget);
      expect(find.text('Converti'), findsOneWidget);
      expect(find.text('Spesa'), findsOneWidget);
    });

    testWidgets('la tab iniziale è Pasti', (tester) async {
      await tester.pumpApp(const GuidePage());
      expect(find.text('Aggiungere un alimento'), findsOneWidget);
    });

    testWidgets('la tab Converti mostra i suoi contenuti', (tester) async {
      await tester.pumpApp(const GuidePage());
      await tester.tap(find.text('Converti'));
      await tester.pumpAndSettle();
      expect(find.text('Come usarlo'), findsOneWidget);
      expect(find.text('Alimenti disponibili'), findsOneWidget);
    });

    testWidgets('la tab Spesa mostra i suoi contenuti', (tester) async {
      await tester.pumpApp(const GuidePage());
      await tester.tap(find.text('Spesa'));
      await tester.pumpAndSettle();
      expect(find.text('Aggiungere un elemento'), findsOneWidget);
      expect(find.text('Spuntare un elemento'), findsOneWidget);
    });
  });
}
