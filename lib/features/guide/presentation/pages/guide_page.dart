import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Guida'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Pasti'),
              Tab(text: 'Converti'),
              Tab(text: 'Spesa'),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        body: const TabBarView(
          children: [
            _PastiTab(),
            _ConvertiTab(),
            _SpesaTab(),
          ],
        ),
      ),
    );
  }
}

// ── Pasti ────────────────────────────────────────────────────────────────────

class _PastiTab extends StatelessWidget {
  const _PastiTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _DocCard(
          title: 'Aggiungere un alimento',
          child: _Steps(steps: [
            'Tocca il giorno per espandere la card',
            'Scegli il pasto: Colazione, Pranzo o Cena',
            'Scrivi il nome nel campo di testo',
            'Premi + o Invio per aggiungerlo',
          ]),
        ),
        _TipCard(
          text:
              'Premi "Genera lista della spesa" in fondo alla pagina per importare automaticamente tutti gli alimenti della settimana, senza duplicati.',
        ),
        _DocCard(
          title: 'Rimuovere un alimento',
          child: _Body(
              text:
                  'Tocca il pulsante × a destra dell\'elemento per eliminarlo.'),
        ),
        _DocCard(
          title: 'Salvataggio automatico',
          child: _Body(
              text:
                  'I dati vengono salvati automaticamente sul dispositivo. Non serve premere nessun tasto.'),
        ),
        const _TipCard(
          text:
              'Ad ogni avvio l\'app controlla automaticamente se è disponibile una nuova versione. Se sì, compare un avviso con il pulsante "Scarica" per scaricare l\'aggiornamento.',
        ),
      ],
    );
  }
}

// ── Converti ─────────────────────────────────────────────────────────────────

class _ConvertiTab extends StatelessWidget {
  const _ConvertiTab();

  static const _categories = [
    ('Cereali e pasta', 'Riso (4 varietà), pasta, farro, orzo, quinoa, cous cous'),
    ('Legumi secchi', 'Ceci, fagioli, lenticchie'),
    ('Verdure', 'Carote, zucchine, patate, spinaci, broccoli, asparagi e altri'),
    ('Carni', 'Pollo petto, tacchino fesa, hamburger, vitello'),
    ('Pesce', 'Tonno, merluzzo, spigola, sogliola'),
    ('Uova', 'Uovo al tegamino, frittata'),
  ];

  static const _methods = ['Bollitura', 'Padella', 'Forno', 'Friggitrice ad aria'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _DocCard(
          title: 'Come usarlo',
          child: _Steps(steps: [
            'Cerca l\'alimento nel campo (es. pollo, riso)',
            'Seleziona il metodo di cottura dall\'elenco',
            'Inserisci il peso in grammi',
            'Il risultato appare in tempo reale',
            'Premi il pulsante "Cambia" per invertire crudo / cotto',
          ]),
        ),
        _DocCard(
          title: 'Alimenti disponibili',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: _categories.indexed.map((entry) {
                    final (i, cat) = entry;
                    return Container(
                      decoration: BoxDecoration(
                        border: i < _categories.length - 1
                            ? Border(
                                bottom: BorderSide(color: scheme.outlineVariant))
                            : null,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(cat.$1,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(cat.$2,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.onSurfaceVariant)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _methods
                    .map((m) => Chip(
                          label: Text(m,
                              style: const TextStyle(fontSize: 12)),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Spesa ─────────────────────────────────────────────────────────────────────

class _SpesaTab extends StatelessWidget {
  const _SpesaTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _DocCard(
          title: 'Aggiungere un elemento',
          child: _Body(
              text: 'Scrivi il nome nel campo in alto e premi + o Invio.'),
        ),
        _TipCard(
          text:
              'Vai alla tab Pasti e premi "Genera lista della spesa" per importare automaticamente gli alimenti pianificati, senza duplicati.',
        ),
        _DocCard(
          title: 'Spuntare un elemento',
          child: _Body(
              text:
                  'Tocca la casella a sinistra. Gli elementi completati vengono spostati in una sezione separata con testo barrato.'),
        ),
        _DocCard(
          title: 'Rimuovere / svuotare',
          child: _Body(
              text:
                  'Tocca × per rimuovere un singolo elemento, oppure "Svuota lista" in fondo per eliminare tutto (richiede conferma).'),
        ),
      ],
    );
  }
}

// ── Componenti condivisi ──────────────────────────────────────────────────────

class _DocCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _DocCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String text;
  const _TipCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.4),
        border: Border(left: BorderSide(color: scheme.primary, width: 3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: scheme.primary),
              const SizedBox(width: 5),
              Text('SUGGERIMENTO',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                      color: scheme.primary)),
            ],
          ),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  final List<String> steps;
  const _Steps({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.indexed.map((entry) {
        final (i, step) = entry;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text('${i + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(step,
                    style:
                        const TextStyle(fontSize: 14, height: 1.5)),
              )),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Body extends StatelessWidget {
  final String text;
  const _Body({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 14, height: 1.5));
  }
}

// ignore footer version — accessed via kAppVersion constant
String get _footerText => 'BitePlan · v$kAppVersion · $kAppAuthor';
