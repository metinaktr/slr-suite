root <- getwd()

stopifnot(isTRUE(slr_assert(TRUE, "ok")))
validation_error <- tryCatch(slr_assert(FALSE, "invalid"), error = identity)
stopifnot(inherits(validation_error, "slr_validation_error"))

wrapped <- slr_wrap_error(simpleError("parent"), "coverage")
stopifnot(inherits(wrapped, "slr_step_error"), wrapped$step == "coverage")

stopifnot(slr_project_root() == normalizePath(root, winslash = "/"))
stopifnot(length(slr_steps(root)) >= 9L)
stopifnot(isTRUE(slr_check_dependencies("base")))
dependency_error <- tryCatch(slr_check_dependencies("not_a_real_package"), error = identity)
stopifnot(inherits(dependency_error, "slr_dependency_error"))

workspace <- tempfile("coverage-pipeline-")
dir.create(file.path(workspace, "scripts"), recursive = TRUE)
file.create(file.path(workspace, "slr-suite.Rproj"))
writeLines("writeLines('ok', 'output.txt')", file.path(workspace, "scripts", "01_ok.R"))
old <- setwd(workspace)
result <- slr_run_step(file.path(workspace, "scripts", "01_ok.R"), root = workspace)
stopifnot(result$status == "success", file.exists("output.txt"))

writeLines("stop('expected')", file.path(workspace, "scripts", "02_fail.R"))
step_error <- tryCatch(
  slr_run_step(file.path(workspace, "scripts", "02_fail.R"), root = workspace),
  error = identity
)
stopifnot(inherits(step_error, "slr_step_error"))
setwd(old)
