# =====================================
# test_all.R
# CI Entry Point for SLR-Suite
# =====================================

cat(">> Starting CI tests for SLR-Suite\n")

# ----------------------------
# Run CI-safe core pipeline
# ----------------------------
source("scripts/ci/03_biblio_core_ci.R")

# ----------------------------
# Validate expected outputs
# ----------------------------
expected_files <- c(
  "data/processed/ci_run/most_prod_authors.csv",
  "data/processed/ci_run/TCCM_ci.csv"
)

missing_files <- expected_files[!file.exists(expected_files)]

if (length(missing_files) > 0) {
  stop(
    "❌ CI test failed. Missing output files:\n",
    paste(missing_files, collapse = "\n")
  )
}

cat("✅ All CI tests passed successfully\n")
