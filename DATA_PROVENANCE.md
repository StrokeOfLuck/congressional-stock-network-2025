# Data provenance

## Analysis extract

The visualization reads:

`PTR_transactions_2025_ACCEPTED_STOCK_PURCHASES.csv`

The extract was derived from the V8.2 House PTR output that was originally committed to this repository as blob:

`418f6b6e46674ef944b617f24f7890803c0e7bdc`

The frozen extract keeps only accepted public-stock purchases whose transaction date falls in 2025:

- `transaction_type == "P"`
- `asset_type == "ST"`
- `ticker_parse_status == "accepted"`
- transaction year = 2025

Result: **3,179 purchase records**.

The extract contains only columns referenced by the R analysis:

`filing_id, politician, asset_v8_2_cleaned, ticker_v8_2_cleaned, asset_type, transaction_type, transaction_date, amount_min, amount_max, amount_category, location, page, original_pdf_url, ticker_parse_status`.

The purpose of freezing this smaller input is separation of concerns: the data-engineering pipeline can evolve independently while this visualization remains reproducible against a specific analysis input.

## Committee and legislator metadata

Historical committee snapshots and the House roster are downloaded from exact pinned commits in:

https://github.com/unitedstates/congress-legislators

See `committee-snapshot-index-2025.csv` and `committee-membership-2025-TRANSACTION_MATCHED-REFERENCE.md` for the matching rules and source commits.
