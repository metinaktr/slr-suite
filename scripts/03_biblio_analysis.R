# 03_biblio_analysis.R
rm(list=ls())
library(bibliometrix)
library(dplyr)
library(readr)
library(ggplot2)

FILE_PATH <- "data/interim/screened.csv"
OUT_DIR   <- "data/processed/biblio"

if (!dir.exists(OUT_DIR)) dir.create(OUT_DIR, recursive = TRUE)

df <- read_csv(FILE_PATH)

results <- biblioAnalysis(df)
summary_res <- summary(results, k = 50, pause = FALSE)

write_csv(as.data.frame(summary_res$MostProdAuthors), file.path(OUT_DIR, "most_prod_authors.csv"))
write_csv(as.data.frame(summary_res$MostProdCountries), file.path(OUT_DIR, "most_prod_countries.csv"))
write_csv(as.data.frame(summary_res$MostRelSources), file.path(OUT_DIR, "most_rel_sources.csv"))
write_csv(as.data.frame(summary_res$MostCitedPapers), file.path(OUT_DIR, "most_cited_papers.csv"))

NetMatrix <- biblioNetwork(df, analysis = "co-occurrences", network = "keywords", sep = ";")
save(NetMatrix, file = file.path(OUT_DIR, "NetMatrix_keywords.rda"))

png(file.path(OUT_DIR, "biblio_top10.png"), width = 1600, height = 1000, res = 180)
plot(results, k = 10)
dev.off()

message("✔ Bibliyometrik analiz tamamlandı.")
