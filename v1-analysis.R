# Version 1.0 analytical views. Sourced by the canonical Rmd after data cleaning.
# Binary affiliations prevent repeat records from increasing shared-stock weights.
v1_pairs <- purchases_2025_all %>% distinct(politician_clean, ticker)
v1_matrix <- as.matrix(xtabs(~ politician_clean + ticker, data = v1_pairs))
v1_overlap <- tcrossprod(v1_matrix)
diag(v1_overlap) <- 0
v1_indices <- which(upper.tri(v1_overlap) & v1_overlap > 0, arr.ind = TRUE)
v1_edges <- tibble(
  from = rownames(v1_overlap)[v1_indices[, 1]],
  to = colnames(v1_overlap)[v1_indices[, 2]],
  shared_stocks = as.integer(v1_overlap[v1_indices])
)
v1_members <- all_2025_politician_party %>%
  mutate(
    id = politician_clean, label = politician_clean, group = party,
    full_stock_degree = as.integer(rowSums(v1_matrix)[politician_clean]),
    shared_member_degree = as.integer(rowSums(v1_overlap > 0)[politician_clean]),
    size = 9 + 1.5 * sqrt(full_stock_degree),
    title = paste0('<b>', htmlEscape(politician_clean), '</b><br>', party,
      '<br>Distinct stocks in full accepted dataset: ', full_stock_degree,
      '<br>Members sharing at least one stock: ', shared_member_degree)
  )
v1_stock_sets <- split(v1_pairs$ticker, v1_pairs$politician_clean)
v1_edges$tickers <- vapply(seq_len(nrow(v1_edges)), function(i) {
  paste(sort(intersect(v1_stock_sets[[v1_edges$from[i]]],
    v1_stock_sets[[v1_edges$to[i]]])), collapse = ', ')
}, character(1))
v1_edges <- v1_edges %>% mutate(
  id = paste0('pair_', row_number()), width = 0.6 + log1p(shared_stocks),
  color = 'rgba(90,105,120,0.25)',
  title = paste0('<b>', htmlEscape(from), ' + ', htmlEscape(to), '</b><br>',
    shared_stocks, ' shared stocks<br>', tickers)
)

# Nominal assortativity: r = (trace(e) - sum(a^2)) / (1 - sum(a^2)).
# Undirected edges contribute once in each direction to the mixing matrix.
# Unweighted is primary; shared-ticker weights are a descriptive sensitivity check.
v1_assortativity <- function(weighted = FALSE) {
  parties <- setNames(v1_members$party, v1_members$id)
  levels <- sort(unique(parties[parties != 'Unknown']))
  mix <- matrix(0, length(levels), length(levels), dimnames = list(levels, levels))
  for (i in seq_len(nrow(v1_edges))) {
    a <- parties[[v1_edges$from[i]]]; b <- parties[[v1_edges$to[i]]]
    if (a == 'Unknown' || b == 'Unknown') next
    w <- if (weighted) v1_edges$shared_stocks[i] else 1
    mix[a, b] <- mix[a, b] + w; mix[b, a] <- mix[b, a] + w
  }
  if (sum(mix) == 0) return(NA_real_)
  e <- mix / sum(mix); expected <- sum(rowSums(e)^2)
  if (expected >= 1) return(NA_real_)
  (sum(diag(e)) - expected) / (1 - expected)
}
v1_r <- v1_assortativity(FALSE)
v1_rw <- v1_assortativity(TRUE)
v1_duplicate_excess <- sum(duplicated(df[, names(readr::read_csv(ptr_file, n_max = 0, show_col_types = FALSE))]))
v1_hidden_rows <- nrow(purchases_2025_all) - nrow(purchases_network)
v1_hidden_tickers <- n_distinct(v1_pairs$ticker) - length(keep_tickers)
v1_isolates <- sum(v1_members$shared_member_degree == 0)
v1_early_matches <- sum(purchases_2025_all$transaction_date_parsed >= as.Date('2025-01-03') &
  purchases_2025_all$transaction_date_parsed < as.Date('2025-01-21'))

v1_all_nodes <- bind_rows(
  v1_members %>% transmute(id = paste0('M:', id), label, group, size, title),
  stock_detail_summary %>% transmute(id = paste0('S:', ticker), label = ticker,
    group = 'Stock', size = 7 + sqrt(politician_count),
    title = paste0(htmlEscape(company_name), '<br>', politician_count, ' reporting member(s)'))
)
v1_all_edges <- v1_pairs %>% transmute(from = paste0('M:', politician_clean),
  to = paste0('S:', ticker), color = 'rgba(100,110,120,0.2)', width = 1)

v1_widget <- function(nodes, edges, key) {
  visNetwork(nodes, edges, height = '620px', width = '100%') %>%
    visGroups(groupname = 'Democrat', color = '#2F6FDB', shape = 'dot') %>%
    visGroups(groupname = 'Republican', color = '#D64B4B', shape = 'dot') %>%
    visGroups(groupname = 'Independent', color = '#8A63B8', shape = 'dot') %>%
    visGroups(groupname = 'Unknown', color = '#888888', shape = 'dot') %>%
    visGroups(groupname = 'Stock', color = '#D6B54A', shape = 'diamond') %>%
    visNodes(font = list(size = 12, strokeWidth = 3, strokeColor = '#ffffff')) %>%
    visEdges(smooth = FALSE) %>% visLayout(randomSeed = 42) %>%
    visPhysics(solver = 'forceAtlas2Based',
      forceAtlas2Based = list(avoidOverlap = 1, gravitationalConstant = -70),
      stabilization = list(iterations = 400)) %>%
    visInteraction(hover = TRUE, navigationButtons = FALSE) %>%
    visEvents(
      afterDrawing = sprintf("function(){window.v1Networks=window.v1Networks||{};window.v1Networks['%s']=this;}", key),
      stabilizationIterationsDone = 'function(){this.setOptions({physics:false});this.fit();}',
      click = sprintf("function(p){if(window.v1Inspect)window.v1Inspect('%s',p,this);}", key)
    )
}
v1_member_widget <- v1_widget(v1_members, v1_edges, 'members')
v1_all_widget <- v1_widget(v1_all_nodes, v1_all_edges, 'all')

v1_book <- function(label, page, anchor = '') tags$a(label,
  href = paste0('https://stevemcd1.github.io/introSNA/', page, anchor),
  target = '_blank', rel = 'noopener noreferrer')
v1_caveats <- tags$div(class = 'method-note',
  tags$b('Version 1.0 scope and limits. '),
  paste0('This is a frozen extract of accepted 2025 House public-stock purchase records, not a complete census of trading. ',
    'Owner/spouse/dependent fields are absent, so edges represent member-reported purchases, not necessarily personal decisions. ',
    v1_duplicate_excess, ' excess rows are identical across the retained source columns. They are retained pending original-filing review; ',
    'record counts and summed dollar bounds may therefore be inflated. Binary affiliations and distinct-shared-ticker weights are unchanged by exact repeats. ',
    'Amounts are disclosure bounds, not exact spending, holdings, or profit. ',
    'Two members can purchase on different dates; overlap is not evidence of communication, coordination, influence, or misconduct.'))

v1_panel <- tags$div(id = 'v1Page', class = 'page', style = 'display:none;',
  tags$div(class = 'code-wrap',
    tags$h1('Compare reported purchases · 1.0'),
    tags$p('Which members reported purchases of the same stocks, and how much of that overlap crosses party lines?'),
    tags$p('The member projection keeps all 55 accepted purchasers, including members without a shared-stock connection. ',
      v1_book('Textbook §13.6: Projecting One Mode Networks', 'two_mode.html', '#projecting-one-mode-networks')),
    tags$div(class = 'v1-controls',
      tags$button(id = 'v1MembersBtn', class = 'nav-button active', 'Member overlap'),
      tags$button(id = 'v1AllBtn', class = 'nav-button', 'All member–stock ties'),
      tags$button(id = 'v1FitBtn', class = 'nav-button', 'Fit graph'),
      tags$label('Find member or stock ', tags$input(id = 'v1Search', type = 'search', placeholder = 'Name or ticker')),
      tags$button(id = 'v1FindBtn', class = 'nav-button', 'Find'),
      tags$label(id = 'v1ThresholdLabel', 'Minimum shared stocks ',
        tags$input(id = 'v1Threshold', type = 'number', min = 1,
          max = max(v1_edges$shared_stocks), value = 1, style = 'width:75px;'))
    ),
    tags$p(id = 'v1GraphNote', 'Member overlap: each line represents at least one shared ticker; thicker lines mean more distinct shared tickers. Node size counts all distinct accepted stocks. Red = Republican; blue = Democrat. Click a line to see its shared tickers, or a member to see their accepted stock list. Threshold changes only this display, not the statistics below.'),
    tags$div(id = 'v1MembersGraph', class = 'v1-graph', v1_member_widget),
    tags$div(id = 'v1AllGraph', class = 'v1-graph', style = 'display:none;', v1_all_widget),
    tags$div(id = 'v1Selection', class = 'method-note', role = 'status', 'Select a member or connection to inspect it.'),
    tags$h2('Party mixing in the complete member projection'),
    tags$div(class = 'output-box', sprintf(
      '%s members · %s connected pairs · %s members with no shared ticker. Unweighted party assortativity r = %.3f; shared-ticker-weighted r = %.3f.',
      nrow(v1_members), nrow(v1_edges), v1_isolates, v1_r, v1_rw)),
    tags$p('These descriptive values use all pairs sharing at least one ticker, before the display threshold. ',
      'Positive values indicate more same-party mixing than the edge-endpoint baseline; negative values indicate more cross-party mixing. ',
      'Zero means mixing at that baseline, not necessarily a 50/50 split. Isolates have no edges and do not contribute to mixing. ',
      'Unknown-party endpoints are excluded. No significance test or causal claim is made. Popular stocks and members with many purchases can create substantial overlap. ',
      v1_book('Textbook §8.1: Estimating assortativity', 'assortitivity.html', '#estimating-assortativity')),
    tags$h2('What the original shared-stock display hides'),
    tags$p(sprintf('%s purchase rows and %s single-member tickers are hidden by the shared-stock display rule. All %s accepted purchasers and %s tickers are available in “All member–stock ties.” Nothing is deleted by switching views.',
      v1_hidden_rows, v1_hidden_tickers, nrow(v1_members), ncol(v1_matrix))),
    tags$p('The all-ties view uses one equal-width line per distinct member–ticker affiliation; it does not encode purchase frequency. ',
      'Member size measures full accepted stock degree, stock size counts reporting members. The member-only view is a projection; its centralities must not be interpreted as those of the original two-mode graph. ',
      v1_book('Textbook §§13.1–13.4: Two-mode construction and degree', 'two_mode.html')),
    v1_caveats,
    tags$p('Committees are intentionally excluded from these purchasing comparisons. The original Explore tab retains institutional context. ',
      'Community detection, brokerage, sector exposure, and time-window similarity are future analyses; version 1.0 does not claim to measure them.'),
    tags$p(v1_book('Textbook §4.1: Force-directed layouts', 'graph_layouts.html', '#force-directed-layouts'),
      ' · ', v1_book('Appendix B.3: visNetwork', 'interact_vis.html', '#interactive-visualization-with-visnetwork'),
      '. Layout positions aid exploration; distances are not numerical measures of similarity.'),
    tags$p('Methods reference: Steve McDonald, Tom R. Leppard, Andrew P. Davis, and Aditi Mallavarapu. ',
      tags$i('Introduction to Social Network Analysis'), '. 2026. Sections linked where used.')
  )
)

dir.create('validation', showWarnings = FALSE)
readr::write_csv(v1_edges %>% select(from, to, shared_stocks, tickers), 'validation/member-overlap.csv')
readr::write_csv(v1_members %>% select(id, party, full_stock_degree, shared_member_degree), 'validation/member-metrics.csv')
jsonlite::write_json(list(
  accepted_rows = nrow(purchases_2025_all), displayed_rows = nrow(purchases_network),
  accepted_members = nrow(v1_members), accepted_tickers = ncol(v1_matrix),
  hidden_rows = v1_hidden_rows, hidden_tickers = v1_hidden_tickers,
  projected_edges = nrow(v1_edges), isolates = v1_isolates,
  assortativity = v1_r, weighted_assortativity = v1_rw,
  identical_excess_rows = v1_duplicate_excess,
  early_future_snapshot_rows = v1_early_matches,
  roster_count = nrow(house_roster_2025)
), 'validation/metrics.json', auto_unbox = TRUE, pretty = TRUE, digits = 12)
