# =====================================
# test_all.R
# CI Entry Point for SLR-Suite
# =====================================

rm(list = ls())

suppressPackageStartupMessages({
  library(bibliometrix)
  library(dplyr)
  library(readr)
  library(here)
})

cat(">> Starting CI tests for SLR-Suite\n")

# --------------------------------------------------
# DEBUG / CONTEXT (bilgi amaçlı)
# --------------------------------------------------
cat("getwd() :", getwd(), "\n")
cat("here()  :", here::here(), "\n")

RAW_DIR <- here::here("data", "raw")

cat("RAW dir exists?:", dir.exists(RAW_DIR), "\n")
cat("Files in raw:\n")
print(list.files(RAW_DIR, all.files = TRUE))

# --------------------------------------------------
# Run CI-safe core pipeline (WORKDIR-INDEPENDENT)
# --------------------------------------------------
CI_SCRIPT <- here::here("ci", "03_biblio_core_ci.R")

if (!file.exists(CI_SCRIPT)) {
  stop("❌ CI script not found: ", CI_SCRIPT)
}

source(CI_SCRIPT)

cat("✅ Core CI script sourced successfully\n")

# --------------------------------------------------
# Validate expected outputs (WORKDIR-INDEPENDENT)
# --------------------------------------------------
expected_files <- c(
  here::here("data", "processed", "ci_run", "most_prod_authors.csv"),
  here::here("data", "processed", "ci_run", "TCCM_ci.csv")
)

missing_files <- expected_files[!file.exists(expected_files)]

if (length(missing_files) > 0) {
  stop(
    "❌ CI test failed. Missing output files:\n",
    paste(missing_files, collapse = "\n")
  )
}

cat("✅ All CI tests passed successfully\n")
