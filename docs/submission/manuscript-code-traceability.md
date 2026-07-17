# Manuscript–Code Traceability Matrix

This matrix is the authoritative bidirectional map for SLR Suite v2.1.0. Every executable analysis module is described in the manuscript, and every software claim in the manuscript is linked to an implementation and verification path.

## Executable modules

| Module | Responsibility | Principal input | Principal output | Manuscript location | Verification |
|---|---|---|---|---|---|
| `R/conditions.R` | Typed errors and assertions | Error context | `slr_*` conditions | Software architecture; Error handling | `tests/testthat/test-errors.R` |
| `R/pipeline.R` | Step discovery, isolated execution, logging, orchestration | Project root and ordered steps | Run records and pipeline outputs | Software architecture; Orchestration | Pipeline and E2E tests |
| `scripts/01_acquire_and_dedupe.R` | Import and deduplicate bibliographic records | Raw database export | Cleaned collection | Module inventory M1 | Bundled-data E2E |
| `scripts/02_screening.R` | Apply configured screening workflow | Deduplicated records and criteria | Screened records | Module inventory M2 | Bundled-data E2E |
| `scripts/03_biblio_analysis.R` | Core bibliometric summaries | Screened bibliographic data | Descriptive tables | Module inventory M3 | `test_all.R` |
| `scripts/04_vosviewer_export.R` | Prepare VOSviewer network files | Screened collection | Network exports | Module inventory M4 | Syntax and structural gates |
| `scripts/05_tccm_matrix.R` | Construct TCCM coding matrix | Screened records and dictionaries | TCCM matrix | Module inventory M5 | Syntax and structural gates |
| `scripts/06_thematic_evolution.R` | Analyse thematic change over time | Screened records | Thematic evolution outputs | Module inventory M6 | Syntax and structural gates |
| `scripts/07_citation_impact.R` | Calculate article citation summaries | Screened records | Citation-impact table | Module inventory M7 | Syntax and structural gates |
| `scripts/08_future_agenda_SPAR.R` | Aggregate TCCM evidence into a future-agenda table | TCCM matrix | SPAR agenda table | Module inventory M8 | Syntax and structural gates |
| `scripts/09_prisma_flow.R` | Generate PRISMA flow counts and diagram | Raw/interim/processed counts | PRISMA artifact | Module inventory M9 | Syntax and structural gates |
| `experiments/run_validation.R` | Record deterministic repository invariants and environment | Repository state | CSV checklist and session summary | Experimental validation | Structural validation CI step |

## Manuscript claims

| Manuscript claim | Repository evidence | Automated check |
|---|---|---|
| Exact dependency restoration | `renv.lock`, `.Rprofile`, `renv/` | Clean CI restore on three operating systems |
| Isolated orchestration | `R/pipeline.R` | `test-e2e-orchestration.R` |
| Standard error handling | `R/conditions.R` | `test-errors.R` |
| Code quality gate | `.lintr`, `scripts/quality_gate.R` | CI quality step |
| Core coverage at or above 70% | `scripts/coverage_gate.R` | CI coverage step |
| Bundled example execution | `data/raw/results.txt`, `test_all.R` | CI bundled-data E2E step |
| Reproducibility evidence | `experiments/run_validation.R` | Uploaded per-OS validation artifacts |
| Versioned publication metadata | `VERSION`, `DESCRIPTION`, `CITATION.cff`, `codemeta.json` | Structural validation and metadata parsing |

Changes to a module, public claim, or verification path must update this matrix in the same pull request.
