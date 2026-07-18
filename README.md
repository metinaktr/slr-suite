# SLR Suite

Current version: **2.2.0**

SLR Suite is an RStudio and Quarto workflow for transparent, traceable, and reproducible systematic literature reviews. It connects review protocols, ordered R analysis stages, validation evidence, and manuscript reporting in one versioned project.

## Major improvements since v1.0.0

- Added a portable UTF-8 RStudio project (`slr-suite.Rproj`) and explicit dependencies (`DESCRIPTION`).
- Replaced the stateful launcher with isolated orchestration functions in `R/pipeline.R`.
- Added automated tests and a deterministic validation experiment.
- Added user, architecture, and reproducibility documentation.
- Added a Quarto manuscript whose claims match the current software and validation scope.
- Added CI for R tests, validation artifacts, and Quarto rendering.
- Removed the Windows-incompatible empty path named `data.`.

## Quick start in RStudio

1. Clone this repository and open `slr-suite.Rproj`.
2. Restore the exact dependency set with `install.packages("renv")` and `renv::restore()`.
3. Put an export file in `data/raw/` and review the YAML protocol files in `config/`.
4. Run `source("master_launcher.R")` for the menu, or run the commands below in the Terminal pane.

```sh
Rscript tests/testthat.R
Rscript scripts/quality_gate.R
Rscript scripts/coverage_gate.R
Rscript master_launcher.R validate
Rscript master_launcher.R run
```

## Start SLR Suite on Windows, Linux, and macOS

The same R codebase runs on all three supported operating systems. Windows includes a clickable launcher; Linux and macOS use the platform Terminal or the shared RStudio project.

| Operating system | How to start SLR Suite |
|---|---|
| Windows | Double-click `SLR_Baslat.bat`, then select an option from 1 to 12. The launcher locates `Rscript.exe` automatically when R is installed in its standard location. |
| Linux | Open a Terminal in the repository directory and run `Rscript master_launcher.R run`. |
| macOS | Open Terminal in the repository directory and run `Rscript master_launcher.R run`. |
| Any system with RStudio | Open `slr-suite.Rproj`, then run `source("master_launcher.R")` in the R console to display the interactive menu. |

Before the first run on Linux or macOS, install R and restore the locked dependencies from the repository directory:

```sh
Rscript -e 'install.packages("renv", repos = "https://cloud.r-project.org"); renv::restore()'
```

Linux and macOS do not require a separate edition of SLR Suite or a platform-specific download. The `master_launcher.R` entry point and all analysis modules are shared across platforms. Automated GitHub Actions runs verify the project on Ubuntu, macOS, and Windows; their results are available on the repository's **Actions** page.

The launcher never clears the RStudio global workspace and never installs packages during analysis. Pipeline outcomes are appended to `logs/pipeline_runs.csv`; validation evidence is written to `artifacts/validation/`.

## Software quality evidence

- [Software–documentation traceability](docs/quality/software-documentation-traceability.md)
- [Software quality improvements](docs/quality/software-quality-improvements.md)
- [Release validation report](docs/quality/release-validation.md)
- [Maintenance and release strategy](docs/quality/maintenance-strategy.md)

GitHub Actions validates the locked installation, code quality, tests, bundled example, coverage, and structural evidence on Ubuntu, macOS, and Windows.

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
