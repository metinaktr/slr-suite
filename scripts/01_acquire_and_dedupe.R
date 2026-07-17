# ==============================================================================
# 01_acquire_and_dedupe.R (WoS Plaintext Etiketli Format İçin)
# ==============================================================================
suppressPackageStartupMessages({
  library(bibliometrix)
  library(dplyr)
  library(readr)
  library(here)
})

cat(">>> 01_acquire_and_dedupe başlatıldı\n")


# --------------------------------------------------
# 1. Mod Tespiti (CI mi Yerel mi?)
# --------------------------------------------------
CI_MODE <- tolower(Sys.getenv("CI")) == "true"


# --------------------------------------------------
# 2. DİNAMİK DİZİNLER (İŞİN ÖZÜ BURASI)
# --------------------------------------------------
ROOT_DIR    <- here::here()
RAW_DIR     <- here::here("data", "raw")
INTERIM_DIR <- here::here("data", "interim")


cat(">> Adım 1: Plain Text (Etiketli) Veri işleniyor...\n")

cat(">>> Proje kökü:", ROOT_DIR, "\n")
cat(">>> RAW dizini :", RAW_DIR, "\n")


if (!dir.exists(INTERIM_DIR)) {
  dir.create(INTERIM_DIR, recursive = TRUE)
}


# 2. Dosya Listeleme
# ----------------------------
input_files <- list.files(
  "data/raw",
  pattern = "\\.(txt|csv|bib|ris)$",
  full.names = TRUE
)

if (length(input_files) == 0) {
  stop("❌ CI error: No input files found in data/raw/")
}

# 3. WoS Plaintext Okuma Fonksiyonu
# ----------------------------
read_slr_data <- function(file_path) {
  message(">> Okunuyor: ", basename(file_path))
  
  # Verinin ilk satırına bakarak formatı anlayalım
  first_line <- readLines(file_path, n = 1, warn = FALSE)
  
  # Eğer dosya "FN " (Web of Science etiketi) ile başlıyorsa bibliometrix kullan
  if (grepl("^FN ", first_line)) {
    # convert2df: Alt alta olan etiketli satırları (TI, AU, AB vb.) 
    # tek bir satırda birleştirerek tabloya dönüştürür [cite: 1, 8, 33, 519]
    df <- convert2df(file = file_path, dbsource = "wos", format = "plaintext")
  } else {
    # Eğer dosya zaten tabloysa (CSV) standart oku
    df <- read_csv(file_path, col_types = cols(.default = "c"), trim_ws = TRUE)
  }
  
  # Sütun isimlerini büyük harf yap (UT, TI, DI standardı için)
  names(df) <- toupper(trimws(names(df)))
  return(df)
}

# 4. Verileri Birleştir ve Tekilleştir
# ----------------------------
# bibliometrix bazen list-column dönebilir, bind_rows ile düzeltiyoruz
df_list <- lapply(input_files, read_slr_data)
merged <- bind_rows(lapply(df_list, as.data.frame))

# ID Sütunu Belirleme (WoS Plaintext sonrası UT mutlaka oluşur )
priority_cols <- c("UT", "DI", "TI")
id_col <- intersect(priority_cols, names(merged))[1]

if (is.na(id_col)) {
  cat("Mevcut Sütunlar:", paste(names(merged), collapse = ", "), "\n")
  stop("❌ Hata: Kayıtları ayırmak için gereken kimlik sütunları bulunamadı.")
}

cat(">> Tekilleştirme anahtarı:", id_col, "\n")

# Tekilleştirme: Mükerrer makaleleri temizle
dedup <- merged %>%
  filter(!is.na(.data[[id_col]])) %>%
  distinct(.data[[id_col]], .keep_all = TRUE)

# 5. Kayıt
# ----------------------------
write_csv(dedup, file.path(INTERIM_DIR, "cleaned_dedup.csv"))

cat("✅ İşlem Başarıyla Tamamlandı!\n")
cat("- Orijinal kayıt sayısı:", nrow(merged), "\n")
cat("- Tekilleştirilmiş (Benzersiz) kayıt sayısı:", nrow(dedup), "\n")
cat("- Kayıt konumu: data/interim/cleaned_dedup.csv\n")
