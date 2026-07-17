# ==========================================================
# SLR-Suite Core Bibliometric Pipeline (CI-Safe)
# ----------------------------------------------------------
# Purpose:
# - Validate core bibliometric functionality
# - Ensure data ingestion, analysis, and output generation
# - Designed explicitly for GitHub Actions / CI usage
# ----------------------------------------------------------
# This script is NOT intended for full analytical reporting.
# ==========================================================
suppressPackageStartupMessages({
  library(bibliometrix)
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(readr)
})

# ----------------------------
# PATHS (CI-SAFE)
# ----------------------------
ROOT <- getwd()

DATA_RAW <- file.path(ROOT, "data", "raw")
DATA_OUT <- file.path(ROOT, "data", "processed", "ci_run")

if (!dir.exists(DATA_OUT)) {
  dir.create(DATA_OUT, recursive = TRUE)
}

# ----------------------------
# INPUT CHECK
# ----------------------------
files <- list.files(DATA_RAW, full.names = TRUE)
files

if (length(files) == 0) {
  stop("❌ CI error: No input files found in data/raw/")
}

message(">> CI input file detected: ", basename(files[1]))

# ----------------------------
# DATA IMPORT
# ----------------------------
message(">> Importing WoS / Scopus data")

M <- convert2df(
  file     = files[1],
  dbsource = "wos",
  format   = "plaintext"
)


stopifnot(nrow(M) > 0)

# ----------------------------
# BASIC FILTERING
# ----------------------------
D <- M %>%
  filter(!is.na(PY)) %>%
  filter(PY >= 2015, PY <= 2026)

stopifnot(nrow(D) > 0)

message(">> Records after filtering: ", nrow(D))

# ----------------------------
# BIBLIOMETRIC ANALYSIS (CORE TEST)
# ----------------------------
message(">> Running core bibliometric analysis")

results <- biblioAnalysis(D)
S <- summary(results, k = 10, pause = FALSE)

# Save a minimal but verifiable output
write_csv(
  as.data.frame(S$MostProdAuthors),
  file.path(DATA_OUT, "most_prod_authors.csv")
)

# ----------------------------
# MINIMAL TCCM-LIKE CLASSIFICATION (CI VERSION)
# ----------------------------
message(">> Generating minimal CI-safe TCCM output")

get_text <- function(df) {
  txt <- paste(df$TI, df$AB, df$DE, sep = " ")
  txt[is.na(txt)] <- ""
  txt
}

txt <- tolower(get_text(D))

# Minimal theory dictionary (lightweight & deterministic)
theory_dict <- list(
  "Utilitarian"   = "utilitarian",
  "Deontological" = "duty",
  "Virtue"        = "virtue",
  "Care"          = "care",
  "Rights"        = "right"
)

match_all <- function(x, dict) {
  hits <- names(dict)[sapply(dict, function(p) str_detect(x, p))]
  if (length(hits) == 0) NA_character_ else paste(hits, collapse = ";")
}

TCCM <- tibble(
  Title  = D$TI,
  Year   = D$PY,
  Theory = vapply(txt, match_all, dict = theory_dict, FUN.VALUE = character(1))
)

write_csv(
  TCCM,
  file.path(DATA_OUT, "TCCM_ci.csv")
)

# ----------------------------
# FINAL STATUS
# ----------------------------
message("✅ CI-safe core bibliometric pipeline completed successfully")
