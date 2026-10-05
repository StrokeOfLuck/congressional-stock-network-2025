# Version 1.0 review branch

This version is an exploratory analysis of a frozen extract, not a certification of complete House trading coverage.

## Defensible claims

- The accepted extract contains 3,179 reported purchase records, 55 members, and 855 tickers.
- A two-mode affiliation represents at least one accepted member-reported stock purchase in calendar 2025.
- The original shared-stock display retains 355 tickers, 45 members, and 1,291 distinct affiliations. It hides 777 records and 500 one-member tickers without deleting them.
- The member projection uses distinct affiliations. Each pair's weight is its number of distinct shared tickers. All 55 purchasers are retained, including 10 isolates.
- Party assortativity is descriptive. The primary statistic weights each connected member pair equally. A separately labeled sensitivity statistic weights pairs by shared tickers. Neither statistic is recomputed when the display threshold changes.
- Committee links are context; they are not included in purchasing-similarity statistics.

## Corrections and limits

- Terms ending January 3, 2025 are excluded from the 119th-Congress roster. A new cache filename prevents stale roster reuse.
- The roster source is pinned December 5, 2025 and is not claimed as independently verified year-end completeness.
- The accepted input remains byte-for-byte unchanged. Its 124 excess identical rows are flagged, not deleted. Original PDFs are needed to distinguish duplicate extraction from legitimate repeated or household transactions.
- Owner, amendment linkage, and original transaction-row identity are absent from this extract. It cannot support personal-decision attribution or definitive duplicate resolution.
- January 3–20 purchases use the later January 21 committee snapshot. This is an approximation, not contemporaneous membership proof.
- Binary ties and shared-ticker weights are unaffected by exact repeated rows. Frequency edges and summed amount bounds can be affected.
- Sales, other asset types, rejected tickers, missing filings, and upstream parsing losses are outside the accepted extract's scope.
- Popular stocks and broad purchasing patterns can create many projected ties. Overlap is not evidence of coordinated trades, influence, insider information, current holdings, or profit.

## Reproduce

Run `Rscript render.R`, then `python3 verify_v1.py`. The latter independently checks counts, projected weight distribution, party mixing, and the corrected roster boundary. Rendering exports inspectable CSVs and JSON under `validation/`.

The branch-only workflow renders `preview/index.html` without deploying GitHub Pages. It does not modify the portfolio or the production network deployment. The preview link uses a third-party HTML preview host and may cache updates briefly.

## Textbook

McDonald, Steve, Tom R. Leppard, Andrew P. Davis, and Aditi Mallavarapu. 2026. *Introduction to Social Network Analysis*. https://stevemcd1.github.io/introSNA/

Sections are linked beside the relevant explanations in the interface: 2.0.1 and 2.1.2 (edge lists and valued ties), 13.1–13.4 (two-mode affiliation and degree), 13.6 (projection), 8.1 (assortativity), 4.1 (layout), and B.3 (visNetwork). Chapter 15 is conceptual context for time-aware institutional matching; this version does not claim a longitudinal network analysis. Communities and roles remain possible extensions, not implemented findings.
