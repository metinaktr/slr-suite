# 01_acquire_and_dedupe.R

library(dplyr)
library(readr)

input_files <- list.files("data/raw", full.names = TRUE, pattern = "\\.csv$")

df_list <- lapply(input_files, read_csv)

merged <- bind_rows(df_list)

# UT yoksa DOI, yoksa Title ile dedupe yapılsın
id_col <- intersect(c("UT", "DI", "TI"), names(merged))[1]

if (is.null(id_col)) {
  stop("Veri setinde UT, DI veya TI değişkeni bulunamadı. Deduplikasyon yapılamıyor.")
}

dedup <- merged %>% distinct(.data[[id_col]], .keep_all = TRUE)

write_csv(dedup, "data/interim/cleaned_dedup.csv")

message(paste("✔ Deduplikasyon tamamlandı. Kullanılan ID:", id_col))
