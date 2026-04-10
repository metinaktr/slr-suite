# ==========================================================
# SLR-Suite Core Bibliometric Pipeline (CI-Safe)
# ==========================================================

rm(list = ls())

suppressPackageStartupMessages({
  library(bibliometrix)
  library(dplyr)
  library(stringr)
  library(readr)
  library(here)
})

# ----------------------------
# PATHS (TRULY CI-SAFE)
# ----------------------------
ROOT <- here::here()
DATA_RAW <- here::here("data", "raw")
DATA_OUT <- here::here("data", "processed", "ci_run")

if (!dir.exists(DATA_OUT)) {
  dir.create(DATA_OUT, recursive = TRUE)
}

cat("CI root :", ROOT, "\n")
cat("RAW dir :", DATA_RAW, "\n")

# ----------------------------
# INPUT CHECK
# ----------------------------
files <- list.files(
  DATA_RAW,
  pattern = "\\.(txt|csv|bib|ris)$",
  ignore.case = TRUE,
  full.names = TRUE
)

if (length(files) == 0) {
  stop("❌ CI error: No input files found in data/raw/")
}

cat(">> CI input file:", basename(files[1]), "\n")

# ----------------------------
# DATA IMPORT (ROBUST)
# ----------------------------
first_line <- readLines(files[1], n = 1, warn = FALSE)

M <- if (grepl("^FN ", first_line)) {
  convert2df(files[1], dbsource = "wos", format = "plaintext")
} else {
  read_csv(files[1], col_types = cols(.default = "c"))
}

names(M) <- toupper(names(M))
stopifnot(nrow(M) > 0)

# ----------------------------
# BASIC FILTERING
# ----------------------------
D <- M %>%
  filter(!is.na(PY), PY >= 2015, PY <= 2026)

stopifnot(nrow(D) > 0)

# ----------------------------
# CORE BIBLIOMETRIC CHECK
# ----------------------------
results <- biblioAnalysis(D)
S <- summary(results, k = 10, pause = FALSE)

write_csv(
  as.data.frame(S$MostProdAuthors),
  file.path(DATA_OUT, "most_prod_authors.csv")
)

# ----------------------------
# MINIMAL CI-TCCM
# ----------------------------
txt <- tolower(paste(D$TI, D$AB, D$DE, sep = " "))
txt[is.na(txt)] <- ""

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

message("✅ CI-safe core bibliometric pipeline completed successfully")
