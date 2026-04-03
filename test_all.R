# =====================================
# test_all.R
# CI entry-point for SLR-Suite
# =====================================

cat(">> Starting SLR-Suite CI tests\n")

source("scripts/03_biblio_core_ci.R")

stopifnot(
  file.exists("data/processed/ci_run/most_prod_authors.csv"),
  file.exists("data/processed/ci_run/TCCM_ci.csv")
)

cat("✅ All CI tests passed successfully\n")
