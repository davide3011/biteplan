# db_prodotti — catalogo prodotti aldi.it

Dump del catalogo pubblico su [aldi.it/prodotti](https://www.aldi.it/prodotti), raccolto con
uno scraper (`scrape_aldi.py`) perché il sito non espone un'API pubblica ed è protetto da
bot-detection (Akamai) che blocca le richieste HTTP dirette — servono un browser reale
(Playwright + Chromium headless).

**Non fa parte dell'app BitePlan** (non è collegato a `lib/` né alla build Flutter): è un
dataset a sé, generato una tantum, da usare come riferimento offline (es. prezzi/prodotti per
alimentare in futuro il convertitore o la lista spesa).

## File

- `aldi_prodotti.db` — SQLite, tabelle `prodotti`, `categorie`, `prodotto_categorie` (join, un prodotto può comparire in più categorie foglia), `metadata` (data di generazione, fonte). Generato, non versionato (vedi `.gitignore`) — rigenerabile con lo script.
- `scrape_aldi.py` — script di generazione (Playwright + BeautifulSoup)
- `viewer.html` — UI statica per sfogliare il db nel browser (nessun server/dipendenza da installare)

## Schema SQLite

```
prodotti(sku PK, nome, marca, prezzo_testo, prezzo_scontato, unita_misura,
          prezzo_comparativo, descrizione, immagine_url, url_prodotto)
categorie(slug PK, nome, breadcrumb)
prodotto_categorie(sku, categoria_slug)
```

`prezzo_testo` e `prezzo_comparativo` sono stringhe italiane così come mostrate sul sito
(es. `"0,75 €"`, `"(1,50 €/1 kg)"`) — non convertite in numero per evitare ambiguità di
parsing su formati misti (kg/100g/pezzo).

## Copertura e limiti

- **674 prodotti unici**, 90 categorie foglia (su 92 individuate; 2 risultate vuote),
  generato il 2026-09-20. Include sia alimentari sia non-food (abbigliamento, casa, pet
  care, elettronica, ecc.) perché il catalogo online ALDI Italia li espone tutti sotto
  `/prodotti`.
- Il catalogo online ALDI Italia è un **volantino digitale**, non un e-commerce completo:
  le pagine di dettaglio prodotto **non hanno quasi mai** ingredienti, valori nutrizionali o
  codice EAN. Il campo `descrizione` è popolato solo per ~38% dei prodotti (376/674 vuoti),
  più spesso su non-food (taglie, materiali) che su alimentari.
- I prezzi sono uno snapshot del giorno di generazione: ALDI aggiorna il volantino/le offerte
  periodicamente, quindi il dato invecchia — va rigenerato se serve aggiornato.

## Rigenerare il db

```bash
pip install --break-system-packages playwright beautifulsoup4
python3 scrape_aldi.py              # scraping completo (~20-30 min)
python3 scrape_aldi.py --no-detail  # salta il dettaglio prodotto (solo elenco, ~2 min)
```

Usa il Chromium di sistema (`/snap/bin/chromium`) via Playwright, nessun download di
browser aggiuntivo. Include una pausa (`DELAY` in `scrape_aldi.py`) fra le richieste di
listing e fetch in parallelo (`DETAIL_CONCURRENCY = 8`, in `scrape_aldi.py`) per le pagine
di dettaglio, il collo di bottiglia principale.

Ogni run è **riproducibile**: `write_sqlite()` cancella `aldi_prodotti.db` se già esiste
(`db_path.unlink()`) e lo ricrea da zero con lo schema e i dati appena raccolti — nessun
merge/append tra run, il file rispecchia sempre solo l'ultimo scraping. `metadata.generato_il`
viene sovrascritto ad ogni rigenerazione con il timestamp del run corrente.

## Visualizzare il db (`viewer.html`)

Pagina statica (HTML + JS, [sql.js](https://sql.js.org) via CDN) che legge `aldi_prodotti.db`
direttamente nel browser, senza installazione né build:

- tabella con miniatura, nome, marca, prezzo (con eventuale prezzo scontato), formato/unità
  di misura e categorie di appartenenza
- ricerca live per nome/marca
- filtro per categoria (dropdown popolato dalla tabella `categorie`)
- colonne ordinabili al click sull'intestazione (stesso click inverte la direzione)
- riepilogo in testa con data/ora di generazione e fonte, letti da `metadata`

Va **servita via HTTP** (il fetch del `.db` fallisce se apri il file con doppio click /
`file://`, per le restrizioni CORS del browser):

```bash
cd db_prodotti
python3 -m http.server 8000
# poi apri http://localhost:8000/viewer.html
```
