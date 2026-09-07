# Congressional Stock Trading Network 2025

Interactive network analysis of reported 2025 U.S. House public-stock purchases.

The project connects:

- House politicians
- public-stock tickers
- House committees
- House subcommittees

Committee relationships are matched using transaction-date-aware congressional
membership snapshots rather than applying one roster to the entire year.

## What the interactive page includes

The rendered HTML contains four internal sections:

- **Explore** — force-directed stock / politician / committee network
- **About** — data definitions, caveats, and source provenance
- **Methodology** — why the project is constructed the way it is
- **Class Report** — narrated analysis with visible R commands and outputs

Other features include search, reset/recenter controls, committee/subcommittee
drawers, original PTR links, shareable selection state, CSV export, and House
coverage diagnostics.

## Main graph rule

The opening network includes a stock ticker only when at least two different
politicians have accepted 2025 public-stock purchases for that ticker.

This is a display rule. Accepted purchases are not deleted just because a
politician lacks a committee match or because their ticker is purchased by only
one politician.

## Committee matching

The matching rule is Congress-aware:

- Jan. 1–2, 2025 → Dec. 17, 2024 snapshot (118th Congress)
- Jan. 3–20, 2025 → Jan. 21, 2025, the first usable House snapshot of the 119th Congress
- Jan. 21 onward → latest available snapshot on or before the transaction date

Exact snapshot commits are listed in `committee-snapshot-index-2025.csv`.

## Source data

The project uses:

- House Periodic Transaction Report data prepared for this project
- `unitedstates/congress-legislators` for legislator and committee metadata
- exact pinned Git commits for historical committee snapshots

The development fork used while building the committee source work is:

`StrokeOfLuck/congress-legislators`

## Run locally

Open:

`2025_Congressional_Stock_Network.Rmd`

and render it in Positron / RStudio.

Required R packages are listed in `INSTALL_PACKAGES.R`.

The first render needs internet access to retrieve pinned committee snapshots.

## GitHub Pages

This repository includes a GitHub Actions workflow that renders the R Markdown
file and deploys the resulting `index.html` to GitHub Pages on pushes to `main`.

Suggested repository name:

`congressional-stock-network-2025`
