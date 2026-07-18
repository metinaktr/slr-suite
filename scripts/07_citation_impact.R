# 07_citation_impact.R
library(bibliometrix)
library(dplyr)
library(readr)

df <- read_csv("data/interim/collection_screened.csv")

cit <- citations(df, field="article", sep=";")

write_csv(as.data.frame(cit$Cited), "data/processed/citation_impact.csv")

message("✔ Citation impact tamamlandı.")
