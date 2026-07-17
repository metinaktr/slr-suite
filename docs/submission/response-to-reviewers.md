# Response to the Editor and Reviewers

Manuscript: *SLR Suite: A Reproducible RStudio Workflow for Systematic Literature Reviews*

Software release evaluated: v2.2.0

## E3. Software maturity and SoftwareX standards — Critical

**Comment.** The software must improve code quality, modularity, installation, error handling, and reproducibility.

**Response.** The software now has reusable orchestration and typed condition layers, an exact `renv` dependency lock, documented one-command restoration, unit and end-to-end tests, lint and coverage gates, machine-readable evidence, and cross-platform CI.

**Files/evidence.** `R/pipeline.R`; `R/conditions.R`; `renv.lock`; `docs/user-guide.qmd`; `tests/`; `scripts/quality_gate.R`; `scripts/coverage_gate.R`; `.github/workflows/r-validation.yaml`. Manuscript pp. 2–3, “Software architecture”, “Installation and error handling”, and “Methods”.

## E4. Complete manuscript–repository alignment — Critical

**Comment.** Every manuscript feature must work in GitHub, and every GitHub module must be explained in the paper.

**Response.** A bidirectional traceability matrix maps each orchestration, analysis, validation, and reporting component to manuscript sections and verification evidence. The manuscript now contains an explicit M1–M9 module inventory.

**Files/evidence.** `docs/submission/manuscript-code-traceability.md`; `docs/paper/manuscript.qmd`. Manuscript pp. 2–3, “Software architecture” and “Module inventory”.

## E5. Comprehensive new version and documented changes — High

**Comment.** Raise the software version, apply Semantic Versioning, prepare a changelog, and publish a new release.

**Response.** v2.2.0 is published from the tested `main` commit. Version identifiers are synchronized across project, citation, CodeMeta, and manuscript metadata. The changelog records additions, changes, and comparison links under Semantic Versioning.

**Files/evidence.** `VERSION`; `DESCRIPTION`; `CITATION.cff`; `codemeta.json`; `CHANGELOG.md`; GitHub Release `v2.2.0`. Manuscript p. 1, “Code metadata”.

## E6. Verifiable response for every correction — Critical

**Comment.** Prepare a detailed response identifying each change, file, and page.

**Response.** This document provides a point-by-point response with repository paths and manuscript page/section locators. Page locators refer to the submission PDF generated from `docs/paper/manuscript.qmd`; section names remain stable if typesetting changes pagination.

**Files/evidence.** This file and `docs/submission/manuscript-code-traceability.md`.

## E7. Independent pre-submission quality control — High

**Comment.** Test installation, example data, and the complete workflow on different operating systems.

**Response.** GitHub Actions restores the locked environment and runs quality, unit, bundled-data end-to-end, coverage, and structural validation on Ubuntu, macOS, and Windows. Evidence is uploaded separately for every operating system. A reproducible validation protocol and acceptance criteria are recorded.

**Files/evidence.** `.github/workflows/r-validation.yaml`; `test_all.R`; `experiments/run_validation.R`; `docs/submission/pre-submission-validation.md`. Manuscript pp. 3–4, “Methods” and “Results”.

## E8. Resubmission strategy — Medium

**Comment.** Complete all deficiencies before SoftwareX resubmission or evaluate alternatives appropriate to software maturity.

**Response.** A gated strategy requires all CI jobs, traceability checks, metadata, manuscript rendering, and an independent installation rehearsal before resubmission. It also defines a fallback journal-selection process without weakening the evidence standard.

**Files/evidence.** `docs/submission/resubmission-strategy.md`. Manuscript p. 4, “Limitations” and “Reproducibility and availability”.
