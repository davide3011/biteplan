import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shopping_list_provider.dart';
import '../widgets/shopping_item_tile.dart';
import '../../../../shared/widgets/empty_state.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ShoppingListProvider>().add(text);
    _controller.clear();
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Svuota lista'),
        content: const Text('Svuotare tutta la lista della spesa?'),
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
    if (ok == true && mounted) {
      context.read<ShoppingListProvider>().clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ShoppingListProvider>();
    final pending = provider.pendingItems;
    final checked = provider.checkedItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 56, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lista della spesa',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (provider.items.isNotEmpty)
                Text(
                  '${checked.length} / ${provider.items.length} '
                  'completat${checked.length == 1 ? 'o' : 'i'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),

        // Add row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration:
                      const InputDecoration(hintText: 'Aggiungi elemento…'),
                  onSubmitted: (_) => _add(),
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _add,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(52, 52),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),

        Expanded(
          child: provider.items.isEmpty
              ? const EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Lista vuota',
                  subtitle: 'Aggiungi qualcosa con il campo qui sopra.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    // Pending items
                    if (pending.isNotEmpty)
                      Card(
                        margin: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (int i = 0; i < pending.length; i++) ...[
                              if (i > 0)
                                const Divider(
                                    height: 1, indent: 16, endIndent: 16),
                              ShoppingItemTile(
                                item: pending[i],
                                onToggle: () => context
                                    .read<ShoppingListProvider>()
                                    .toggle(pending[i].id),
                                onRemove: () => context
                                    .read<ShoppingListProvider>()
                                    .remove(pending[i].id),
                              ),
                            ],
                          ],
                        ),
                      ),

                    // Checked section
                    if (checked.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Text(
                              'COMPLETATI (${checked.length})',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Divider(
                                color: theme.colorScheme.outline
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (int i = 0; i < checked.length; i++) ...[
                              if (i > 0)
                                const Divider(
                                    height: 1, indent: 16, endIndent: 16),
                              ShoppingItemTile(
                                item: checked[i],
                                onToggle: () => context
                                    .read<ShoppingListProvider>()
                                    .toggle(checked[i].id),
                                onRemove: () => context
                                    .read<ShoppingListProvider>()
                                    .remove(checked[i].id),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _confirmClear,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(
                          color: theme.colorScheme.error.withValues(alpha: 0.4),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Svuota lista'),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
