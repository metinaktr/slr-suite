# 08_future_agenda_SPAR.R

rm(list = ls())

suppressPackageStartupMessages({
  library(bibliometrix)
  library(dplyr)
  library(readr)
  library(here)
})



tccm <- read_csv("data/processed/tccm/TCCM_matrix.csv")

spar <- tccm %>%
  group_by(Theory) %>%
  summarise(Count = n()) %>%
  arrange(desc(Count))

write_csv(spar, "data/processed/future_agenda_spar.csv")

message("✔ SPAR öneri seti üretildi.")
