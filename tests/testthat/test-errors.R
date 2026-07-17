test_that("validation failures expose stable condition classes", {
  expect_error(
    slr_assert(FALSE, "invalid input"),
    class = "slr_validation_error"
  )
})

test_that("step failures preserve step and parent error", {
  script <- tempfile(fileext = ".R")
  writeLines("stop('synthetic failure')", script)
  error <- tryCatch(slr_run_step(script, log_dir = tempfile()), error = identity)
  expect_s3_class(error, "slr_step_error")
  expect_identical(error$step, basename(script))
  expect_match(conditionMessage(error), "synthetic failure")
  expect_s3_class(error$parent, "simpleError")
})
