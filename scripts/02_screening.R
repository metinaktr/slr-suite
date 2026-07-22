# ==============================================================================
# 02_screening.R
# Configurable title-abstract screening with an auditable decision log
# ==============================================================================
suppressPackageStartupMessages({
  library(readr)
  library(here)
})
source(here::here("R", "screening.R"))

cat(">>> 02_screening has started\n")

# --------------------------------------------------
# 1. Dynamic Paths
# --------------------------------------------------
INTERIM_DIR <- here::here("data", "interim")

IN_FILE  <- file.path(INTERIM_DIR, "cleaned_dedup.csv")
OUT_RDS  <- file.path(INTERIM_DIR, "collection_screened.rds")
OUT_CSV  <- file.path(INTERIM_DIR, "collection_screened.csv")
AUDIT_CSV <- file.path(INTERIM_DIR, "screening_decisions.csv")
CRITERIA_FILE <- here::here("config", "screen_criteria.yaml")

if (!file.exists(IN_FILE)) {
  stop("[ERROR] cleaned_dedup.csv was not found. Run 01_acquire_and_dedupe.R first.")
}

# --------------------------------------------------
# 2. Data Upload
# --------------------------------------------------
records <- read_csv(IN_FILE, show_col_types = FALSE)
names(records) <- toupper(names(records))

cat(">>> Number of records:", nrow(records), "\n")

# --------------------------------------------------
# 3. Configured screening
# --------------------------------------------------
criteria <- read_screening_criteria(CRITERIA_FILE)
decisions <- screen_records(records, criteria)
screened <- decisions[decisions$SCREENING_DECISION == "include", , drop = FALSE]

cat(">>> Number included after configured screening:", nrow(screened), "\n")

# --------------------------------------------------
# 4. Save outputs (pipeline standard)
# --------------------------------------------------
saveRDS(screened, OUT_RDS)
write_csv(screened, OUT_CSV)
write_csv(decisions, AUDIT_CSV)

cat("[OK] Screening completed. Researcher review is still required.\n")
cat("[FILE] RDS:", OUT_RDS, "\n")
cat("[FILE] CSV:", OUT_CSV, "\n")
cat("[FILE] Decision audit:", AUDIT_CSV, "\n")
