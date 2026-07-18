# ==============================================================================
# 02_screening.R
# Title–Abstract Screening (DYNAMIC & PIPELINE-SAFE)
# ==============================================================================
suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(here)
})

cat(">>> 02_Screening has begun\n")

# --------------------------------------------------
# 1. Dynamic Paths
# --------------------------------------------------
INTERIM_DIR <- here::here("data", "interim")

IN_FILE  <- file.path(INTERIM_DIR, "cleaned_dedup.csv")
OUT_RDS  <- file.path(INTERIM_DIR, "collection_screened.rds")
OUT_CSV  <- file.path(INTERIM_DIR, "collection_screened.csv")

if (!file.exists(IN_FILE)) {
  stop("❌ cleaned_dedup.csv was not found. Run 01_acquire_and_dedupe.R first.")
}

# --------------------------------------------------
# 2. Data Upload
# --------------------------------------------------
df <- read_csv(IN_FILE, show_col_types = FALSE)
names(df) <- toupper(names(df))

cat(">>> Number of entries:", nrow(df), "\n")

# --------------------------------------------------
# 3. Title–Abstract Screening (BASIC)
# --------------------------------------------------
screened <- df %>%
  filter(
    !is.na(TI), nzchar(TI),
    !is.na(AB), nzchar(AB)
  )

cat(">>> Number of registrations following screening:", nrow(screened), "\n")

# --------------------------------------------------
# 4. KAYIT (PIPELINE STANDARD)
# --------------------------------------------------
saveRDS(screened, OUT_RDS)
write_csv(screened, OUT_CSV)

cat("✅ Screening is complete\n")
cat("📁 RDS :", OUT_RDS, "\n")
cat("📁 CSV :", OUT_CSV, "\n")
