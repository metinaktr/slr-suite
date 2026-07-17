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
