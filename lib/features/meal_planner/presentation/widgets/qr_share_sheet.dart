import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/meal_plan.dart';

const int _kQrMaxBytes = 2953;

void showQrShareSheet(BuildContext context, MealPlan plan) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _QrShareSheet(plan: plan),
  );
}

class _QrShareSheet extends StatelessWidget {
  final MealPlan plan;
  const _QrShareSheet({required this.plan});

  String? _buildPayload() {
    final payload = jsonEncode({'v': 1, 'meals': plan.days.map(
      (k, v) => MapEntry(k, {
        'colazione': v.colazione,
        'pranzo': v.pranzo,
        'cena': v.cena,
      }),
    )});
    if (payload.length > _kQrMaxBytes) return null;
    return payload;
  }

  @override
  Widget build(BuildContext context) {
    final payload = _buildPayload();
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // handle
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Condividi piano',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Fai scansionare questo codice dall\'altro dispositivo',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            if (payload == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Dati troppo grandi per un QR code.\nRiduci il numero di alimenti inseriti.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.error),
                ),
              )
            else
              QrImageView(
                data: payload,
                version: QrVersions.auto,
                size: 260,
                errorCorrectionLevel: QrErrorCorrectLevel.L,
                backgroundColor: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}
