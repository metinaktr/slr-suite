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
df <- read_csv(FILE_PATH, col_types = cols(.default = "c"))
df <- as.data.frame(df)
# 2. Analiz edilecek sütunların karakter (string) olduğundan emin olun
# bibliometrix'in strsplit hatası verdiği sütunları metne çeviriyoruz
cols_to_fix <- intersect(c("AU", "DE", "ID", "SO", "TI", "CR"), names(df))
df[cols_to_fix] <- lapply(df[cols_to_fix], as.character)


# 3. Sayısal sütunları zorunlu olarak numerik yapın
if ("PY" %in% names(df)) df$PY <- as.numeric(as.character(df$PY))
if ("TC" %in% names(df)) df$TC <- as.numeric(as.character(df$TC))

# 4. Kayıp (NA) değerleri bibliometrix'in sevmediği boşluklara çevirin
df[is.na(df)] <- ""

# Şimdi analizi çalıştırın
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
