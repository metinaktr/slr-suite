# Pre-Submission Validation Report

## Scope

This protocol independently checks release v2.2.0 installation, code quality, the bundled example, complete CI-safe workflow, documentation, and reproducibility evidence. It distinguishes software verification from scientific validation of a review corpus.

## Controlled environment

- R: 4.5.1, pinned in GitHub Actions.
- Dependencies: exact records in `renv.lock`; restored with `renv::restore()`/`setup-renv`.
- Operating systems: Ubuntu latest, macOS latest, Windows latest.
- Input: versioned example export at `data/raw/results.txt`.
- Entry points: `tests/testthat.R`, `test_all.R`, and `master_launcher.R validate`.

## Acceptance criteria

| Check | Command/evidence | Acceptance criterion |
|---|---|---|
| Locked installation | `renv::restore()` in a clean CI runner | No unresolved package installation error |
| Static quality | `Rscript scripts/quality_gate.R` | All R files parse; no runtime installation or workspace clearing |
| Unit/orchestration tests | `Rscript tests/testthat.R` | Zero failures and zero unexpected skips |
| Example E2E | `Rscript test_all.R` | Required processed tables are created |
| Core coverage | `Rscript scripts/coverage_gate.R` | At least 70% |
| Repository invariants | `Rscript master_launcher.R validate` | Every declared invariant passes |
| Documentation | Quarto workflow | Manuscript and documentation render successfully |
| Cross-platform result | GitHub Actions matrix | Ubuntu, macOS, and Windows jobs all succeed |

## Recorded results

Local Windows validation on 2026-07-17 passed 12/12 automated tests, the 24-file quality gate, bundled-data E2E execution, all structural checks, and 75.34% core coverage. The first three-platform release-candidate run ([GitHub Actions run 29580303142](https://github.com/metinaktr/slr-suite/actions/runs/29580303142)) passed on macOS (1 min 7 s), Ubuntu (1 min 23 s), and Windows (3 min 3 s). Its per-OS jobs and downloadable `validation-evidence-*` artifacts are the authoritative independent machine record. Quarto rendering is also required on pull requests before merge; deployment steps run only after a successful render on `main`.

## Installation rehearsal

1. Obtain a clean clone or release archive.
2. Open `slr-suite.Rproj` or start a terminal in the project root.
3. Install `renv` once, then run `renv::restore()`.
4. Run the four validation commands in the acceptance table.
5. Confirm artifacts contain a session summary, structural checklist, and coverage value.

## Residual limitations

The bundled data verifies software mechanics, not search completeness, dual-reviewer agreement, coding validity, or the substantive accuracy of bibliometric interpretation. A real submission dataset must be frozen, licensed for use, and independently checked before empirical claims are added.

## Sign-off rule

Submission is blocked if any operating-system job fails, Quarto rendering fails, coverage falls below 70%, the manuscript and traceability matrix diverge, or the release tag does not identify the tested commit.
