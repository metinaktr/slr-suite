# SLR Suite command-line and RStudio launcher

source(file.path("R", "pipeline.R"), encoding = "UTF-8")

args <- commandArgs(trailingOnly = TRUE)
command <- if (length(args)) args[[1]] else if (interactive()) "menu" else "help"

if (identical(command, "menu")) {
  slr_menu()
} else if (identical(command, "run")) {
  slr_run_pipeline()
} else if (identical(command, "validate")) {
  source(file.path("experiments", "run_validation.R"), encoding = "UTF-8")
} else {
  cat(paste(
    "SLR Suite\n",
    "Usage: Rscript master_launcher.R <command>\n",
    "Commands:\n",
    "  run       Run the complete analysis pipeline\n",
    "  validate  Run the reproducibility experiment\n",
    "  menu      Open the interactive RStudio menu\n",
    sep = ""
  ))
}
