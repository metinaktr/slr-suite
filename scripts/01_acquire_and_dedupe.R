# ==============================================================================
# 01_acquire_and_dedupe.R (For the WoS Plaintext-Tagged Format)
# ==============================================================================
suppressPackageStartupMessages({
  library(bibliometrix)
  library(dplyr)
  library(readr)
  library(here)
})
source(here::here("R", "document_types.R"))

cat(">>> 01_acquire_and_dedupe has been started\n")


# --------------------------------------------------
# 1. Mode Detection (CI or Local?)
# --------------------------------------------------
CI_MODE <- tolower(Sys.getenv("CI")) == "true"


# --------------------------------------------------
# 2. Project directories
# --------------------------------------------------
ROOT_DIR    <- here::here()
RAW_DIR     <- here::here("data", "raw")
INTERIM_DIR <- here::here("data", "interim")


cat(">> Step 1: Plain Text (Labeled) Data is being processed...\n")

cat(">>> Project root:", ROOT_DIR, "\n")
cat(">>> RAW directory :", RAW_DIR, "\n")


if (!dir.exists(INTERIM_DIR)) {
  dir.create(INTERIM_DIR, recursive = TRUE)
}


# 2. File Listing
# ----------------------------
input_files <- list.files(
  "data/raw",
  pattern = "\\.txt$",
  full.names = TRUE
)

if (length(input_files) == 0) {
  stop("[ERROR] No input files were found in data/raw/.")
}

# 3. WoS plaintext reader
# ----------------------------
read_slr_data <- function(file_path) {
  message(">> Being read: ", basename(file_path))
  
  # Let's look at the first row of the data to understand the format
  first_line <- readLines(file_path, n = 1, warn = FALSE)
  
  # If the file starts with "FN " (Web of Science tag), use Bibliometrix
  if (grepl("^FN ", first_line)) {
    # convert2df combines tagged fields (for example, TI, AU, and AB)
    # into one bibliographic record per row.
    df <- convert2df(file = file_path, dbsource = "wos", format = "plaintext")
  } else {
    # BibexPy combined TXT exports may be delimited rather than WoS-tagged.
    df <- read_delim(file_path, delim = NULL, col_types = cols(.default = "c"), trim_ws = TRUE)
  }
  
  # Capitalize the column names (for the UT, TI, and DI standards)
  names(df) <- toupper(trimws(names(df)))
  return(df)
}

# 4. Merge and Dedupe Data
# ----------------------------
# Bibliometrix sometimes returns a list-column; we fix this using `bind_rows`.
df_list <- lapply(input_files, read_slr_data)
merged <- bind_rows(lapply(df_list, as.data.frame))

if ("DT" %in% names(merged)) {
  merged$DT_ORIGINAL <- merged$DT
  merged$DT <- normalize_document_type(merged$DT)
}

# Identifying the ID Column (UT is always generated after WoS Plaintext)
priority_cols <- c("UT", "DI", "TI")
id_col <- intersect(priority_cols, names(merged))[1]

if (is.na(id_col)) {
  cat("Current Columns:", paste(names(merged), collapse = ", "), "\n")
  stop("[ERROR] No supported record identifier column was found (expected UT, DI, or TI).")
}

cat(">> Deduplication key:", id_col, "\n")

# Deduplication: Remove duplicate articles
dedup <- merged %>%
  filter(!is.na(.data[[id_col]])) %>%
  distinct(.data[[id_col]], .keep_all = TRUE)

# 5. Save
# ----------------------------
write_csv(dedup, file.path(INTERIM_DIR, "cleaned_dedup.csv"))

cat("[OK] Acquisition and deduplication completed.\n")
cat("- Number of original records:", nrow(merged), "\n")
cat("- Number of deduplicated (unique) records:", nrow(dedup), "\n")
cat("- Saving location: data/interim/cleaned_dedup.csv\n")
