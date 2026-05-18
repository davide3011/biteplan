import 'package:flutter/material.dart';
import '../../models/meal_plan.dart';
import '../../../../core/constants/app_constants.dart';

class MealCard extends StatefulWidget {
  final String dayId;
  final String dayLabel;
  final DayPlan dayPlan;
  final bool initiallyExpanded;
  final void Function(String slot, String text) onAdd;
  final void Function(String slot, int index) onRemove;

  const MealCard({
    super.key,
    required this.dayId,
    required this.dayLabel,
    required this.dayPlan,
    required this.onAdd,
    required this.onRemove,
    this.initiallyExpanded = false,
  });

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  late final Map<String, TextEditingController> _controllers = {
    for (final slot in kMealSlots) slot: TextEditingController(),
  };

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _add(String slot) {
    final text = _controllers[slot]!.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(slot, text);
    _controllers[slot]!.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalItems = widget.dayPlan.colazione.length +
        widget.dayPlan.pranzo.length +
        widget.dayPlan.cena.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: widget.initiallyExpanded,
        title: Text(
          widget.dayLabel,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: totalItems > 0
            ? Text('$totalItems voc${totalItems == 1 ? 'e' : 'i'}')
            : null,
        children: [
          const Divider(height: 1),
          for (final slot in kMealSlots)
            _SlotSection(
              label: kMealSlotLabels[slot]!,
              items: widget.dayPlan.slot(slot),
              controller: _controllers[slot]!,
              onAdd: () => _add(slot),
              onRemove: (i) => widget.onRemove(slot, i),
              isLast: slot == kMealSlots.last,
            ),
        ],
      ),
    );
  }
}

class _SlotSection extends StatelessWidget {
  final String label;
  final List<String> items;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final bool isLast;

  const _SlotSection({
    required this.label,
    required this.items,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
        for (int i = 0; i < items.length; i++)
          _ItemRow(text: items[i], onRemove: () => onRemove(i)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Aggiungi a ${label.toLowerCase()}…',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (_) => onAdd(),
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                height: 44,
                child: FilledButton(
                  onPressed: onAdd,
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Icon(Icons.add, size: 20),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  final String text;
  final VoidCallback onRemove;

  const _ItemRow({required this.text, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 5,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 16),
            visualDensity: VisualDensity.compact,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}
