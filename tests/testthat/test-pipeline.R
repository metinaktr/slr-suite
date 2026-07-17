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

test_that("console menu accepts a numbered selection", {
  input <- textConnection("2")
  on.exit(close(input), add = TRUE)
  expect_equal(slr_menu_select(c("First", "Exit"), input = input), 2L)
})
