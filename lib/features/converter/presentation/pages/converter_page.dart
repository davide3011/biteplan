import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/conversion_entry.dart';
import '../../providers/converter_provider.dart';
import '../../../../shared/widgets/empty_state.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final _searchController = TextEditingController();
  final _gramsController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _gramsController.dispose();
    super.dispose();
  }

  void _onSelect(ConversionEntry entry) {
    _searchController.clear();
    _gramsController.clear();
    context.read<ConverterProvider>().select(entry);
  }

  void _onReset() {
    _gramsController.clear();
    context.read<ConverterProvider>().reset();
  }

  void _onSwap() {
    _gramsController.clear();
    context.read<ConverterProvider>().swapDirection();
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ConverterProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 56, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Convertitore',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Calcola il peso cotto dal crudo e viceversa',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              if (provider.selected == null) ...[
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cerca alimento…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ConverterProvider>().search('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) {
                    setState(() {});
                    context.read<ConverterProvider>().search(v);
                  },
                ),
                if (provider.results.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (int i = 0; i < provider.results.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          ListTile(
                            title: Text(
                              _cap(provider.results[i].food),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: Text(
                              _cap(provider.results[i].method),
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.55),
                                fontSize: 13,
                              ),
                            ),
                            onTap: () => _onSelect(provider.results[i]),
                            dense: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (provider.results.isEmpty &&
                    _searchController.text.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: EmptyState(
                      icon: Icons.search,
                      title: 'Cerca un alimento per iniziare',
                      subtitle: 'es. pollo, riso, zucchine',
                    ),
                  ),
                if (provider.results.isEmpty &&
                    _searchController.text.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: EmptyState(
                      icon: Icons.search_off,
                      title: 'Nessun risultato',
                    ),
                  ),
              ],
              if (provider.selected != null)
                _ConverterCard(
                  provider: provider,
                  gramsController: _gramsController,
                  onReset: _onReset,
                  onSwap: _onSwap,
                  onGramsChanged: (v) => context
                      .read<ConverterProvider>()
                      .setGrams(double.tryParse(v)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConverterCard extends StatelessWidget {
  final ConverterProvider provider;
  final TextEditingController gramsController;
  final VoidCallback onReset;
  final VoidCallback onSwap;
  final void Function(String) onGramsChanged;

  const _ConverterCard({
    required this.provider,
    required this.gramsController,
    required this.onReset,
    required this.onSwap,
    required this.onGramsChanged,
  });

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = provider.selected!;
    final result = provider.result;
    final isRtC = provider.rawToCooked;
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        _cap(selected.food),
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text('·',
                          style: TextStyle(
                              color: theme.colorScheme.outline, fontSize: 16)),
                      Text(
                        _cap(selected.method),
                        style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: onReset, child: const Text('Cambia')),
              ],
            ),
          ),
          const Divider(height: 1),

          // Calculator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Input
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRtC ? 'CRUDO' : 'COTTO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: gramsController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style: theme.textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                hintText: '0',
                                border: UnderlineInputBorder(),
                                enabledBorder: UnderlineInputBorder(),
                                focusedBorder: UnderlineInputBorder(),
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: onGramsChanged,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text('g',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(color: muted)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Swap button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: IconButton.outlined(
                    onPressed: onSwap,
                    icon: const Icon(Icons.swap_horiz),
                    style: IconButton.styleFrom(
                        minimumSize: const Size(44, 44)),
                  ),
                ),

                // Output
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRtC ? 'COTTO' : 'CRUDO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text(
                                result != null
                                    ? _formatResult(result)
                                    : '—',
                                style: result != null
                                    ? theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      )
                                    : theme.textTheme.headlineMedium?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.2),
                                        fontWeight: FontWeight.w300,
                                      ),
                              ),
                            ),
                            if (result != null) ...[
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text('g',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(color: muted)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer
          if (result != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Text(
                'fattore di resa ${selected.yieldFactor} · '
                '${isRtC ? 'da mangiare cotti' : 'peso crudo equivalente'}',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  String _formatResult(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();
}
