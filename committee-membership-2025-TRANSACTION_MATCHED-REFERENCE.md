# Transaction-matched committee data: plain-language reference

## The short version

The stock data are filtered **before** committee matching.

That means a politician does **not** need a committee assignment to stay in the
stock dataset. If a politician has an accepted 2025 public-stock purchase but no
committee/subcommittee match for the relevant date, the purchase stays in the
stock analysis. It simply gets no institutional edge.

## Which committee snapshot does a transaction use?

There are three date rules.

### Jan. 1-2, 2025

These two days are still part of the **118th Congress**.

The project uses the **Dec. 17, 2024** committee snapshot, the latest usable
prior-Congress snapshot in the source history.

In the current PTR data, the Jan. 2 accepted purchases are James Comer records.

### Jan. 3-20, 2025

The **119th Congress** begins Jan. 3.

There is a Jan. 17 repository update, but that version of
`committee-membership-current.yaml` contains **no House committee membership
rows**. It is therefore not used for House matching.

The first usable House committee snapshot for the 119th Congress is
**Jan. 21, 2025**. Transactions from Jan. 3 through Jan. 20 use Jan. 21.

### Jan. 21-Dec. 31, 2025

The project uses the **latest available committee snapshot on or before the
transaction date**.

Examples:

- Jan. 2 transaction -> Dec. 17, 2024 snapshot
- Jan. 10 transaction -> Jan. 21, 2025 snapshot
- July 10 transaction -> June 17, 2025 snapshot
- Oct. 5 transaction -> Sept. 11, 2025 snapshot
- Nov. 20 transaction -> Nov. 14, 2025 snapshot

This is closer to the transaction date than applying one committee roster to the
entire year.

## Why it is still snapshot-based

The source does not provide a perfect day-by-day change log for every House
committee assignment.

If a member changes committees between two published snapshots, the project
cannot see the change until the next snapshot records it.

So the method is:

**transaction-date-aware and Congress-aware, but not a perfect daily history.**

## Source

Original dataset:

https://github.com/unitedstates/congress-legislators

Development fork:

https://github.com/StrokeOfLuck/congress-legislators

The exact source dates and Git commit SHAs are in:

`committee-snapshot-index-2025.csv`

The first render creates:

`committee-membership-2025-TRANSACTION_MATCHED.csv`

## 119th-Congress House coverage

The coverage panel now counts House members/delegates whose terms overlap
**Jan. 3 through Dec. 31, 2025**.

This avoids counting outgoing 118th-Congress members who served only Jan. 1-2 as
part of the 119th-Congress coverage denominator.

The coverage categories are:

### In main network

The politician has an accepted 2025 public-stock purchase and at least one
ticker bought by two or more politicians.

### Accepted purchases, outside graph

The politician has accepted 2025 public-stock purchases, but none of their
tickers pass the main graph's 2+ politician display rule.

These people are not missing from the data. They are hidden only for graph
readability.

### No accepted purchase found

This does **not** prove no trading.

Possible explanations include:

- no qualifying public-stock purchase;
- sales only;
- other asset types;
- unresolved or rejected ticker parsing;
- no qualifying PTR filing;
- source/scrape coverage that still needs review.

## Two explicit PTR name fixes

Two accepted purchasers were valid records but did not match the roster cleanly
because their PTR names differ substantially from the roster names:

- `Neal Patrick MD, Facs Dunn` -> `Neal P. Dunn`
- `Peter Allen Stauber` -> `Pete Stauber`

These aliases are now explicit in the R code.

## What an institutional edge means

A politician-to-committee or politician-to-subcommittee edge means that at least
one accepted 2025 purchase was matched to a source snapshot in which that
politician appeared on that institution.

A missing institutional edge does **not** delete or invalidate the stock
purchase.

## What none of this proves

A stock purchase and committee assignment appearing together do not prove
misconduct, influence, coordination, or causation. The network is an exploratory
tool for finding relationships worth checking against original PTR filings and
official committee records.
