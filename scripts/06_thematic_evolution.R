# 06_thematic_evolution.R

library(bibliometrix)
library(ggplot2)

df <- read_csv("data/interim/screened.csv")

OUT_DIR <- "data/processed/thematic"
if (!dir.exists(OUT_DIR)) dir.create(OUT_DIR, recursive=TRUE)

year_min <- min(df$PY, na.rm=TRUE)
year_max <- max(df$PY, na.rm=TRUE)
mid <- ceiling(year_min + (year_max-year_min)/2)

safe_breaks <- unique(sort(c(year_min, mid, year_max)))

TE <- thematicEvolution(df, field="ID", years=safe_breaks, n=250)

png(file.path(OUT_DIR, "thematic_sankey.png"), width=2000, height=1400, res=200)
plot(TE)
dev.off()

message("✔ Tematik evrim tamamlandı.")
