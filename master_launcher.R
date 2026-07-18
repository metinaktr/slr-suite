# SLR Suite command-line and RStudio launcher

source(file.path("R", "pipeline.R"), encoding = "UTF-8")

args <- commandArgs(trailingOnly = TRUE)
command <- if (length(args)) args[[1]] else if (interactive()) "menu" else "help"

if (identical(command, "menu")) {
  slr_menu()
} else if (identical(command, "run")) {
  slr_run_pipeline()
} else if (identical(command, "step")) {
  step_number <- if (length(args) >= 2L) suppressWarnings(as.integer(args[[2]])) else NA_integer_
  steps <- slr_steps()
  slr_assert(
    length(step_number) == 1L && !is.na(step_number) &&
      step_number >= 1L && step_number <= length(steps),
    sprintf("Step number must be between 1 and %d.", length(steps)),
    "slr_validation_error"
  )
  slr_check_dependencies()
  slr_run_step(steps[[step_number]], root = slr_project_root())
} else if (identical(command, "validate")) {
  source(file.path("experiments", "run_validation.R"), encoding = "UTF-8")
} else {
  cat(paste(
    "SLR Suite\n",
    "Usage: Rscript master_launcher.R <command>\n",
    "Commands:\n",
    "  run       Run the complete analysis pipeline\n",
    "  step <n>  Run one numbered analysis step (1-9)\n",
    "  validate  Run the reproducibility experiment\n",
    "  menu      Open the interactive console or RStudio menu\n",
    sep = ""
  ))
}
