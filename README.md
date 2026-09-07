# Congressional Stock Trading Network 2025

Interactive network analysis of reported 2025 U.S. House public-stock purchases.

This repository is intentionally separate from `sean-data-portfolio`. The portfolio repository contains only a lightweight project page and links here. Keeping the analysis, data extract, methodology, and deployment history in their own Git repository reduces coupling and keeps changes to this project from creating technical debt in the website repo.

## Interactive project

The rendered page contains four internal sections:

- **Explore** — force-directed politician / stock / committee network
- **About** — source definitions, provenance, and caveats
- **Methodology** — design and analytical choices
- **Class Report** — narrated R commands and outputs for course-format review

The interface also includes graph search, reset/recenter controls, institution drawers, original PTR links, shareable selections, CSV export, and House coverage diagnostics.

## Analysis input

This repository does **not** duplicate the full 2021–2026 scraper working dataset.

Instead it contains a frozen, analysis-specific extract:

`PTR_transactions_2025_ACCEPTED_STOCK_PURCHASES.csv`

It contains **3,179 accepted 2025 public-stock purchase records** and only the source columns referenced by the visualization. The larger scraping/cleaning pipeline remains a separate data-engineering concern.

This split is deliberate:

- `house-ptr-scraper` owns extraction, parsing, cleaning, and ticker resolution.
- `congressional-stock-network-2025` owns this analysis and visualization.
- `sean-data-portfolio` owns only the portfolio presentation and links.

## Main graph rule

A ticker enters the opening network only when at least two different politicians have accepted 2025 purchases for it.

That is a display rule. Purchases are not removed because a politician lacks a committee match or because their stock is not shared with another politician.

## Committee matching

Committee membership is transaction-date-aware and Congress-aware:

- Jan. 1–2, 2025 → Dec. 17, 2024 snapshot (118th Congress)
- Jan. 3–20, 2025 → Jan. 21, 2025, the first usable 119th-Congress House snapshot
- Jan. 21 onward → latest available snapshot on or before the transaction date

Exact source commits are listed in `committee-snapshot-index-2025.csv`.

Original source:

https://github.com/unitedstates/congress-legislators

Development fork used during source work:

https://github.com/StrokeOfLuck/congress-legislators

## Run locally

Open `2025_Congressional_Stock_Network.Rmd` in Positron / RStudio and render it.

The first render needs internet access because the Rmd downloads exact pinned historical committee and legislator source files. It then caches the flattened tables locally.

Required packages are listed in `INSTALL_PACKAGES.R`.

## GitHub Pages

`.github/workflows/pages.yml` renders the Rmd to `index.html` and deploys it to GitHub Pages whenever `main` is updated.
