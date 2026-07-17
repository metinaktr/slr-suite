# Reusable orchestration functions. Analysis scripts remain independently runnable.

if (!exists("slr_abort", mode = "function")) {
  source(file.path("R", "conditions.R"), encoding = "UTF-8")
}

slr_project_root <- function(start = getwd()) {
  current <- normalizePath(start, winslash = "/", mustWork = TRUE)
  repeat {
    if (file.exists(file.path(current, "slr-suite.Rproj"))) return(current)
    parent <- dirname(current)
    if (identical(parent, current)) slr_abort("SLR Suite project root was not found.", "slr_path_error")
    current <- parent
  }
}

slr_steps <- function(root = slr_project_root()) {
  sort(list.files(file.path(root, "scripts"), pattern = "^[0-9]{2}_.+\\.R$", full.names = TRUE))
}

slr_check_dependencies <- function(packages = c("bibliometrix", "dplyr", "here", "readr", "stringr", "tidyr")) {
  missing <- packages[!vapply(packages, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))]
  if (length(missing)) {
    slr_abort(
      paste0("Missing R packages: ", paste(missing, collapse = ", "),
             ". Run renv::restore() before starting the pipeline."),
      "slr_dependency_error", packages = missing
    )
  }
  invisible(TRUE)
}

slr_run_step <- function(script, root = slr_project_root(), log_dir = file.path(root, "logs")) {
  slr_assert(file.exists(script), paste0("Pipeline script not found: ", script),
             "slr_path_error", path = script)
  dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)
  started <- Sys.time()
  status <- "success"
  error_message <- ""
  captured_error <- NULL
  tryCatch(
    sys.source(script, envir = new.env(parent = globalenv()), chdir = FALSE),
    error = function(error) {
      status <<- "failed"
      error_message <<- conditionMessage(error)
      captured_error <<- slr_wrap_error(error, basename(script))
    }
  )
  record <- data.frame(
    step = basename(script), status = status,
    started_at = format(started, tz = "UTC", usetz = TRUE),
    duration_seconds = round(as.numeric(difftime(Sys.time(), started, units = "secs")), 3),
    message = error_message, stringsAsFactors = FALSE
  )
  log_file <- file.path(log_dir, "pipeline_runs.csv")
  write.table(record, log_file, sep = ",", row.names = FALSE,
              col.names = !file.exists(log_file), append = file.exists(log_file))
  if (identical(status, "failed")) stop(captured_error)
  invisible(record)
}

slr_run_pipeline <- function(root = slr_project_root(), steps = slr_steps(root)) {
  slr_check_dependencies()
  old <- setwd(root)
  on.exit(setwd(old), add = TRUE)
  invisible(do.call(rbind, lapply(steps, slr_run_step, root = root)))
}

slr_menu <- function(root = slr_project_root()) {
  steps <- slr_steps(root)
  labels <- c("Run complete pipeline", basename(steps), "Run validation experiment", "Exit")
  repeat {
    selected <- menu(labels, title = "SLR Suite")
    if (selected == 0L || selected == length(labels)) break
    if (selected == 1L) slr_run_pipeline(root)
    else if (selected == length(labels) - 1L) source(file.path(root, "experiments", "run_validation.R"))
    else slr_run_step(steps[[selected - 1L]], root)
  }
  invisible(TRUE)
}
