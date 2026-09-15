# Changelog

All notable changes to SLR Suite are documented here.

## [2.3.2] - 2026-09-15

- Corrected thematic cut years to avoid duplicate interval boundaries.
- Added proportional two-period Sankey PNG/SVG export and analytical CSV/RDS outputs.
- Propagated real failures; logged single-year input as skipped, not successful.
- Extended instrumented coverage to thematic rendering and skip/continuation cases; core coverage reached 80.77% without lowering the 70% threshold.
- Added explicit macOS XQuartz installation for Cairo SVG export; CI passed on Ubuntu, macOS and Windows.
- Repeated the nine-stage benchmark five times per collection at commit `2e7cd2854c3aef9073e30ac9e813ba2fef97ddca`; all 15 runs and 135 module executions completed successfully with required outputs verified.
- The v2.3.1 tag and archive are unchanged. Benchmark evidence identifies the evaluated source separately from subsequent metadata/documentation commits.

## [2.3.1] - 2026-09-09

### Changed

- Made record-level TCCM classification explicit through a single-record matching contract and a row-preserving classification function.
- Expanded the manuscript listing and user documentation to explain how the YAML dictionary is validated, loaded, and applied to each record.

### Added

- Added regression tests for record independence, multiple labels, unmatched and missing text, and input-output row-count preservation.

## [2.3.0] - 2026-09-08

### Added

- Added configurable YAML-based screening and researcher-editable TCCM dictionaries.
- Added document-type normalization, benchmark protocols, raw run-level benchmark records, and summary evidence.
- Added contribution guidance and user-facing FAQ and troubleshooting documentation.

### Changed

- Standardized remaining executable messages and comments in English.
- Expanded screening tests and quality gates for configurable eligibility rules.
- Refreshed the `renv` lockfile with complete dependency metadata for clean cross-platform restoration.
- Synchronized software version metadata, documentation, validation records, and release links with the evaluated source state.

## [2.2.0] - 2026-07-17

### Added

- Added a bidirectional manuscript–code traceability matrix covering all executable modules.
- Added a software quality improvements summary, release validation report, and maintenance strategy.
- Added Ubuntu, macOS, and Windows validation jobs with per-platform evidence artifacts.
- Added pull-request manuscript and documentation rendering before Pages deployment.

### Changed

- Expanded the manuscript with the complete M1–M9 module inventory, installation contract, typed error behavior, and cross-platform validation method.
- Extended structural validation to cover dependency locking, software metadata, and the complete quality evidence package.

## [2.1.0] - 2026-07-17

### Added

- Locked the complete runtime and quality-tool dependency graph with `renv`.
- Added typed, standardized pipeline errors with preserved parent conditions.
- Added end-to-end orchestration tests, lint checks, and a 70% coverage quality gate.
- Added CodeMeta and structured software metadata.

### Changed

- Strengthened GitHub Actions with pinned R and required Linux system libraries.
- Updated the manuscript and user documentation with reproducibility and quality evidence.

## [2.0.0] - 2026-07-17

### Changed

- Redesigned the project as a portable UTF-8 RStudio workflow.
- Replaced stateful global-environment orchestration with isolated pipeline execution and CSV run logs.
- Declared R dependencies explicitly and removed runtime package installation.
- Rewrote the README and added user, architecture, and reproducibility documentation.
- Added a Quarto manuscript aligned with the implemented software and evidence scope.

### Added

- Automated `testthat` checks and a deterministic structural validation experiment.
- GitHub Actions validation with downloadable evidence artifacts.
- Machine-readable project version in `VERSION`, `DESCRIPTION`, and `CITATION.cff`.

### Fixed

- Removed the Windows-incompatible empty path named `data.`.
- Replaced the hard-coded Windows R installation path with portable `Rscript` discovery.

## [1.0.0]

- Initial public release of SLR Suite.

[2.0.0]: https://github.com/metinaktr/slr-suite/compare/v1.0.0...v2.0.0
[2.1.0]: https://github.com/metinaktr/slr-suite/compare/v2.0.0...v2.1.0
[2.2.0]: https://github.com/metinaktr/slr-suite/compare/v2.1.0...v2.2.0
[2.3.0]: https://github.com/metinaktr/slr-suite/compare/v2.2.0...v2.3.0
[2.3.1]: https://github.com/metinaktr/slr-suite/compare/v2.3.0...v2.3.1
[1.0.0]: https://github.com/metinaktr/slr-suite/releases/tag/v1.0.0
