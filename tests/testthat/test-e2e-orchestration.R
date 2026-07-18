test_that("multiple steps execute end to end in isolated environments", {
  root <- tempfile("slr-e2e-")
  dir.create(file.path(root, "scripts"), recursive = TRUE)
  file.create(file.path(root, "slr-suite.Rproj"))
  writeLines("writeLines('stage-1', file.path('stage-1.txt'))", file.path(root, "scripts", "01_first.R"))
  writeLines(
    "stopifnot(file.exists('stage-1.txt')); writeLines('stage-2', 'stage-2.txt')",
    file.path(root, "scripts", "02_second.R")
  )
  old <- setwd(root)
  on.exit(setwd(old), add = TRUE)
  steps <- slr_steps(root)
  result <- do.call(rbind, lapply(steps, slr_run_step, root = root))
  expect_equal(result$status, c("success", "success"))
  expect_true(file.exists(file.path(root, "stage-2.txt")))
  expect_true(file.exists(file.path(root, "logs", "pipeline_runs.csv")))
})

test_that("screening output contract is shared by downstream modules", {
  root <- slr_project_root()
  producer <- paste(
    readLines(file.path(root, "scripts", "02_screening.R"), warn = FALSE),
    collapse = "\n"
  )
  expect_match(producer, "collection_screened[.]csv")

  consumers <- c(
    "scripts/05_tccm_matrix.R",
    "scripts/06_thematic_evolution.R",
    "scripts/07_citation_impact.R"
  )
  content <- vapply(consumers, function(path) {
    paste(readLines(file.path(root, path), warn = FALSE), collapse = "\n")
  }, character(1))
  expect_true(all(grepl("collection_screened[.]csv", content)))
  expect_false(any(grepl("data/interim/screened[.]csv", content, fixed = FALSE)))
})
