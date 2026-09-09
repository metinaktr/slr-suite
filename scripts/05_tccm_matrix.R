# ==============================================================================
# 05_tccm_matrix.R
# Dynamic & Parametric TCCM Matrix Generator
# ==============================================================================

# Clear the cache (If the launcher installs the dictionary file, you can delete this)
library(dplyr)
library(readr)
library(stringr)
library(tidyr)
library(ggplot2)
library(stringi)
library(bibliometrix)
library(here)
source(here("R", "tccm.R"))

# 1. Upload External Dictionary
# If it doesn't work through the Launcher, download it here:
if (!exists("TCCM_DICTIONARIES")) {
  source(here("scripts", "config_dictionaries.R"))
}

# 2. DATA UPLOAD AND PREPARATION
df <- read_csv(here("data", "interim", "collection_screened.csv"))

OUT_DIR <- here("data", "processed", "tccm")
if (!dir.exists(OUT_DIR)) dir.create(OUT_DIR, recursive = TRUE)

# Build exactly one normalized text string for every input record.
record_text <- build_tccm_record_text(df)

split_keywords <- function(s){
  if (is.na(s) || !nzchar(s)) return(character(0))
  s <- gsub(";", ",", s)
  toks <- unlist(strsplit(s, ","))
  trimws(toks[nzchar(toks)])
}

get_chars <- function(de, id, top_k=5){
  kws <- unique(c(split_keywords(de), split_keywords(id)))
  if (length(kws)==0) return(NA_character_)
  paste(head(kws, top_k), collapse="; ")
}

# ---- CONSTRUCTION OF THE TCCM MATRIX ----
message(">> The TCCM matrix is dynamically generated based on the dictionary structure...")

# Initial framework
TCCM <- tibble(
  Authors = df$AU,
  Year = df$PY,
  Source = df$SO,
  Title = df$TI,
  DOI = if("DI" %in% names(df)) df$DI else NA_character_,
  Top_Keywords = mapply(get_chars, df$DE, df$ID)
)

# Apply every configured dimension independently to each record. The resulting
# assignment table has the same number and order of rows as the input data.
TCCM <- bind_cols(
  TCCM,
  classify_tccm_records(record_text, TCCM_DICTIONARIES)
)
stopifnot(nrow(TCCM) == nrow(df))

# Save Result
write_csv(TCCM, file.path(OUT_DIR, "TCCM_matrix.csv"))

# ---- FREQ TABLES (DYNAMIC) ----
freq_table <- function(vec, name){
  tibble(x=vec) %>%
    filter(!is.na(x), nzchar(x)) %>%
    separate_rows(x, sep=";\\s*") %>%
    count(x, sort=TRUE) %>%
    rename(!!name := x, n = n)
}

# Generate an automatic frequency table for each category in the dictionary
for (cat_name in names(TCCM_DICTIONARIES)) {
  ft <- freq_table(TCCM[[cat_name]], cat_name)
  write_csv(ft, file.path(OUT_DIR, paste0("freq_", tolower(cat_name), ".csv")))
}

message("[OK] The TCCM matrix and frequency tables were created successfully.")
