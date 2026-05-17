import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/meal_planner_provider.dart';
import '../widgets/meal_card.dart';
import '../widgets/qr_share_sheet.dart';
import '../pages/qr_scan_page.dart';
import '../../../shopping_list/providers/shopping_list_provider.dart';
import '../../../../core/constants/app_constants.dart';

class MealPlannerPage extends StatelessWidget {
  final VoidCallback onGoShopping;

  const MealPlannerPage({super.key, required this.onGoShopping});

  String get _todayId {
    const ids = [
      '',
      'lunedi',
      'martedi',
      'mercoledi',
      'giovedi',
      'venerdi',
      'sabato',
      'domenica',
    ];
    return ids[DateTime.now().weekday];
  }

  String get _todayFormatted {
    final now = DateTime.now();
    const months = [
      'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
      'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
    ];
    const weekdays = [
      '', 'lunedì', 'martedì', 'mercoledì', 'giovedì', 'venerdì', 'sabato', 'domenica',
    ];
    return 'Oggi, ${weekdays[now.weekday]} ${now.day} ${months[now.month - 1]}';
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Svuota piano'),
        content: const Text('Svuotare tutto il piano settimanale?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Svuota'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<MealPlannerProvider>().clearAll();
    }
  }

  void _generateShopping(BuildContext context) {
    final plan = context.read<MealPlannerProvider>().plan;
    context.read<ShoppingListProvider>().addAll(plan.allItems);
    onGoShopping();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<MealPlannerProvider>();
    final todayId = _todayId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 56, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Piano Pasti',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                _todayFormatted,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              for (final dayId in kDayIds)
                MealCard(
                  key: ValueKey(dayId),
                  dayId: dayId,
                  dayLabel: kDayLabels[dayId]!,
                  dayPlan: provider.plan.days[dayId] ??
                      (throw StateError('Day $dayId not found')),
                  initiallyExpanded: dayId == todayId,
                  onAdd: (slot, text) =>
                      context.read<MealPlannerProvider>().addItem(dayId, slot, text),
                  onRemove: (slot, index) =>
                      context.read<MealPlannerProvider>().removeItem(dayId, slot, index),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => _generateShopping(context),
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Genera lista della spesa'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
              if (provider.plan.hasAnyMeal) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _confirmClear(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(
                      color: theme.colorScheme.error.withValues(alpha: 0.4),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Svuota piano'),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: provider.plan.hasAnyMeal
                          ? () => showQrShareSheet(context, provider.plan)
                          : null,
                      icon: const Icon(Icons.qr_code, size: 18),
                      label: const Text('Condividi'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const QrScanPage()),
                      ),
                      icon: const Icon(Icons.qr_code_scanner, size: 18),
                      label: const Text('Ricevi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
