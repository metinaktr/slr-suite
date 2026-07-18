# ==============================================================================
# 01_acquire_and_dedupe.R (For the WoS Plaintext-Tagged Format)
# ==============================================================================
suppressPackageStartupMessages({
  library(bibliometrix)
  library(dplyr)
  library(readr)
  library(here)
})

cat(">>> 01_acquire_and_dedupe has been started\n")


# --------------------------------------------------
# 1. Mode Detection (CI or Local?)
# --------------------------------------------------
CI_MODE <- tolower(Sys.getenv("CI")) == "true"


# --------------------------------------------------
# 2. DYNAMIC ARRAYS (THIS IS THE CRUX OF THE MATTER)
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
  pattern = "\\.(txt|csv|bib|ris)$",
  full.names = TRUE
)

if (length(input_files) == 0) {
  stop("❌ CI error: No input files found in data/raw/")
}

# 3. WoS Plaintext Okuma Fonksiyonu
# ----------------------------
read_slr_data <- function(file_path) {
  message(">> Being read: ", basename(file_path))
  
  # Let's look at the first row of the data to understand the format
  first_line <- readLines(file_path, n = 1, warn = FALSE)
  
  # If the file starts with "FN " (Web of Science tag), use Bibliometrix
  if (grepl("^FN ", first_line)) {
    # convert2df: Lines with labels that are one below the other (TI, AU, AB vb.) 
    # combines them into a single line and converts them into a table [cite: 1, 8, 33, 519]
    df <- convert2df(file = file_path, dbsource = "wos", format = "plaintext")
  } else {
    # If the file is already a table (CSV), use the standard read function
    df <- read_csv(file_path, col_types = cols(.default = "c"), trim_ws = TRUE)
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

# Identifying the ID Column (UT is always generated after WoS Plaintext)
priority_cols <- c("UT", "DI", "TI")
id_col <- intersect(priority_cols, names(merged))[1]

if (is.na(id_col)) {
  cat("Current Columns:", paste(names(merged), collapse = ", "), "\n")
  stop("❌ Error: The identity columns required to distinguish the records could not be found.")
}

cat(">> Deduplication key:", id_col, "\n")

# Deduplication: Remove duplicate articles
dedup <- merged %>%
  filter(!is.na(.data[[id_col]])) %>%
  distinct(.data[[id_col]], .keep_all = TRUE)

# 5. Save
# ----------------------------
write_csv(dedup, file.path(INTERIM_DIR, "cleaned_dedup.csv"))

cat("✅ Transaction Completed Successfully!\n")
cat("- Number of original records:", nrow(merged), "\n")
cat("- Number of deduplicated (unique) records:", nrow(dedup), "\n")
cat("- Saving location: data/interim/cleaned_dedup.csv\n")
