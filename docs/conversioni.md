# Conversioni crudo/cotto — Fonti e documentazione

## Formula

```
yield = peso_cotto / peso_crudo

peso_cotto = peso_crudo × yield
peso_crudo = peso_cotto / yield
```

Un `yield` > 1 indica assorbimento di acqua (riso, pasta).
Un `yield` < 1 indica perdita di acqua (carne, verdure).

---

## Tabella coefficienti

I coefficienti di resa riportati nelle tabelle seguenti sono stati ricavati dalla banca dati ufficiale [Alimenti & Nutrizione — CREA](https://www.alimentinutrizione.it/presentazione-dati), confrontando i valori nutrizionali degli alimenti nelle rispettive forme crude e cotte. Le tabelle documentano gli alimenti attualmente supportati dall'app, suddivisi per categoria.

> **Nota metodologica — valori derivati da CREA:** per gli alimenti in cui la letteratura grigia non riporta un fattore diretto, il yield è calcolato dalla banca dati CREA come `yield = kcal_crudo ÷ kcal_cotto_bollito`. Il metodo è valido perché la variazione energetica per 100 g riflette esclusivamente la concentrazione o diluizione d'acqua durante la cottura. Per ciascun valore così derivato la fonte riporta i link alle schede CREA crudo e cotto.
>
> **Cottura in padella — metodologia (verdure a foglia e ortaggi):** la banca dati CREA non include dati per la cottura in padella di queste verdure. Come ancoraggio si usa il dato diretto USDA FNDDS per gli spinaci: *"Spinach, fresh, cooked, no added fat"* (fdcId 2709615) — moisture change **−15%** → yield padella = **0.85**, identico al yield bollitura CREA. Per le altre verdure il yield padella è derivato come `yield_bollitura × k`, dove k è un fattore per tipo di vegetale (documentato nella colonna Fonte).

| Alimento | Metodo | Yield | Fonte |
|---|---|---|---|
| Cous cous precotto | Bollitura | 2.25 | [sinu.it](https://sinu.it/wp-content/uploads/2025/01/Standard-Quantitativi-delle-Porzioni.pdf) |
| Farro perlato | Bollitura | 2.28 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Orzo perlato | Bollitura | 2.67 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Quinoa | Bollitura | 3.12 | [sinu.it](https://sinu.it/wp-content/uploads/2025/01/Standard-Quantitativi-delle-Porzioni.pdf) |
| Riso basmati | Bollitura | 3.00 | [sinu.it](https://sinu.it/wp-content/uploads/2025/01/Standard-Quantitativi-delle-Porzioni.pdf) |
| Riso brillato | Bollitura | 2.60 | [sinu.it](https://sinu.it/wp-content/uploads/2025/01/Standard-Quantitativi-delle-Porzioni.pdf) |
| Riso parboiled | Bollitura | 2.36 | [sinu.it](https://sinu.it/wp-content/uploads/2025/01/Standard-Quantitativi-delle-Porzioni.pdf) |
| Riso venere | Bollitura | 2.10 | [sinu.it](https://sinu.it/wp-content/uploads/2025/01/Standard-Quantitativi-delle-Porzioni.pdf) |
| Pasta all'uovo fresca | Bollitura | 1.36 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Pasta all'uovo secca | Bollitura | 2.99 | [sinu.it](https://sinu.it/wp-content/uploads/2025/01/Standard-Quantitativi-delle-Porzioni.pdf) |
| Pasta semola corta | Bollitura | 1.88 | [sinu.it](https://sinu.it/wp-content/uploads/2025/01/Standard-Quantitativi-delle-Porzioni.pdf) |
| Pasta semola lunga | Bollitura | 2.10 | [sinu.it](https://sinu.it/wp-content/uploads/2025/01/Standard-Quantitativi-delle-Porzioni.pdf) |
| Gnocchi di patate | Bollitura | 1.06 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Ceci secchi | Bollitura | 2.90 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Fagioli secchi | Bollitura | 2.30 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Lenticchie secche | Bollitura | 2.47 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Carote | Bollitura | 0.87 | [nutrizionistadoc.it](https://www.nutrizionistadoc.it/wp-content/uploads/2017/09/Tabella-di-conversione-cibi-crudi-e-cotti.pdf) |
| Carote | Forno | 0.80 | derivato: bollitura 0.87 × k=0.92 (radici al forno) |
| Carote (fettine) | Padella | 0.38 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Carote (fettine) | Forno | 0.72 | derivato: padella 0.38 → forno con umidità trattenuta, stima per fettine al forno |
| Cipolle | Bollitura | 0.73 | [nutrizionistadoc.it](https://www.nutrizionistadoc.it/wp-content/uploads/2017/09/Tabella-di-conversione-cibi-crudi-e-cotti.pdf) |
| Cipolle | Forno | 0.65 | derivato: bollitura 0.73 × k=0.89 (bulbi al forno, perdita per evaporazione) |
| Cipolle (cubetti) | Padella | 0.44 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Cipolle (cubetti) | Forno | 0.50 | derivato: padella 0.44 × k=1.14 (forno trattiene più umidità dei cubetti) |
| Melanzane | Forno | 0.42 | derivato da friggitrice 0.37 / 0.92 (pezzi grandi al forno) |
| Melanzane (cubetti) | Padella | 0.80 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Melanzane (cubetti) | Forno | 0.75 | derivato: padella 0.80 × k=0.94 (forno simile a padella per cubetti) |
| Patate | Bollitura | 0.94 | [sinu.it](https://sinu.it/wp-content/uploads/2025/01/Standard-Quantitativi-delle-Porzioni.pdf) |
| Patate | Forno | 0.90 | derivato da friggitrice 0.90 (forno intero = perdita analoga) |
| Patate (spicchi) | Padella | 0.64 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Patate (spicchi) | Forno | 0.63 | derivato: friggitrice 0.60 / 0.92 × 0.92 ≈ padella (forno spicchi simile a padella) |
| Peperoni | Padella | 0.60 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Peperoni | Forno | 0.96 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Verdure miste | Padella | 0.75 | derivato: media verdure miste saltate in padella |
| Verdure miste | Forno | 0.78 | derivato: media verdure miste al forno (umidità trattenuta) |
| Zucchine | Bollitura | 0.90 | [nutrizionistadoc.it](https://www.nutrizionistadoc.it/wp-content/uploads/2017/09/Tabella-di-conversione-cibi-crudi-e-cotti.pdf) |
| Zucchine | Padella | 0.82 | derivato: bollitura 0.90 × k=0.91 (padella pezzi interi/mezzane) |
| Zucchine | Forno | 0.86 | derivato: bollitura 0.90 × k=0.96 (forno trattiene umidità) |
| Zucchine (fettine) | Padella | 0.76 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Zucchine (fettine) | Forno | 0.72 | derivato: padella 0.76 × k=0.95 (forno simile a padella per fettine) |
| Spinaci | Bollitura | 0.85 | [CREA crudo](https://www.alimentinutrizione.it/tabelle-nutrizionali/005700) / [CREA cotto](https://www.alimentinutrizione.it/tabelle-nutrizionali/005705) — 35÷41 kcal |
| Spinaci | Padella | 0.85 | [USDA FNDDS](https://fdc.nal.usda.gov/) fdcId 2709615 — "Spinach, fresh, cooked, no added fat" moisture change −15% |
| Bieta | Bollitura | 0.83 | [CREA crudo](https://www.alimentinutrizione.it/tabelle-nutrizionali/005080) / [CREA cotto](https://www.alimentinutrizione.it/tabelle-nutrizionali/005085) — 15÷18 kcal |
| Bieta | Padella | 0.80 | derivato: bollitura 0.83 × k=0.96 (foglie tenere, perdita aggiuntiva moderata) |
| Broccoli | Bollitura | 0.97 | [CREA crudo](https://www.alimentinutrizione.it/tabelle-nutrizionali/005110) / [CREA cotto](https://www.alimentinutrizione.it/tabelle-nutrizionali/005105) — 33÷34 kcal |
| Broccoli | Padella | 0.89 | derivato: bollitura 0.97 × k=0.92 (crucifere dense, maggiore evaporazione) |
| Broccoli | Forno | 0.90 | derivato: padella 0.89 × k=1.01 (forno trattiene lievemente più umidità) |
| Cavolfiore | Bollitura | 0.97 | [CREA crudo](https://www.alimentinutrizione.it/tabelle-nutrizionali/005160) / [CREA cotto](https://www.alimentinutrizione.it/tabelle-nutrizionali/005165) — 30÷31 kcal |
| Cavolfiore | Padella | 0.89 | derivato: bollitura 0.97 × k=0.92 (crucifere dense, maggiore evaporazione) |
| Cavolfiore | Forno | 0.90 | derivato: padella 0.89 × k=1.01 (forno trattiene lievemente più umidità) |
| Fagiolini | Bollitura | 0.95 | [matematicaincucina.it — INRAN](https://www.matematicaincucina.it/peso-alimenti-crudi-e-cotti-guida-alla-conversione/) |
| Fagiolini | Padella | 0.86 | derivato: bollitura 0.95 × k=0.90 (legumi a baccello) |
| Fagiolini | Forno | 0.88 | derivato: padella 0.86 × k=1.02 (forno trattiene lievemente più umidità) |
| Asparagi | Bollitura | 0.97 | [CREA crudo](https://www.alimentinutrizione.it/tabelle-nutrizionali/005040) / [CREA cotto](https://www.alimentinutrizione.it/tabelle-nutrizionali/005045) — 33÷34 kcal |
| Asparagi | Padella | 0.88 | derivato: bollitura 0.97 × k=0.91 (steli, perdita per calore diretto) |
| Asparagi | Forno | 0.90 | derivato: padella 0.88 × k=1.02 (forno trattiene lievemente più umidità) |
| Carciofi | Bollitura | 0.75 | [CREA crudo](https://www.alimentinutrizione.it/tabelle-nutrizionali/005120) / [CREA cotto](https://www.alimentinutrizione.it/tabelle-nutrizionali/005125) — 33÷44 kcal |
| Carciofi | Padella | 0.66 | derivato: bollitura 0.75 × k=0.88 (struttura densa, perdita consistente) |
| Carciofi | Forno | 0.68 | derivato: padella 0.66 × k=1.03 (forno trattiene umidità per struttura densa) |
| Finocchi | Bollitura | 0.88 | [CREA crudo](https://www.alimentinutrizione.it/tabelle-nutrizionali/005320) / [CREA cotto](https://www.alimentinutrizione.it/tabelle-nutrizionali/005325) — 15÷17 kcal |
| Finocchi | Padella | 0.75 | derivato: bollitura 0.88 × k=0.85 (bulbo aromatico, forte evaporazione) |
| Finocchi | Forno | 0.78 | derivato: padella 0.75 × k=1.04 (forno gratinati, umidità parzialmente trattenuta) |
| Porri | Bollitura | 1.00 | [CREA crudo](https://www.alimentinutrizione.it/tabelle-nutrizionali/005650) / [CREA cotto](https://www.alimentinutrizione.it/tabelle-nutrizionali/005655) — 35÷35 kcal |
| Porri | Padella | 0.80 | derivato: bollitura 1.00 × k=0.80 (allium a stelo, forte perdita per calore secco) |
| Porri | Forno | 0.82 | derivato: padella 0.80 × k=1.03 (forno trattiene leggermente più umidità) |
| Verza | Bollitura | 1.00 | [matematicaincucina.it — INRAN](https://www.matematicaincucina.it/peso-alimenti-crudi-e-cotti-guida-alla-conversione/) |
| Verza | Padella | 0.88 | derivato: bollitura 1.00 × k=0.88 (cavolo foglia) |
| Verza | Forno | 0.90 | derivato: padella 0.88 × k=1.02 (forno intrappola vapore nelle foglie) |
| Cavolo cappuccio | Bollitura | 1.00 | [pinofiore.altervista.org](https://pinofiore.altervista.org/conversione-alimenti.php) |
| Cavolo cappuccio | Padella | 0.92 | derivato: bollitura 1.00 × k=0.92 (cavolo denso, perdita contenuta) |
| Cavolo cappuccio | Forno | 0.88 | derivato: padella 0.92 × k=0.96 (forno con più evaporazione per struttura compatta) |
| Cicoria coltivata | Bollitura | 0.80 | [pinofiore.altervista.org](https://pinofiore.altervista.org/conversione-alimenti.php) |
| Cicoria coltivata | Padella | 0.75 | derivato: bollitura 0.80 × k=0.94 (foglie, leggera perdita aggiuntiva) |
| Cicoria di campo | Bollitura | 1.00 | [CREA crudo](https://www.alimentinutrizione.it/tabelle-nutrizionali/005240) / [CREA cotto](https://www.alimentinutrizione.it/tabelle-nutrizionali/005245) — 17÷17 kcal |
| Cicoria di campo | Padella | 0.88 | derivato: bollitura 1.00 × k=0.88 (foglie selvatiche, analogo a verza) |
| Cavolini di Bruxelles | Bollitura | 0.89 | [CREA crudo](https://www.alimentinutrizione.it/tabelle-nutrizionali/005170) / [CREA cotto](https://www.alimentinutrizione.it/tabelle-nutrizionali/005175) — 47÷53 kcal |
| Cavolini di Bruxelles | Padella | 0.82 | derivato: bollitura 0.89 × k=0.92 (crucifere dense) |
| Cavolini di Bruxelles | Forno | 0.82 | derivato: padella 0.82 × k=1.00 (forno e padella equivalenti per struttura compatta) |
| Rape | Bollitura | 0.92 | [CREA crudo](https://www.alimentinutrizione.it/tabelle-nutrizionali/005660) / [CREA cotto](https://www.alimentinutrizione.it/tabelle-nutrizionali/005665) — 24÷26 kcal |
| Rape | Padella | 0.83 | derivato: bollitura 0.92 × k=0.90 (radici, perdita aggiuntiva per calore diretto) |
| Rape | Forno | 0.85 | derivato: padella 0.83 × k=1.02 (forno trattiene lievemente più umidità) |
| Agretti | Bollitura | 0.88 | [CREA crudo](https://www.alimentinutrizione.it/tabelle-nutrizionali/005010) / [CREA cotto](https://www.alimentinutrizione.it/tabelle-nutrizionali/005025) — 22÷25 kcal |
| Agretti | Padella | 0.80 | derivato: bollitura 0.88 × k=0.91 (steli succulenti) |
| Pollo petto | Bollitura | 0.90 | [nutrizionistadoc.it](https://www.nutrizionistadoc.it/wp-content/uploads/2017/09/Tabella-di-conversione-cibi-crudi-e-cotti.pdf) |
| Pollo petto | Padella | 0.83 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Pollo petto | Forno | 0.67 | [aemmedi.it](https://aemmedi.it/wp-content/uploads/2016/09/04_tabelle-conversioni-crudo-cotto.pdf) |
| Tacchino fesa | Bollitura | 0.94 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Tacchino fesa | Padella | 0.85 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Tacchino fesa | Forno | 0.69 | [aemmedi.it](https://aemmedi.it/wp-content/uploads/2016/09/04_tabelle-conversioni-crudo-cotto.pdf) |
| Hamburger | Padella | 0.90 | [aemmedi.it](https://aemmedi.it/wp-content/uploads/2016/09/04_tabelle-conversioni-crudo-cotto.pdf) |
| Tonno | Padella | 0.78 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |
| Tonno | Forno | 0.74 | [aemmedi.it](https://aemmedi.it/wp-content/uploads/2016/09/04_tabelle-conversioni-crudo-cotto.pdf) |
| Merluzzo | Bollitura | 0.86 | [nutrizionistadoc.it](https://www.nutrizionistadoc.it/wp-content/uploads/2017/09/Tabella-di-conversione-cibi-crudi-e-cotti.pdf) |
| Merluzzo | Forno | 0.70 | [aemmedi.it](https://aemmedi.it/wp-content/uploads/2016/09/04_tabelle-conversioni-crudo-cotto.pdf) |
| Spigola | Bollitura | 0.86 | [nutrizionistadoc.it](https://www.nutrizionistadoc.it/wp-content/uploads/2017/09/Tabella-di-conversione-cibi-crudi-e-cotti.pdf) |
| Spigola | Forno | 0.75 | [aemmedi.it](https://aemmedi.it/wp-content/uploads/2016/09/04_tabelle-conversioni-crudo-cotto.pdf) |
| Uovo al tegamino | Padella | 0.90 | [aemmedi.it](https://aemmedi.it/wp-content/uploads/2016/09/04_tabelle-conversioni-crudo-cotto.pdf) |
| Frittata semplice | Padella | 0.87 | [istitutomuzzone.edu.it](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf) |

---

## Friggitrice ad aria

### Regola adottata (documentata)

Non esistono tabelle ufficiali standardizzate di yield per la friggitrice ad aria. Si adotta quindi una **regola di equivalenza al forno ventilato**, con una **correzione per maggiore disidratazione**:

- Base: `yield_airfryer ≈ yield_forno`
- Correzione: `yield_airfryer = yield_forno × k`
- Coefficiente k:
  - **Carni/Pesce**: k = 0.94 (-6%)
  - **Verdure**: k = 0.92 (-8%)
  - **Tuberi (patate)**: k = 0.94 (-6%)

Motivazione: la friggitrice ad aria usa aria calda ad alta velocità → maggiore evaporazione superficiale rispetto al forno → yield leggermente inferiore.

---

## Tabella — Friggitrice ad aria

| Alimento | Metodo | Yield | Fonte |
|---|---|---|---|
| Pollo petto | Friggitrice ad aria | 0.63 | derivato da forno 0.67 × 0.94 |
| Tacchino fesa | Friggitrice ad aria | 0.65 | derivato da forno 0.69 × 0.94 |
| Vitello magro | Friggitrice ad aria | 0.51 | derivato da forno 0.54 × 0.94 |
| Hamburger | Friggitrice ad aria | 0.85 | derivato da padella/forno medio |
| Tonno | Friggitrice ad aria | 0.70 | derivato da forno 0.74 × 0.94 |
| Merluzzo | Friggitrice ad aria | 0.66 | derivato da forno 0.70 × 0.94 |
| Spigola | Friggitrice ad aria | 0.71 | derivato da forno 0.75 × 0.94 |
| Sogliola | Friggitrice ad aria | 0.66 | derivato da forno 0.70 × 0.94 |
| Carote | Friggitrice ad aria | 0.74 | derivato da forno 0.80 × 0.92 |
| Carote (fettine) | Friggitrice ad aria | 0.66 | derivato da forno 0.72 × 0.92 |
| Cipolle | Friggitrice ad aria | 0.60 | derivato da forno 0.65 × 0.92 |
| Cipolle (cubetti) | Friggitrice ad aria | 0.46 | derivato da forno 0.50 × 0.92 |
| Melanzane | Friggitrice ad aria | 0.37 | derivato da griglia 0.40 × 0.92 |
| Melanzane (cubetti) | Friggitrice ad aria | 0.69 | derivato da forno 0.75 × 0.92 |
| Patate | Friggitrice ad aria | 0.90 | derivato da forno 0.90 × 0.92 ≈ 0.90 (patate intere) |
| Patate (spicchi) | Friggitrice ad aria | 0.60 | derivato da padella 0.64 × 0.94 |
| Peperoni | Friggitrice ad aria | 0.88 | derivato da forno 0.96 × 0.92 |
| Verdure miste | Friggitrice ad aria | 0.60 | media da forno 0.78 × 0.77 (mix secco, forte disidratazione) |
| Zucchine | Friggitrice ad aria | 0.83 | derivato da forno 0.86 × 0.92 ≈ 0.83 (arrotondato) |
| Zucchine (fettine) | Friggitrice ad aria | 0.66 | derivato da forno 0.72 × 0.92 |
| Broccoli | Friggitrice ad aria | 0.83 | derivato da forno 0.90 × 0.92 |
| Cavolfiore | Friggitrice ad aria | 0.83 | derivato da forno 0.90 × 0.92 |
| Fagiolini | Friggitrice ad aria | 0.81 | derivato da forno 0.88 × 0.92 |
| Asparagi | Friggitrice ad aria | 0.83 | derivato da forno 0.90 × 0.92 |
| Carciofi | Friggitrice ad aria | 0.63 | derivato da forno 0.68 × 0.92 |
| Finocchi | Friggitrice ad aria | 0.72 | derivato da forno 0.78 × 0.92 |
| Cavolini di Bruxelles | Friggitrice ad aria | 0.75 | derivato da forno 0.82 × 0.92 |
| Rape | Friggitrice ad aria | 0.78 | derivato da forno 0.85 × 0.92 |

---

## Fonti di riferimento

- **Alimenti & Nutrizione — CREA** (banca dati ufficiale italiana, agg. dic. 2019): [presentazione](https://www.alimentinutrizione.it/presentazione-dati) — [ricerca per alimento](https://www.alimentinutrizione.it/tabelle-nutrizionali/ricerca-per-alimento). Usata per derivare yield da confronto kcal crudo/cotto (metodo documentato nella nota metodologica sopra).
- **SINU — Società Italiana di Nutrizione Umana**: [Standard Quantitativi delle Porzioni](https://sinu.it/wp-content/uploads/2025/01/Standard-Quantitativi-delle-Porzioni.pdf)
- **Istituto Muzzone — Ristorazione Scolastica Piemonte**: [Tabelle conversione crudo-cotto 2024](https://www.istitutomuzzone.edu.it/wp-content/uploads/2024/08/Tabelle-conversione-crudo-cotto-2024.pdf)
- **AMD/AEMMEDI**: [Tabelle conversioni crudo-cotto](https://aemmedi.it/wp-content/uploads/2016/09/04_tabelle-conversioni-crudo-cotto.pdf)
- **Nutrizionistadoc.it**: [Tabella di conversione cibi crudi e cotti](https://www.nutrizionistadoc.it/wp-content/uploads/2017/09/Tabella-di-conversione-cibi-crudi-e-cotti.pdf)
- **Matematica in Cucina** (dati INRAN): [Peso alimenti crudi e cotti — guida alla conversione](https://www.matematicaincucina.it/peso-alimenti-crudi-e-cotti-guida-alla-conversione/)
- **Pinofiore.altervista.org**: [Tabella di conversione del peso da cibo crudo a cotto](https://pinofiore.altervista.org/conversione-alimenti.php)
- **USDA FoodData Central — FNDDS (Food and Nutrient Database for Dietary Studies)**: [fdc.nal.usda.gov](https://fdc.nal.usda.gov/) — usato per il dato diretto di spinaci in padella (fdcId 2709615, moisture change −15%) come ancoraggio metodologico per la derivazione dei yield padella delle verdure.

> I valori presenti nell'app sono medie indicative. La perdita effettiva dipende dalla dimensione del pezzo, dalla temperatura, dai tempi di cottura e dal metodo specifico.

---

## Aggiungere o modificare alimenti

I dati sono definiti in `src/data/conversions.json`. Per aggiungere un nuovo alimento:

```json
"nome-alimento": {
  "metodo": { "yield": 0.XX }
}
```

Il nome e il metodo devono essere in minuscolo. Sono supportati più metodi per lo stesso alimento.
