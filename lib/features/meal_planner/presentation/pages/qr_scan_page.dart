import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../models/meal_plan.dart';
import '../../providers/meal_planner_provider.dart';
import '../../../../core/constants/app_constants.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool _handled = false;

  void _onDetect(BarcodeCapture capture, BuildContext context) {
    if (_handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    setState(() => _handled = true);

    try {
      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      if (parsed['v'] != 1 || parsed['meals'] is! Map) {
        _showError(context, 'QR non valido: dati non riconosciuti.');
        return;
      }
      final mealsMap = parsed['meals'] as Map<String, dynamic>;
      for (final day in kDayIds) {
        final dayData = mealsMap[day];
        if (dayData is! Map) {
          _showError(context, 'QR non valido: struttura dati errata.');
          return;
        }
        for (final slot in kMealSlots) {
          if (dayData[slot] is! List) {
            _showError(context, 'QR non valido: struttura dati errata.');
            return;
          }
        }
      }

      final plan = MealPlan(Map.fromEntries(
        kDayIds.map((day) {
          final d = mealsMap[day] as Map<String, dynamic>;
          return MapEntry(
            day,
            DayPlan(
              colazione: List<String>.from(d['colazione'] as List),
              pranzo: List<String>.from(d['pranzo'] as List),
              cena: List<String>.from(d['cena'] as List),
            ),
          );
        }),
      ));

      context.read<MealPlannerProvider>().importPlan(plan);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Piano ricevuto!')),
        );
      }
    } catch (_) {
      _showError(context, 'QR non riconosciuto.');
    }
  }

  void _showError(BuildContext context, String msg) {
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Scansiona QR')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) => _onDetect(capture, context),
          ),
          // cornice di mira
          Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: scheme.primary, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0, right: 0,
            child: Text(
              'Inquadra il codice QR dell\'altro dispositivo',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
