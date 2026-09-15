# Thematic Sankey regression record

Local Windows test, 15 September 2026, R 4.5.1. A modified development copy ran
the nine-module pipeline once on each of three working input collections.

| Input records | Screened records | Successful modules | Positive thematic flows |
|---|---|---|---|
| 20 | 20 | 9/9 | 2 |
| 208 | 205 | 9/9 | 39 |
| 500 | 490 | 9/9 | 46 |

Required interim outputs and 16 processed files per collection were non-empty.
PNG signatures and SVG path checks passed. Static Sankey images were inspected
for visible ribbons. Rendering preserves the computed lineage-strength weights.
Single-year skipping, invalid-year failure and continuation after skipping were
also checked. Original bibliographic exports were unchanged; BOM removal applied
only to existing working copies. Licensed bibliographic data are not included.

These are development regression results, not measurements from archived v2.3.1.
No repeated runtime/memory benchmark or new Linux/macOS test was performed.
Locale setup warnings and packages built under newer R patch versions occurred
without stopping execution. Technical output verification does not establish
independent scientific classification validity or general scalability.
