# 01_acquire_and_dedupe.R

library(dplyr)
library(readr)
library(stringr)

input_files <- list.files("data/raw", full.names = TRUE)

df_list <- lapply(input_files, function(f) {
  tryCatch(read_csv(f), error = function(e) NULL)
})

merged <- bind_rows(df_list)

dedup <- merged %>% distinct(UT, .keep_all = TRUE)

write_csv(dedup, "data/interim/cleaned_dedup.csv")
message("✔ Veri toplama + deduplikasyon tamamlandı.")
