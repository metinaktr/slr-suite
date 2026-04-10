library(readr)
library(dplyr)
library(stringr)
library(tidyr)
library(here)

# Screening sonrası veri
M <- readRDS(here::here("data","interim","collection_screened.rds"))

# Keyword havuzu
kw <- M %>%
  select(DE, ID) %>%
  pivot_longer(everything(), values_to = "kw") %>%
  filter(!is.na(kw)) %>%
  separate_rows(kw, sep = ";") %>%
  mutate(
    kw = tolower(str_trim(kw)),
    kw_norm = kw %>%
      str_replace_all("-", " ") %>%
      str_replace_all("\\.", "") %>%
      str_squish()
  )

# En sık geçenler
top_kw <- kw %>%
  count(kw, kw_norm, sort = TRUE) %>%
  filter(n >= 5)

# Thesaurus formatı
thesaurus <- top_kw %>%
  transmute(
    label = kw,
    `replace by` = kw_norm
  ) %>%
  distinct()

# Kaydet
write_tsv(
  thesaurus,
  here::here("data","processed","vos_thesaurus.txt")
)

cat("✅ Thesaurus taslağı üretildi: data/processed/vos_thesaurus.txt\n")
