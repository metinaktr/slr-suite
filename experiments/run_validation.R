# Deterministic validation of repository structure and the bundled example input.
source(file.path("R", "pipeline.R"), encoding = "UTF-8")
root <- slr_project_root()
started <- Sys.time()

checks <- list(
  rstudio_project = file.exists(file.path(root, "slr-suite.Rproj")),
  dependency_manifest = file.exists(file.path(root, "DESCRIPTION")),
  search_protocol = file.exists(file.path(root, "config", "search_protocol.yaml")),
  screening_protocol = file.exists(file.path(root, "config", "screen_criteria.yaml")),
  example_input = file.exists(file.path(root, "data", "raw", "results.txt")),
  pipeline_steps = length(slr_steps(root)) >= 9L,
  technical_paper = file.exists(file.path(root, "docs", "paper", "manuscript.qmd")),
  automated_tests = dir.exists(file.path(root, "tests", "testthat")),
  dependency_lock = file.exists(file.path(root, "renv.lock")),
  codemeta = file.exists(file.path(root, "codemeta.json")),
  quality_improvements = file.exists(file.path(root, "docs", "quality", "software-quality-improvements.md")),
  traceability_matrix = file.exists(file.path(root, "docs", "quality", "software-documentation-traceability.md")),
  release_validation = file.exists(file.path(root, "docs", "quality", "release-validation.md")),
  maintenance_strategy = file.exists(file.path(root, "docs", "quality", "maintenance-strategy.md"))
)

report <- data.frame(
  check = names(checks), passed = unlist(checks, use.names = FALSE),
  timestamp_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
  stringsAsFactors = FALSE
)
output_dir <- file.path(root, "artifacts", "validation")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(report, file.path(output_dir, "structural_validation.csv"), row.names = FALSE)
writeLines(c(
  paste("R version:", R.version.string), paste("Platform:", R.version$platform),
  paste("Started UTC:", format(started, tz = "UTC", usetz = TRUE)),
  paste("Checks passed:", sum(report$passed), "/", nrow(report))
), file.path(output_dir, "session_summary.txt"), useBytes = TRUE)

if (!all(report$passed)) stop("Structural validation failed: ", paste(report$check[!report$passed], collapse = ", "))
message("Validation passed: ", nrow(report), " checks.")
