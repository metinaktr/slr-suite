# ==============================================================================
# 09_prisma_flow.R
# PRISMA 2020 Flow Diagram - Automated Counting & Visualization
# ==============================================================================

library(dplyr)
library(readr)
library(here)
library(DiagrammeR)

ROOT <- getwd()

RAW_DIR     <- file.path(ROOT, "data", "raw")
INTERIM_DIR <- file.path(ROOT, "data", "interim")
PROC_DIR    <- file.path(ROOT, "data", "processed")

if (!dir.exists(PROC_DIR)) dir.create(PROC_DIR, recursive = TRUE)

cat(">> PRISMA 2020 surveys are beginning...\n")

# --------------------------------------------------
# 1. Identification
# --------------------------------------------------
raw_files <- list.files(RAW_DIR, full.names = TRUE)
records_identified <- length(raw_files)

dedup <- read_csv(file.path(INTERIM_DIR, "cleaned_dedup.csv"),
                  show_col_types = FALSE)

records_after_dedup <- nrow(dedup)

# --------------------------------------------------
# 2. Screening
# --------------------------------------------------
# Assumption: 02_screening.R produces collection_screened.csv.
screened_file <- file.path(INTERIM_DIR, "collection_screened.csv")

if (!file.exists(screened_file)) {
  stop("[ERROR] Screening output was not found: collection_screened.csv")
}

screened <- read_csv(screened_file, show_col_types = FALSE)

records_screened <- nrow(dedup)
records_excluded_title_abstract <- records_after_dedup - nrow(screened)

# --------------------------------------------------
# 3. Eligibility (full text) - optional
# --------------------------------------------------
# If there is no full-text search, "screening" is considered equivalent to "eligibility"
records_assessed_fulltext <- nrow(screened)
records_excluded_fulltext <- 0

# --------------------------------------------------
# 4. Included
# --------------------------------------------------
records_included <- nrow(screened)

# --------------------------------------------------
# 5. PRISMA Table (CSV)
# --------------------------------------------------
prisma_counts <- tibble(
  Step = c(
    "Records identified",
    "Records after duplicates removed",
    "Records screened",
    "Records excluded (title/abstract)",
    "Full-text articles assessed",
    "Full-text articles excluded",
    "Studies included in review"
  ),
  N = c(
    records_identified,
    records_after_dedup,
    records_screened,
    records_excluded_title_abstract,
    records_assessed_fulltext,
    records_excluded_fulltext,
    records_included
  )
)

write_csv(prisma_counts, file.path(PROC_DIR, "prisma_counts.csv"))
cat("[OK] prisma_counts.csv was created.\n")

# --------------------------------------------------
# 6. PRISMA 2020 Flow Diagram (DiagrammeR)
# --------------------------------------------------
grViz(sprintf("
digraph prisma {
  graph [layout = dot, rankdir = TB]

  node [shape = box, style = rounded, fontname = Helvetica]

  A [label = 'Records identified\\n(n = %d)']
  B [label = 'Records after duplicates removed\\n(n = %d)']
  C [label = 'Records screened\\n(n = %d)']
  D [label = 'Records excluded\\n(n = %d)']
  E [label = 'Full-text articles assessed\\n(n = %d)']
  F [label = 'Studies included in review\\n(n = %d)']

  A -> B
  B -> C
  C -> D
  C -> E
  E -> F
}
",
records_identified,
records_after_dedup,
records_screened,
records_excluded_title_abstract,
records_assessed_fulltext,
records_included
)) -> prisma_diagram

# Save
DiagrammeRsvg::export_svg(prisma_diagram) |>
  charToRaw() |>
  rsvg::rsvg_png(file.path(PROC_DIR, "PRISMA_2020_flow.png"))

cat("[OK] The PRISMA 2020 diagram was created: data/processed/PRISMA_2020_flow.png\n")
