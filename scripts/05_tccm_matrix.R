# 05_tccm_matrix.R
rm(list=ls())

library(dplyr)
library(readr)
library(stringr)
library(tidyr)
library(ggplot2)
library(stringi)
library(bibliometrix)

df <- read_csv("data/interim/screened.csv")

OUT_DIR <- "data/processed/tccm"
if (!dir.exists(OUT_DIR)) dir.create(OUT_DIR, recursive = TRUE)

# ---- TEXT PROCESSING ----
norm_txt <- function(x){
  x %>%
    tolower() %>%
    stringi::stri_replace_all_regex("[^\\p{L}\\p{N}\\s-]", " ") %>%
    str_squish()
}

txt_all <- norm_txt(paste(df$TI, df$AB, df$DE, df$ID))

split_keywords <- function(s){
  if (is.na(s) || !nzchar(s)) return(character(0))
  s <- gsub(";", ",", s)
  toks <- unlist(strsplit(s, ","))
  trimws(toks[nzchar(toks)])
}

get_chars <- function(de, id, top_k=5){
  kws <- unique(c(split_keywords(de), split_keywords(id)))
  if (length(kws)==0) return(NA)
  paste(head(kws, top_k), collapse="; ")
}

# ---- DICTIONARIES ----
theory_dict <- list(
  "Utilitarian Ethics" = c("utilitarian","utility"),
  "Deontological Ethics" = c("deontolog"),
  "Virtue Ethics" = c("virtue ethic"),
  "Rights-Based Ethics" = c("right"),
  "Care Ethics" = c("care ethic"),
  "Social Contract Theory" = c("social contract")
)

context_dict <- list(
  "SMEs" = c("sme","small and medium","kobi"),
  "Public Sector" = c("public sector","government","kamu"),
  "Healthcare" = c("healthcare","hospital","sağlık"),
  "Banking/Finance" = c("bank","fintech","financial"),
  "Education" = c("education","university","school"),
  "Manufacturing" = c("manufactur","production"),
  "Retail" = c("retail","consumer goods")
)

characteristics_dict <- list(
  "Privacy" = c("privacy","personal data"),
  "Trust" = c("trust"),
  "AI Risk" = c("risk","vulnerability"),
  "Transparency" = c("transparency","explainability")
)

method_dict <- list(
  "Survey" = c("survey"),
  "PLS-SEM" = c("pls-sem","partial least squares"),
  "CB-SEM" = c("cb-sem"),
  "Regression" = c("regression","ols"),
  "Case Study" = c("case study"),
  "Qualitative" = c("qualitative","interview"),
  "Mixed Methods" = c("mixed method")
)

moderator_dict <- list(
  "Age" = c("age","elderly"),
  "Gender" = c("male","female","gender"),
  "Culture" = c("cultural","cross-cultural"),
  "Experience" = c("expertise","novice")
)

match_all <- function(text, dict){
  labs <- c()
  for (label in names(dict)) {
    pats <- dict[[label]]
    if (any(str_detect(text, regex(paste(pats, collapse="|"), ignore_case=TRUE)))) {
      labs <- c(labs, label)
    }
  }
  if (length(labs)==0) return(NA)
  paste(unique(labs), collapse="; ")
}

# ---- TCCM ----
TCCM <- tibble(
  Authors = df$AU,
  Year = df$PY,
  Source = df$SO,
  Title = df$TI,
  DOI = df$DI,
  Top_Keywords = mapply(get_chars, df$DE, df$ID),
  Theory = vapply(txt_all, match_all, dict=theory_dict, FUN.VALUE=character(1)),
  Context = vapply(txt_all, match_all, dict=context_dict, FUN.VALUE=character(1)),
  Characteristics = vapply(txt_all, match_all, dict=characteristics_dict, FUN.VALUE=character(1)),
  Methodology = vapply(txt_all, match_all, dict=method_dict, FUN.VALUE=character(1)),
  Moderators = vapply(txt_all, match_all, dict=moderator_dict, FUN.VALUE=character(1))
)

write_csv(TCCM, file.path(OUT_DIR, "TCCM_matrix.csv"))

# ---- FREQ TABLES ----
freq_table <- function(vec, name){
  tibble(x=vec) %>%
    filter(!is.na(x), nzchar(x)) %>%
    separate_rows(x, sep=";\\s*") %>%
    count(x, sort=TRUE)
}

write_csv(freq_table(TCCM$Theory,"Theory"), file.path(OUT_DIR,"freq_theory.csv"))
write_csv(freq_table(TCCM$Context,"Context"), file.path(OUT_DIR,"freq_context.csv"))
write_csv(freq_table(TCCM$Characteristics,"Characteristics"), file.path(OUT_DIR,"freq_characteristics.csv"))
write_csv(freq_table(TCCM$Methodology,"Methodology"), file.path(OUT_DIR,"freq_methodology.csv"))
write_csv(freq_table(TCCM$Moderators,"Moderators"), file.path(OUT_DIR,"freq_moderators.csv"))

message("✔ TCCM matrisi tamamlandı.")
