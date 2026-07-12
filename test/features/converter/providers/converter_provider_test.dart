import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biteplan/features/converter/providers/converter_provider.dart';
import 'package:biteplan/features/converter/models/conversion_entry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ConverterProvider', () {
    late ConverterProvider provider;

    setUp(() {
      provider = ConverterProvider();
    });

    group('stato iniziale', () {
      test('results è vuoto', () {
        expect(provider.results, isEmpty);
      });

      test('selected è null', () {
        expect(provider.selected, isNull);
      });

      test('grams è null', () {
        expect(provider.grams, isNull);
      });

      test('rawToCooked è true', () {
        expect(provider.rawToCooked, true);
      });

      test('result è null', () {
        expect(provider.result, isNull);
      });
    });

    group('select()', () {
      const entry = ConversionEntry(food: 'riso', method: 'bollitura', yieldFactor: 3.0);

      test('imposta l\'alimento selezionato', () {
        provider.select(entry);
        expect(provider.selected, entry);
      });

      test('azzera i grammi', () {
        provider.setGrams(100);
        provider.select(entry);
        expect(provider.grams, isNull);
      });

      test('svuota i risultati', () {
        provider.select(entry);
        expect(provider.results, isEmpty);
      });

      test('notifica i listener', () {
        var notified = false;
        provider.addListener(() => notified = true);
        provider.select(entry);
        expect(notified, true);
      });
    });

    group('setGrams()', () {
      test('aggiorna il valore', () {
        provider.setGrams(150.0);
        expect(provider.grams, 150.0);
      });

      test('accetta null', () {
        provider.setGrams(100.0);
        provider.setGrams(null);
        expect(provider.grams, isNull);
      });

      test('notifica i listener', () {
        var notified = false;
        provider.addListener(() => notified = true);
        provider.setGrams(100.0);
        expect(notified, true);
      });
    });

    group('result', () {
      const entry = ConversionEntry(food: 'riso', method: 'bollitura', yieldFactor: 3.0);

      test('null se nessun alimento selezionato', () {
        provider.setGrams(100.0);
        expect(provider.result, isNull);
      });

      test('null se grammi non impostati', () {
        provider.select(entry);
        expect(provider.result, isNull);
      });

      test('null se grammi sono 0', () {
        provider.select(entry);
        provider.setGrams(0.0);
        expect(provider.result, isNull);
      });

      test('null se grammi sono negativi', () {
        provider.select(entry);
        provider.setGrams(-10.0);
        expect(provider.result, isNull);
      });

      test('calcola crudo→cotto', () {
        provider.select(entry);
        provider.setGrams(100.0);
        expect(provider.result, closeTo(300.0, 0.05));
      });

      test('calcola cotto→crudo dopo swapDirection', () {
        provider.select(entry);
        provider.swapDirection();
        provider.setGrams(300.0);
        expect(provider.result, closeTo(100.0, 0.05));
      });

      test('arrotonda a 1 decimale', () {
        const e = ConversionEntry(food: 'pollo', method: 'forno', yieldFactor: 0.67);
        provider.select(e);
        provider.setGrams(33.0);
        // 33 * 0.67 = 22.11 → arrotondato a 22.1
        expect(provider.result, closeTo(22.1, 0.05));
      });
    });

    group('swapDirection()', () {
      test('inverte la direzione', () {
        expect(provider.rawToCooked, true);
        provider.swapDirection();
        expect(provider.rawToCooked, false);
        provider.swapDirection();
        expect(provider.rawToCooked, true);
      });

      test('azzera i grammi', () {
        provider.setGrams(100.0);
        provider.swapDirection();
        expect(provider.grams, isNull);
      });

      test('notifica i listener', () {
        var notified = false;
        provider.addListener(() => notified = true);
        provider.swapDirection();
        expect(notified, true);
      });
    });

    group('reset()', () {
      test('azzera tutti i campi', () {
        provider.select(const ConversionEntry(food: 'riso', method: 'bollitura', yieldFactor: 3.0));
        provider.setGrams(100.0);
        provider.swapDirection();
        provider.reset();
        expect(provider.selected, isNull);
        expect(provider.grams, isNull);
        expect(provider.rawToCooked, true);
        expect(provider.results, isEmpty);
      });

      test('notifica i listener', () {
        var notified = false;
        provider.addListener(() => notified = true);
        provider.reset();
        expect(notified, true);
      });
    });

    group('search()', () {
      test('risultati vuoti con query vuota', () {
        provider.search('');
        expect(provider.results, isEmpty);
      });

      test('risultati vuoti con solo spazi', () {
        provider.search('   ');
        expect(provider.results, isEmpty);
      });

      test('notifica i listener', () {
        var notified = false;
        provider.addListener(() => notified = true);
        provider.search('riso');
        expect(notified, true);
      });
    });

    group('loadDb()', () {
      test('carica il database e la ricerca trova alimenti noti', () async {
        await provider.loadDb();
        provider.search('riso');
        expect(provider.results, isNotEmpty);
        provider.search('pollo');
        expect(provider.results, isNotEmpty);
      });

      test('la ricerca è case-insensitive', () async {
        await provider.loadDb();
        provider.search('RISO');
        expect(provider.results, isNotEmpty);
      });

      test('notifica i listener', () async {
        var notified = false;
        provider.addListener(() => notified = true);
        await provider.loadDb();
        expect(notified, true);
      });
    });
  });

  group('conversions.json', () {
    test('ogni metodo di ogni alimento ha uno yield positivo', () async {
      final raw =
          await rootBundle.loadString('assets/data/conversions.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      expect(json, isNotEmpty);
      json.forEach((food, methods) {
        (methods as Map).forEach((method, data) {
          final yield_ = (data as Map)['yield'];
          expect(yield_, isA<num>(), reason: '$food/$method');
          expect((yield_ as num).toDouble(), greaterThan(0),
              reason: '$food/$method');
        });
      });
    });
  });
}
