import 'package:flutter_test/flutter_test.dart';
import 'package:biteplan/features/converter/models/conversion_entry.dart';

void main() {
  group('ConversionEntry', () {
    test('rawToCooked moltiplica per il fattore di resa', () {
      const entry = ConversionEntry(
        food: 'riso basmati',
        method: 'bollitura',
        yieldFactor: 3.0,
      );
      expect(entry.rawToCooked(100), closeTo(300.0, 0.001));
      expect(entry.rawToCooked(70), closeTo(210.0, 0.001));
    });

    test('cookedToRaw divide per il fattore di resa', () {
      const entry = ConversionEntry(
        food: 'riso basmati',
        method: 'bollitura',
        yieldFactor: 3.0,
      );
      expect(entry.cookedToRaw(300), closeTo(100.0, 0.001));
      expect(entry.cookedToRaw(150), closeTo(50.0, 0.001));
    });

    test('conversione bidirezionale è consistente', () {
      const entry = ConversionEntry(
        food: 'pollo petto',
        method: 'forno',
        yieldFactor: 0.67,
      );
      final cooked = entry.rawToCooked(140);
      final backToRaw = entry.cookedToRaw(cooked);
      expect(backToRaw, closeTo(140, 0.001));
    });

    test('yield > 1: i cereali aumentano di peso con la cottura', () {
      const entry = ConversionEntry(
        food: 'pasta',
        method: 'bollitura',
        yieldFactor: 2.1,
      );
      expect(entry.rawToCooked(80), greaterThan(80));
    });

    test('yield < 1: la carne perde peso con la cottura', () {
      const entry = ConversionEntry(
        food: 'pollo petto',
        method: 'forno',
        yieldFactor: 0.67,
      );
      expect(entry.rawToCooked(100), lessThan(100));
    });

    test('valore limite: 0 grammi restituisce 0', () {
      const entry = ConversionEntry(
        food: 'riso',
        method: 'bollitura',
        yieldFactor: 3.0,
      );
      expect(entry.rawToCooked(0), 0.0);
      expect(entry.cookedToRaw(0), 0.0);
    });
  });
}
