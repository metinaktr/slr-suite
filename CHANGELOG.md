# Changelog

All notable changes to SLR Suite are documented here.

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
[1.0.0]: https://github.com/metinaktr/slr-suite/releases/tag/v1.0.0
