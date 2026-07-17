# Changelog

All notable changes to SLR Suite are documented here.

## [2.1.0] - 2026-07-17

### Added

- Locked the complete runtime and quality-tool dependency graph with `renv`.
- Added typed, standardized pipeline errors with preserved parent conditions.
- Added end-to-end orchestration tests, lint checks, and a 70% coverage quality gate.
- Added CodeMeta and SoftwareX C1-C9 publication metadata.

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
[1.0.0]: https://github.com/metinaktr/slr-suite/releases/tag/v1.0.0
