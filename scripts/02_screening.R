# 02_screening.R

library(readr)
library(dplyr)

df <- read_csv("data/interim/cleaned_dedup.csv")

screened <- df %>%
  filter(!is.na(TI), !is.na(AB))

write_csv(screened, "data/interim/screened.csv")
message("✔ Screening tamamlandı.")
