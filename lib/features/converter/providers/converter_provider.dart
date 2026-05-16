import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/conversion_entry.dart';

class ConverterProvider extends ChangeNotifier {
  List<ConversionEntry> _db = [];
  List<ConversionEntry> _results = [];
  ConversionEntry? _selected;
  double? _grams;
  bool _rawToCooked = true;

  List<ConversionEntry> get results => _results;
  ConversionEntry? get selected => _selected;
  double? get grams => _grams;
  bool get rawToCooked => _rawToCooked;

  double? get result {
    if (_selected == null || _grams == null || _grams! <= 0) return null;
    final v = _rawToCooked
        ? _selected!.rawToCooked(_grams!)
        : _selected!.cookedToRaw(_grams!);
    return (v * 10).roundToDouble() / 10;
  }

  Future<void> loadDb() async {
    final raw = await rootBundle.loadString('assets/data/conversions.json');
    final Map<String, dynamic> json = jsonDecode(raw);
    _db = [
      for (final food in json.keys)
        for (final method in (json[food] as Map).keys)
          ConversionEntry(
            food: food,
            method: method,
            yieldFactor:
                (json[food][method]['yield'] as num).toDouble(),
          ),
    ];
    notifyListeners();
  }

  void search(String q) {
    if (q.trim().isEmpty) {
      _results = [];
    } else {
      final lower = q.toLowerCase();
      _results = _db.where((e) => e.food.contains(lower)).toList();
    }
    notifyListeners();
  }

  void select(ConversionEntry entry) {
    _selected = entry;
    _results = [];
    _grams = null;
    notifyListeners();
  }

  void setGrams(double? value) {
    _grams = value;
    notifyListeners();
  }

  void swapDirection() {
    _rawToCooked = !_rawToCooked;
    _grams = null;
    notifyListeners();
  }

  void reset() {
    _selected = null;
    _results = [];
    _grams = null;
    _rawToCooked = true;
    notifyListeners();
  }
}
