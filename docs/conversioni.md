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

### Proteine animali

| Alimento | Metodo | Yield | Fonte |
|---|---|---|---|
| Pollo | Forno | 0.75 | [da verificare](https://example.com) |
| Pollo | Padella | 0.70 | [da verificare](https://example.com) |
| Manzo | Forno | 0.70 | [da verificare](https://example.com) |
| Manzo | Padella | 0.72 | [da verificare](https://example.com) |
| Maiale | Forno | 0.68 | [da verificare](https://example.com) |
| Maiale | Padella | 0.70 | [da verificare](https://example.com) |
| Salmone | Forno | 0.80 | [da verificare](https://example.com) |
| Salmone | Padella | 0.78 | [da verificare](https://example.com) |
| Tonno | Forno | 0.75 | [da verificare](https://example.com) |
| Uova | Bollite | 0.88 | [da verificare](https://example.com) |

### Carboidrati

| Alimento | Metodo | Yield | Fonte |
|---|---|---|---|
| Riso | Bollito | 2.50 | [da verificare](https://example.com) |
| Pasta | Bollita | 2.20 | [da verificare](https://example.com) |
| Lenticchie | Bollite | 2.30 | [da verificare](https://example.com) |

### Verdure

| Alimento | Metodo | Yield | Fonte |
|---|---|---|---|
| Zucchine | Padella | 0.80 | [da verificare](https://example.com) |
| Zucchine | Bollite | 0.85 | [da verificare](https://example.com) |
| Carote | Bollite | 0.90 | [da verificare](https://example.com) |
| Carote | Forno | 0.85 | [da verificare](https://example.com) |
| Patate | Forno | 0.75 | [da verificare](https://example.com) |
| Patate | Bollite | 0.90 | [da verificare](https://example.com) |
| Spinaci | Padella | 0.35 | [da verificare](https://example.com) |
| Spinaci | Bolliti | 0.30 | [da verificare](https://example.com) |
| Broccoli | Bolliti | 0.85 | [da verificare](https://example.com) |
| Broccoli | Forno | 0.80 | [da verificare](https://example.com) |

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
