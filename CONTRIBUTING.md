# Contributing to SLR Suite

Thank you for improving SLR Suite. Contributions should preserve transparent inputs, deterministic outputs, and auditable research decisions.

## Before opening a pull request

1. Create a focused branch from `main`.
2. Restore dependencies with `renv::restore()`.
3. Keep configuration in `config/`; do not hard-code review-specific criteria in executable scripts.
4. Add or update tests for behavioral changes.
5. Run `Rscript tests/testthat.R`, `Rscript scripts/quality_gate.R`, and `Rscript master_launcher.R validate`.
6. Update user-facing documentation and `CHANGELOG.md` when behavior changes.

## Data and reproducibility

Do not commit licensed database exports, personal data, credentials, or undisclosed manual decisions. Test data must be synthetic or redistributable and clearly labelled. New analytical claims require a documented protocol, data provenance, and reproducible outputs.

## Pull request description

Describe the problem, the implemented behavior, affected files, verification commands, and remaining limitations. Confirm that no version tag or release metadata is changed unless the pull request explicitly prepares a release.

## Reporting issues

Include the operating system, R version, command used, and a minimal example. Do not share sensitive or licensed datasets in public issues.
