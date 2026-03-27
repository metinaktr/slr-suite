# 08_future_agenda_SPAR.R

library(readr)
library(dplyr)

tccm <- read_csv("data/processed/tccm/TCCM_matrix.csv")

spar <- tccm %>%
  group_by(Theory) %>%
  summarise(Count = n()) %>%
  arrange(desc(Count))

write_csv(spar, "data/processed/future_agenda_spar.csv")

message("✔ SPAR öneri seti üretildi.")
