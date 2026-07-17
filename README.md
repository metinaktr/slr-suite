# SLR Suite

Current development version: **2.0.0** (release candidate)

SLR Suite is an RStudio and Quarto workflow for transparent, traceable, and reproducible systematic literature reviews. It connects review protocols, ordered R analysis stages, validation evidence, and manuscript reporting in one versioned project.

## What changed in the E2 redevelopment

- Added a portable UTF-8 RStudio project (`slr-suite.Rproj`) and explicit dependencies (`DESCRIPTION`).
- Replaced the stateful launcher with isolated orchestration functions in `R/pipeline.R`.
- Added automated tests and a deterministic validation experiment.
- Added user, architecture, and reproducibility documentation.
- Added a Quarto manuscript whose claims match the current software and validation scope.
- Added CI for R tests, validation artifacts, and Quarto rendering.
- Removed the Windows-incompatible empty path named `data.`.

## Quick start in RStudio

1. Clone this repository and open `slr-suite.Rproj`.
2. Install the packages declared in `DESCRIPTION`.
3. Put an export file in `data/raw/` and review the YAML protocol files in `config/`.
4. Run `source("master_launcher.R")` for the menu, or run the commands below in the Terminal pane.

```sh
Rscript tests/testthat.R
Rscript master_launcher.R validate
Rscript master_launcher.R run
```

The launcher never clears the RStudio global workspace and never installs packages during analysis. Pipeline outcomes are appended to `logs/pipeline_runs.csv`; validation evidence is written to `artifacts/validation/`.

## Architecture

| Location | Purpose |
|---|---|
| `R/` | Reusable orchestration and path handling |
| `scripts/` | Ordered analysis stages |
| `config/` | Search, screening, and coding protocols |
| `data/` | Raw, interim, and processed evidence |
| `tests/` | Automated regression checks |
| `experiments/` | Reproducibility validation |
| `docs/` | User documentation and manuscript |

## Scientific scope

SLR Suite supports data preparation and selected bibliometric outputs. It does not replace PRISMA or domain-specific review standards, and it does not validate search completeness, screening reliability, coding validity, or scientific interpretation. Researchers remain responsible for protocol design, screening decisions, synthesis, and conclusions.

## Documentation and paper

The Quarto site under `docs/` contains the [user guide](docs/user-guide.qmd), [architecture](docs/architecture.qmd), [reproducibility protocol](docs/reproducibility.qmd), and [manuscript](docs/paper/manuscript.qmd).

## Citation

Akbulut, M. (2026). *SLR Suite: A reproducible RStudio workflow for systematic literature reviews* [Computer software]. https://github.com/metinaktr/slr-suite

DOI: https://doi.org/10.5281/zenodo.19887817

## License

MIT License. See `LICENSE`.
