# ==============================================================================
# 02_screening.R
# Title–Abstract Screening (DYNAMIC & PIPELINE-SAFE)
# ==============================================================================

rm(list = ls())

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(here)
})

cat(">>> 02_screening başlatıldı\n")

# --------------------------------------------------
# 1. Dinamik Yollar
# --------------------------------------------------
INTERIM_DIR <- here::here("data", "interim")

IN_FILE  <- file.path(INTERIM_DIR, "cleaned_dedup.csv")
OUT_RDS  <- file.path(INTERIM_DIR, "collection_screened.rds")
OUT_CSV  <- file.path(INTERIM_DIR, "collection_screened.csv")

if (!file.exists(IN_FILE)) {
  stop("❌ cleaned_dedup.csv bulunamadı. Önce 01_acquire_and_dedupe.R çalıştırın.")
}

# --------------------------------------------------
# 2. Veri Yükleme
# --------------------------------------------------
df <- read_csv(IN_FILE, show_col_types = FALSE)
names(df) <- toupper(names(df))

cat(">>> Girdi kayıt sayısı:", nrow(df), "\n")

# --------------------------------------------------
# 3. Title–Abstract Screening (BASIC)
# --------------------------------------------------
screened <- df %>%
  filter(
    !is.na(TI), nzchar(TI),
    !is.na(AB), nzchar(AB)
  )

cat(">>> Screening sonrası kayıt sayısı:", nrow(screened), "\n")

# --------------------------------------------------
# 4. KAYIT (PIPELINE STANDARD)
# --------------------------------------------------
saveRDS(screened, OUT_RDS)
write_csv(screened, OUT_CSV)

cat("✅ Screening tamamlandı\n")
cat("📁 RDS :", OUT_RDS, "\n")
cat("📁 CSV :", OUT_CSV, "\n")
