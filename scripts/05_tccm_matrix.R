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

# 1. Upload External Dictionary
# If it doesn't work through the Launcher, download it here:
if (!exists("TCCM_DICTIONARIES")) {
  source(here("scripts", "config_dictionaries.R"))
}

# 2. DATA UPLOAD AND PREPARATION
df <- read_csv(here("data", "interim", "collection_screened.csv"))

OUT_DIR <- here("data", "processed", "tccm")
if (!dir.exists(OUT_DIR)) dir.create(OUT_DIR, recursive = TRUE)

# ---- TEXT PROCESSING ----
norm_txt <- function(x){
  x %>%
    tolower() %>%
    stringi::stri_replace_all_regex("[^\\p{L}\\p{N}\\s-]", " ") %>%
    str_squish()
}

# The main block of text to be analyzed
txt_all <- norm_txt(paste(df$TI, df$AB, df$DE, df$ID))

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

# ---- DYNAMIC MATCH FUNCTION ----
match_category <- function(text, dict_list) {
  found_labels <- c()
  for (label in names(dict_list)) {
    patterns <- dict_list[[label]]
    if (any(str_detect(text, regex(paste(patterns, collapse = "|"), ignore_case = TRUE)))) {
      found_labels <- c(found_labels, label)
    }
  }
  if (length(found_labels) == 0) return(NA_character_)
  return(paste(unique(found_labels), collapse = "; "))
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

# ADD EVERY CATEGORY IN THE DICTIONARY AS AN AUTOMATIC COLUMN
for (cat_name in names(TCCM_DICTIONARIES)) {
  message("--- Processing...: ", cat_name)
  TCCM[[cat_name]] <- vapply(txt_all, 
                             function(t) match_category(t, TCCM_DICTIONARIES[[cat_name]]), 
                             FUN.VALUE = character(1))
}

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

message("✔ The TCCM matrix and frequency tables have been successfully completed.")
