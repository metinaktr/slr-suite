library(bibliometrix)
library(ggplot2)
library(dplyr)
library(readr)

# 1. Data Reading and Preparation
df <- read_csv("data/interim/collection_screened.csv")
df <- as.data.frame(df) # A classic data.frame is required for bibliometrix

OUT_DIR <- "data/processed/thematic"
if (!dir.exists(OUT_DIR)) dir.create(OUT_DIR, recursive=TRUE)

# 2. Smart Year-Cutting Mechanism (Error Corrector)
year_min <- min(df$PY, na.rm=TRUE)
year_max <- max(df$PY, na.rm=TRUE)

# If the year range is very narrow (e.g., only 2024 and 2025), automatically apply a single breakdown
if (year_max - year_min <= 1) {
  safe_breaks <- c(year_min, year_max)
} else {
  mid <- floor(year_min + (year_max - year_min) / 2)
  safe_breaks <- unique(sort(c(year_min, mid, year_max)))
}

# Critical Check: If it is still not unique, force it manually
if (length(safe_breaks) < 2) {
  safe_breaks <- c(year_min, year_min + 1)
}

message(">> Breakdowns by Year of Use: ", paste(safe_breaks, collapse = " - "))

# 3. Thematic Evolution Analysis
# field="ID" (Keywords Plus) Generally, it yields more results in the WoS data
TE <- tryCatch({
  thematicEvolution(df, 
                    field = "ID", 
                    years = safe_breaks, 
                    n = 250, 
                    minFreq = 2)
}, error = function(e) {
  message("❌ Error: Thematic evolution could not be calculated. This may be due to insufficient data.")
  return(NULL)
})

# 4. Visualization (Sankey Diagram)
if (!is.null(TE)) {
  png(file.path(OUT_DIR, "thematic_sankey.png"), width=2200, height=1400, res=220)
  # Let's add a label to the Sankey diagram
  plot(TE)
  dev.off()
  message("✔ The thematic evolution has been successfully completed.")
}
