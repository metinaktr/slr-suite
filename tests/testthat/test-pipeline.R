test_that("project root and numbered steps are discoverable", {
  root <- slr_project_root()
  expect_true(file.exists(file.path(root, "slr-suite.Rproj")))
  steps <- slr_steps(root)
  expect_gte(length(steps), 9L)
  expect_true(all(grepl("^[0-9]{2}_", basename(steps))))
})

test_that("missing scripts fail explicitly", {
  expect_error(slr_run_step("not-a-script.R"), "not found")
})
