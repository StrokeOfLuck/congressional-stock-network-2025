"""Independent standard-library verification of the rendered R analysis."""
import csv
import json
import math
from collections import Counter, defaultdict
from itertools import combinations
from pathlib import Path

rows = list(csv.DictReader(open('PTR_transactions_2025_ACCEPTED_STOCK_PURCHASES.csv')))
clean = lambda name: ' '.join(name.split())
# R strips honorifics; mapping to raw names is verified via the same stock sets.
members = list(csv.DictReader(open('validation/member-metrics.csv')))
edges = list(csv.DictReader(open('validation/member-overlap.csv')))
metrics = json.loads(Path('validation/metrics.json').read_text())
stocks = defaultdict(set)
for row in rows:
    stocks[row['ticker_v8_2_cleaned'].strip().upper()].add(row['politician'])
shared = {ticker for ticker, buyers in stocks.items() if len(buyers) >= 2}
raw_sets = defaultdict(set)
for ticker, buyers in stocks.items():
    for buyer in buyers:
        raw_sets[buyer].add(ticker)
expected_weights = Counter()
for buyers in stocks.values():
    for pair in combinations(sorted(buyers), 2):
        expected_weights[pair] += 1
assert metrics['accepted_rows'] == len(rows) == 3179
assert metrics['accepted_members'] == len(raw_sets) == 55
assert metrics['accepted_tickers'] == len(stocks) == 855
assert metrics['displayed_rows'] == sum(r['ticker_v8_2_cleaned'] in shared for r in rows) == 2402
assert metrics['hidden_tickers'] == len(stocks) - len(shared) == 500
assert metrics['identical_excess_rows'] == len(rows) - len({tuple(r.values()) for r in rows}) == 124
assert metrics['projected_edges'] == len(expected_weights) == len(edges)
assert sorted(int(e['shared_stocks']) for e in edges) == sorted(expected_weights.values())
assert sorted(int(m['full_stock_degree']) for m in members) == sorted(map(len, raw_sets.values()))
assert metrics['isolates'] == sum(int(m['shared_member_degree']) == 0 for m in members) == 10
parties = {m['id']: m['party'] for m in members}
for weighted, key in [(False, 'assortativity'), (True, 'weighted_assortativity')]:
    endpoints = Counter(); total = 0; same = 0
    for edge in edges:
        a, b = parties[edge['from']], parties[edge['to']]
        if 'Unknown' in (a, b):
            continue
        w = int(edge['shared_stocks']) if weighted else 1
        endpoints[a] += w; endpoints[b] += w; total += w
        if a == b:
            same += w
    baseline = sum((v / (2 * total)) ** 2 for v in endpoints.values())
    result = (same / total - baseline) / (1 - baseline)
    assert math.isclose(result, metrics[key], abs_tol=1e-10), (key, result, metrics[key])
roster = list(csv.DictReader(open('house-roster-119th-congress-2025-v1.csv')))
assert metrics['roster_count'] == len(roster)
assert all(r['last_2025_term_date'] > '2025-01-03' for r in roster)
assert not any(r['full_name'] == 'Katie Porter' for r in roster)
html = Path('index.html').read_text()
for marker in ['v1Page', 'v1Threshold', 'v1StockSets', 'Compare members',
               'two_mode.html#projecting-one-mode-networks',
               'assortitivity.html#estimating-assortativity']:
    assert marker in html, marker
print(json.dumps(metrics, indent=2))
print('PASS: independent counts, projection weights, both assortativity definitions, roster boundary, and preview content.')
