#!/usr/bin/env python3
"""Scraper del catalogo prodotti aldi.it -> sqlite (aldi_prodotti.db) + JSON (aldi_prodotti.json).

Uso:
    python3 scrape_aldi.py                 # scraping completo (categorie + elenco prodotti + dettaglio)
    python3 scrape_aldi.py --no-detail      # salta il fetch delle pagine di dettaglio prodotto

Richiede: playwright (pip install playwright), un browser chromium disponibile
(usa /snap/bin/chromium di sistema via executable_path, nessun download extra).
"""
import argparse
import asyncio
import re
import sqlite3
import sys
import time
from pathlib import Path
from urllib.parse import urljoin

from bs4 import BeautifulSoup
from playwright.async_api import async_playwright
from playwright.sync_api import sync_playwright

BASE = "https://www.aldi.it"
UA = ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36")
OUT_DIR = Path(__file__).parent
DELAY = 0.4  # pausa fra le richieste di listing, per non martellare il sito
DETAIL_CONCURRENCY = 8  # pagine di dettaglio in parallelo


def slug_to_label(slug: str) -> str:
    return slug.replace("-", " ").strip().capitalize()


def find_leaf_categories(page) -> list[dict]:
    page.goto(f"{BASE}/prodotti", timeout=30000)
    page.wait_for_load_state("networkidle", timeout=15000)
    soup = BeautifulSoup(page.content(), "html.parser")
    hrefs = sorted({a["href"] for a in soup.find_all("a", href=True)
                    if re.match(r"^/prodotti/.+/k/\d+$", a["href"])})
    paths = [h.split("/k/")[0] for h in hrefs]
    leaves = []
    for h, p in zip(hrefs, paths):
        is_leaf = not any(p2 != p and p2.startswith(p + "/") for p2 in paths)
        if is_leaf:
            slugs = p.strip("/").split("/")[1:]  # rimuove "prodotti"
            leaves.append({
                "url": urljoin(BASE, h),
                "slug_path": "/".join(slugs),
                "breadcrumb": " > ".join(slug_to_label(s) for s in slugs),
                "categoria_slug": slugs[-1],
                "categoria_nome": slug_to_label(slugs[-1]),
            })
    return leaves


def parse_product_tiles(html: str) -> list[dict]:
    soup = BeautifulSoup(html, "html.parser")
    products = []
    for tile_wrap in soup.select('[id^="product-tile-"]'):
        sku = tile_wrap["id"].replace("product-tile-", "")
        tile = tile_wrap.select_one(".product-tile")
        if tile is None:
            continue
        name_el = tile.select_one(".product-tile__name p")
        brand_el = tile.select_one(".product-tile__brandname p")
        price_el = tile.select_one(".base-price__regular span")
        old_price_el = tile.select_one(".base-price__discount-tag__wrapper")
        unit_el = tile.select_one('[data-test="product-tile__unit-of-measurement"]')
        comp_price_el = tile.select_one('[data-test="product-tile__comparison-price"]')
        link_el = tile.select_one("a.product-tile__link")
        img_el = tile.select_one("img")

        products.append({
            "sku": sku,
            "nome": name_el.get_text(strip=True) if name_el else tile.get("title"),
            "marca": brand_el.get_text(strip=True).rstrip(",") if brand_el else None,
            "prezzo_testo": price_el.get_text(strip=True) if price_el else None,
            "prezzo_scontato": bool(old_price_el and old_price_el.get_text(strip=True)),
            "unita_misura": unit_el.get_text(strip=True) if unit_el else None,
            "prezzo_comparativo": comp_price_el.get_text(strip=True) if comp_price_el else None,
            "url_prodotto": urljoin(BASE, link_el["href"]) if link_el else None,
            "immagine_url": img_el["src"] if img_el and img_el.get("src") else None,
        })
    return products


def max_page(html: str) -> int:
    soup = BeautifulSoup(html, "html.parser")
    pages = [int(a.get_text(strip=True)) for a in soup.select(".base-pagination__count")
             if a.get_text(strip=True).isdigit()]
    return max(pages) if pages else 1


def scrape_listing(page, leaves: list[dict]) -> dict:
    """Ritorna {sku: prodotto} con le categorie aggregate."""
    products: dict[str, dict] = {}
    for i, cat in enumerate(leaves, 1):
        print(f"[{i}/{len(leaves)}] {cat['breadcrumb']}", file=sys.stderr)
        page.goto(cat["url"], timeout=30000)
        try:
            page.wait_for_selector('[id^="product-tile-"], .product-listing-viewer', timeout=15000)
        except Exception:
            pass
        html = page.content()
        n_pages = max_page(html)
        all_tiles = parse_product_tiles(html)
        for p in range(2, n_pages + 1):
            time.sleep(DELAY)
            page.goto(f"{cat['url']}?page={p}", timeout=30000)
            page.wait_for_selector('[id^="product-tile-"]', timeout=15000)
            all_tiles.extend(parse_product_tiles(page.content()))

        for t in all_tiles:
            existing = products.get(t["sku"])
            if existing is None:
                t["categorie"] = [{"slug": cat["categoria_slug"], "nome": cat["categoria_nome"],
                                    "breadcrumb": cat["breadcrumb"]}]
                products[t["sku"]] = t
            else:
                if not any(c["slug"] == cat["categoria_slug"] for c in existing["categorie"]):
                    existing["categorie"].append({"slug": cat["categoria_slug"],
                                                    "nome": cat["categoria_nome"],
                                                    "breadcrumb": cat["breadcrumb"]})
        time.sleep(DELAY)
    return products


async def _scrape_detail_one(context, product: dict, sem: asyncio.Semaphore,
                              progress: list, total: int) -> None:
    async with sem:
        page = await context.new_page()
        try:
            await page.goto(product["url_prodotto"], timeout=30000)
            await page.wait_for_load_state("networkidle", timeout=15000)
            soup = BeautifulSoup(await page.content(), "html.parser")
            desc_el = soup.select_one(".product-details__information .show-more__content")
            product["descrizione"] = desc_el.get_text(strip=True) if desc_el else None
        except Exception as e:
            print(f"  errore su {product['url_prodotto']}: {e}", file=sys.stderr)
            product["descrizione"] = None
        finally:
            await page.close()
        progress.append(1)
        print(f"[dettaglio {len(progress)}/{total}] {product['nome']}", file=sys.stderr)


async def scrape_detail_async(products: dict) -> None:
    """Fetch delle pagine di dettaglio in parallelo (DETAIL_CONCURRENCY schede alla volta)."""
    items = [p for p in products.values() if p.get("url_prodotto")]
    sem = asyncio.Semaphore(DETAIL_CONCURRENCY)
    progress: list = []

    async with async_playwright() as pw:
        browser = await pw.chromium.launch(executable_path="/snap/bin/chromium", headless=True,
                                            args=["--no-sandbox", "--disable-gpu"])
        context = await browser.new_context(user_agent=UA)
        await asyncio.gather(*(_scrape_detail_one(context, p, sem, progress, len(items))
                                for p in items))
        await browser.close()


def scrape_detail(products: dict) -> None:
    asyncio.run(scrape_detail_async(products))


def write_sqlite(products: dict, db_path: Path) -> None:
    if db_path.exists():
        db_path.unlink()
    conn = sqlite3.connect(db_path)
    conn.executescript("""
        CREATE TABLE categorie (
            slug TEXT PRIMARY KEY,
            nome TEXT NOT NULL,
            breadcrumb TEXT NOT NULL
        );
        CREATE TABLE prodotti (
            sku TEXT PRIMARY KEY,
            nome TEXT NOT NULL,
            marca TEXT,
            prezzo_testo TEXT,
            prezzo_scontato INTEGER NOT NULL DEFAULT 0,
            unita_misura TEXT,
            prezzo_comparativo TEXT,
            descrizione TEXT,
            immagine_url TEXT,
            url_prodotto TEXT
        );
        CREATE TABLE prodotto_categorie (
            sku TEXT NOT NULL REFERENCES prodotti(sku),
            categoria_slug TEXT NOT NULL REFERENCES categorie(slug),
            PRIMARY KEY (sku, categoria_slug)
        );
        CREATE TABLE metadata (
            chiave TEXT PRIMARY KEY,
            valore TEXT NOT NULL
        );
    """)
    conn.execute("INSERT INTO metadata (chiave, valore) VALUES ('generato_il', ?)",
                 (time.strftime("%Y-%m-%dT%H:%M:%S%z"),))
    conn.execute("INSERT INTO metadata (chiave, valore) VALUES ('fonte', ?)",
                 (f"{BASE}/prodotti",))
    seen_cat = set()
    for p in products.values():
        conn.execute(
            "INSERT INTO prodotti (sku, nome, marca, prezzo_testo, prezzo_scontato, "
            "unita_misura, prezzo_comparativo, descrizione, immagine_url, url_prodotto) "
            "VALUES (?,?,?,?,?,?,?,?,?,?)",
            (p["sku"], p["nome"], p.get("marca"), p.get("prezzo_testo"),
             int(p.get("prezzo_scontato", False)), p.get("unita_misura"),
             p.get("prezzo_comparativo"), p.get("descrizione"), p.get("immagine_url"),
             p.get("url_prodotto")),
        )
        for c in p["categorie"]:
            if c["slug"] not in seen_cat:
                conn.execute("INSERT INTO categorie (slug, nome, breadcrumb) VALUES (?,?,?)",
                             (c["slug"], c["nome"], c["breadcrumb"]))
                seen_cat.add(c["slug"])
            conn.execute("INSERT OR IGNORE INTO prodotto_categorie (sku, categoria_slug) VALUES (?,?)",
                         (p["sku"], c["slug"]))
    conn.commit()
    conn.close()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--no-detail", action="store_true", help="salta il fetch delle pagine di dettaglio")
    args = ap.parse_args()

    with sync_playwright() as pw:
        browser = pw.chromium.launch(executable_path="/snap/bin/chromium", headless=True,
                                      args=["--no-sandbox", "--disable-gpu"])
        page = browser.new_page(user_agent=UA)

        leaves = find_leaf_categories(page)
        print(f"{len(leaves)} categorie foglia trovate", file=sys.stderr)

        products = scrape_listing(page, leaves)
        print(f"{len(products)} prodotti unici trovati", file=sys.stderr)

        browser.close()

    if not args.no_detail:
        scrape_detail(products)  # fase separata: usa l'API async per il fetch in parallelo

    write_sqlite(products, OUT_DIR / "aldi_prodotti.db")
    print("Fatto: aldi_prodotti.db", file=sys.stderr)


if __name__ == "__main__":
    main()
