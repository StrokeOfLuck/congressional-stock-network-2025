# 2025 Congressional Stock Trading Network — v1.0 final candidate

## Render

Open and render:

`2025_Congressional_Stock_Network.Rmd`

That single rendered HTML now contains four internal pages:

- Explore
- About
- Method + R Code
- Class Report

The **Class Report** button stays inside the same HTML. It presents the
title/name/date, narration, visible R commands, and real output values in the
course-style format.

The first render still creates the local committee-history and 119th-Congress
roster cache files used by the analysis.

A separate `2025_Congressional_Stock_Network_CLASS_REPORT.Rmd` is kept only as an
optional conventional-R-Markdown backup. You do not need to navigate to a second
HTML for the normal project.

## Corrected committee date logic

Committee matching is now Congress-aware.

- Jan. 1-2, 2025 -> Dec. 17, 2024 snapshot, because Jan. 1-2 are still in the
  118th Congress.
- Jan. 3-20, 2025 -> Jan. 21, 2025, the first usable House committee snapshot
  for the 119th Congress.
- Jan. 21 onward -> latest available snapshot on or before the transaction date.

The Jan. 17 repository update is documented but not used for House matching
because that file contained no House committee membership rows.

See:

`committee-membership-2025-TRANSACTION_MATCHED-REFERENCE.md`

## Stock purchases are not filtered by committee membership

The accepted stock-purchase table is built first.

Committee matching only adds institutional relationships afterward.

If a politician has accepted stock purchases but no committee/subcommittee match
for the selected transaction-date snapshot, the purchases remain in the stock
data. The politician simply receives no institutional edge for those records.

The Explore page now displays a diagnostic count for this.

## Coverage panel correction

The denominator now uses House terms overlapping Jan. 3-Dec. 31, 2025, the
119th-Congress portion of the year.

It no longer counts outgoing 118th-Congress members who served only Jan. 1-2 as
part of the 2025 House coverage denominator.

Two PTR name aliases were also added so valid purchasers are not lost from the
coverage join:

- Neal Patrick MD, Facs Dunn -> Neal P. Dunn
- Peter Allen Stauber -> Pete Stauber

The accepted-purchaser coverage should therefore reconcile to the PTR purchaser
count rather than silently dropping those two names.

## Main graph filter

The main graph still shows only tickers purchased by at least two different
politicians.

That is a display/readability rule, not a data-quality rule.

Accepted purchasers whose tickers are not shared appear in the
`Accepted purchases, outside graph` coverage group.

## Source

Original committee/legislator dataset:

https://github.com/unitedstates/congress-legislators

Development fork:

https://github.com/StrokeOfLuck/congress-legislators

Exact committee source commits:

`committee-snapshot-index-2025.csv`

## Main files

- `2025_Congressional_Stock_Network.Rmd`
- `2025_Congressional_Stock_Network_CLASS_REPORT.Rmd`
- `PTR_transactions_GEOMETRY_V8_2_2021_2026.csv`
- `committee-snapshot-index-2025.csv`
- `committee-membership-2025-TRANSACTION_MATCHED-REFERENCE.md`
- `COURSE_STANDARDS_CHECKLIST.md`
- `legislators-current.csv`
- `legislators-historical.csv`
- `INSTALL_PACKAGES.R`
