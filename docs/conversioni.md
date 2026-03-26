# Conversioni crudo/cotto — Fonti e documentazione

## Formula

```
yield = peso_cotto / peso_crudo

peso_cotto = peso_crudo × yield
peso_crudo = peso_cotto / yield
```

Un `yield` > 1 indica che l'alimento assorbe acqua durante la cottura (es. riso, pasta).
Un `yield` < 1 indica che l'alimento perde acqua (es. carni, verdure).

---

## Tabella coefficienti

I coefficienti di resa riportati nelle tabelle seguenti sono stati ricavati dalla banca dati ufficiale [Alimenti & Nutrizione — CREA](https://www.alimentinutrizione.it/presentazione-dati), confrontando i valori nutrizionali degli alimenti nelle rispettive forme crude e cotte. Le tabelle documentano gli alimenti attualmente supportati dall'app, suddivisi per categoria.

### Cereali e pasta

| Alimento | Metodo | Yield |
|---|---|---|
| Cous cous | Bollitura | 2.25 |
| Farro | Bollitura | 2.28 |
| Gnocchi di patate | Bollitura | 1.06 |
| Pasta all'uovo fresca | Bollitura | 1.36 |
| Pasta all'uovo secca | Bollitura | 2.99 |
| Pasta di semola corta | Bollitura | 1.88 |
| Pasta di semola lunga | Bollitura | 2.10 |
| Quinoa | Bollitura | 3.12 |
| Ravioli freschi | Bollitura | 1.40 |
| Tortellini freschi | Bollitura | 1.92 |

### Legumi

| Alimento | Metodo | Yield |
|---|---|---|
| Ceci secchi | Bollitura | 2.90 |
| Fagiolini freschi/surgelati | Bollitura | 0.95 |
| Fagiolini secchi | Bollitura | 2.30 |
| Fave fresche/surgelate | Bollitura | 0.80 |
| Lenticchie secche | Bollitura | 2.47 |
| Piselli freschi/surgelati | Bollitura | 0.87 |

### Verdure

| Alimento | Metodo | Yield |
|---|---|---|
| Carote (fettine) | Padella | 0.38 |
| Cipolle (cubetti) | Padella | 0.44 |
| Funghi coltivati pleurotes | Padella | 0.85 |
| Funghi prataioli | Padella | 0.53 |
| Melanzane (cubetti) | Padella | 0.80 |
| Melanzane (fette) | Padella | 0.63 |
| Patate con buccia | Bollitura | 1.00 |
| Patate pelate | Bollitura | 0.87 |
| Patate (spicchi) | Padella | 0.64 |
| Peperoni | Padella | 0.60 |
| Peperoni | Forno | 0.96 |
| Sedano (cubetti) | Padella | 0.32 |
| Zucchine (fettine) | Padella | 0.76 |

### Carne

| Alimento | Metodo | Yield |
|---|---|---|
| Fesa di tacchino | Padella | 0.85 |
| Fesa di tacchino | Forno | 0.69 |
| Fettina vitello/maiale | Padella | 0.74 |
| Fettina vitello/maiale panata | Padella | 0.84 |
| Hamburger | Padella | 0.90 |
| Petto di pollo | Padella | 0.83 |
| Petto di pollo | Forno | 0.67 |

### Pesce

| Alimento | Metodo | Yield |
|---|---|---|
| Cernia | Forno | 0.80 |
| Merluzzo (surgelato) | Forno | 0.70 |
| Tonno (trancio) | Padella | 0.78 |

---

## Fonti di riferimento

I coefficienti sono stati derivati da dati medi di letteratura nutrizionale e banche dati alimentari ufficiali:

- **Alimenti & Nutrizione — CREA**
  Banca dati di composizione degli alimenti per studi epidemiologici in Italia:
  [https://www.alimentinutrizione.it/](https://www.alimentinutrizione.it/)

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
