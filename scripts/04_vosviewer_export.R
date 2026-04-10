# ==============================================================================
# 04_vosviewer_export.R
# VOSviewer Keyword Co-occurrence Export (FINAL & STABLE)
# ==============================================================================

rm(list = ls())

suppressPackageStartupMessages({
  library(bibliometrix)
  library(Matrix)
})

cat(">>> VOSviewer Export başlatılıyor...\n")

# ------------------------------------------------------------------
# 1. Girdi / Çıktı
# ------------------------------------------------------------------
DATA_IN  <- "data/interim/collection_screened.rds"
DATA_OUT <- "data/processed"

if (!dir.exists(DATA_OUT)) {
  dir.create(DATA_OUT, recursive = TRUE)
}

if (!file.exists(DATA_IN)) {
  stop("❌ collection_screened.rds bulunamadı. Önce 02_screening.R çalıştırın.")
}

M <- readRDS(DATA_IN)

# ------------------------------------------------------------------
# 2. KORUYUCU TEMİZLİK (HER ŞEY CHARACTER)
# ------------------------------------------------------------------
safe_char <- function(x, n) {
  if (is.null(x)) return(rep(NA_character_, n))
  if (is.list(x)) {
    x <- vapply(x, function(z) {
      if (length(z) == 0) NA_character_
      else paste(z, collapse = "; ")
    }, FUN.VALUE = character(1))
  }
  if (is.factor(x)) x <- as.character(x)
  if (!is.character(x)) x <- rep(NA_character_, n)
  if (length(x) != n) x <- rep(NA_character_, n)
  x
}

n <- nrow(M)
if ("DE" %in% names(M)) M$DE <- safe_char(M$DE, n)
if ("ID" %in% names(M)) M$ID <- safe_char(M$ID, n)

# ------------------------------------------------------------------
# 3. FALLBACK (DE + ID yoksa)
# ------------------------------------------------------------------
if (
  (!"DE" %in% names(M) || all(is.na(M$DE))) &&
  (!"ID" %in% names(M) || all(is.na(M$ID)))
) {
  cat("⚠ DE ve ID boş → TI alanından keyword türetiliyor\n")
  M$DE <- as.character(M$TI)
}

# ------------------------------------------------------------------
# 4. TEK AKTİF KEYWORD ALANI (TEK VE SON)
# ------------------------------------------------------------------
use_id   <- ("ID" %in% names(M)) && any(nzchar(M$ID))
KW_FIELD <- if (use_id) "ID" else "DE"

cat("✅ Aktif keyword alanı:", KW_FIELD, "\n")

# bibliometrix güvenliği: keyword'ler DAİMA DE'de bulunur
if (KW_FIELD == "ID") {
  M$DE <- M$ID
}

if (all(is.na(M$DE))) {
  stop("❌ Kullanılabilir keyword alanı yok.")
}

# ------------------------------------------------------------------
# 4.1 CO-OCCURRENCE İÇİN ASGARİ ŞART
# ------------------------------------------------------------------
M <- M[grepl(";", M$DE), , drop = FALSE]

cat(">>> Co-occurrence için uygun kayıt:", nrow(M), "\n")

if (nrow(M) < 2) {
  stop("❌ Co-occurrence üretilemedi: Yetersiz kayıt.")
}

# ------------------------------------------------------------------
# 4.2 GERÇEK CO-OCCURRENCE FİLTRESİ
# ------------------------------------------------------------------
pairs <- unlist(
  lapply(strsplit(M$DE, ";"), function(x) {
    x <- trimws(x)
    if (length(x) < 2) return(NULL)
    apply(combn(x, 2), 2, paste, collapse = "___")
  })
)

pair_freq  <- table(pairs)
valid_pairs <- names(pair_freq[pair_freq >= 2])

if (length(valid_pairs) == 0) {
  stop("❌ Aynı keyword çifti birden fazla dokümanda tekrar etmiyor.")
}

cat("✅ Geçerli keyword çiftleri:", length(valid_pairs), "\n")

# ------------------------------------------------------------------
# 4.3 KEYWORD FREKANS FİLTRESİ
# ------------------------------------------------------------------
kw_freq <- table(trimws(unlist(strsplit(M$DE, ";"))))
kw_freq <- sort(kw_freq, decreasing = TRUE)

valid_kw <- names(kw_freq[kw_freq >= 2])
cat(">>> Geçerli keyword sayısı:", length(valid_kw), "\n")

M$DE <- sapply(strsplit(M$DE, ";"), function(x) {
  x <- intersect(trimws(x), valid_kw)
  if (length(x) == 0) NA_character_ else paste(x, collapse = "; ")
})

M <- M[!is.na(M$DE), , drop = FALSE]

cat(">>> Frekans filtresi sonrası kayıt:", nrow(M), "\n")

if (nrow(M) < 2) {
  stop("❌ Co-occurrence için yeterli veri kalmadı.")
}

# ------------------------------------------------------------------
# 5. BIBLIOMETRIX İÇİN ZORUNLU STERİLİZASYON
# ------------------------------------------------------------------
M$DE <- as.character(M$DE)
M$DE <- unname(M$DE)
M$DE <- trimws(M$DE)
M$DE[is.na(M$DE)] <- ""
M <- M[nzchar(M$DE), , drop = FALSE]

stopifnot(is.data.frame(M))
stopifnot(is.character(M$DE))

# ------------------------------------------------------------------
# 6. KEYWORD CO-OCCURRENCE MATRIX
# ------------------------------------------------------------------
# ------------------------------------------------------------------
# 6. KEYWORD CO-OCCURRENCE MATRIX (MANUAL & STABLE)
# ------------------------------------------------------------------

keywords_list <- strsplit(M$DE, ";")

# Trim
keywords_list <- lapply(keywords_list, trimws)

# Unique keyword set
all_kw <- sort(unique(unlist(keywords_list)))

# Empty matrix
NetMatrix <- matrix(
  0,
  nrow = length(all_kw),
  ncol = length(all_kw),
  dimnames = list(all_kw, all_kw)
)

# Fill co-occurrences
for (kw in keywords_list) {
  if (length(kw) < 2) next
  cmb <- combn(kw, 2)
  for (i in seq_len(ncol(cmb))) {
    a <- cmb[1, i]
    b <- cmb[2, i]
    NetMatrix[a, b] <- NetMatrix[a, b] + 1
    NetMatrix[b, a] <- NetMatrix[b, a] + 1
  }
}

# ------------------------------------------------------------------
# 7. Sparse → Dense (VOSviewer)
# ------------------------------------------------------------------
if (inherits(NetMatrix, "dgCMatrix")) {
  cat(">>> Sparse → dense matrix dönüştürülüyor...\n")
  NetMatrix <- as.matrix(NetMatrix)
}

if (!is.matrix(NetMatrix)) {
  stop("❌ Network matrisi matrix değil.")
}

# ------------------------------------------------------------------
# 8. EXPORT
# ------------------------------------------------------------------
OUT_FILE <- file.path(DATA_OUT, "vos_keywords_cooccurrence.txt")

write.table(
  NetMatrix,
  file      = OUT_FILE,
  sep       = "\t",
  col.names = NA,
  quote     = FALSE
)

cat("✅ VOSviewer export TAMAMLANDI\n")
cat("📁 Dosya:", OUT_FILE, "\n")
cat("➡ VOSviewer: Create → Map based on network data → Read from file\n")

# ------------------------------------------------------------------
# 9. NETWORK SUMMARY (QUALITY CHECK)
# ------------------------------------------------------------------

# Temel istatistikler
num_keywords <- nrow(NetMatrix)
num_links    <- sum(NetMatrix > 0) / 2
total_weight <- sum(NetMatrix) / 2

cat("🔹 Keyword sayısı      :", num_keywords, "\n")
cat("🔹 Bağlantı sayısı     :", num_links, "\n")
cat("🔹 Toplam bağ ağırlığı :", total_weight, "\n")

# En merkez keyword’ler (degree)
kw_strength <- rowSums(NetMatrix)
top_kw <- sort(kw_strength, decreasing = TRUE)[1:15]

cat("🔝 En güçlü 15 keyword:\n")
print(top_kw)

# ------------------------------------------------------------------
# 10. QUICK HEATMAP (OPTIONAL VISUAL CHECK)
# ------------------------------------------------------------------

heatmap(
  NetMatrix,
  Rowv = NA,
  Colv = NA,
  scale = "none",
  col = colorRampPalette(c("white", "darkred"))(100),
  margins = c(6, 6)
)

# ------------------------------------------------------------------
# 11. THRESHOLD SENSITIVITY (OPTIONAL)
# ------------------------------------------------------------------

MIN_EDGE <- 2   # 2, 3 veya 4 denenebilir

NetMatrix_thr <- NetMatrix
NetMatrix_thr[NetMatrix_thr < MIN_EDGE] <- 0

cat("🔸 Eşik sonrası bağ sayısı:",
    sum(NetMatrix_thr > 0) / 2, "\n")

# ------------------------------------------------------------------
# 12. EDGE LIST EXPORT (OPTIONAL)
# ------------------------------------------------------------------

edges <- which(NetMatrix > 0, arr.ind = TRUE)
edges <- edges[edges[,1] < edges[,2], ]

edge_list <- data.frame(
  Source = rownames(NetMatrix)[edges[,1]],
  Target = colnames(NetMatrix)[edges[,2]],
  Weight = NetMatrix[edges]
)

write.table(
  edge_list,
  file = file.path(DATA_OUT, "vos_keywords_edges.txt"),
  sep = "\t",
  row.names = FALSE,
  col.names = TRUE,
  quote = FALSE
)

cat("✅ Edge list export edildi\n")


# ------------------------------------------------------------------
# 9. NETWORK SUMMARY → FILE OUTPUT
# ------------------------------------------------------------------

summary_file <- file.path(DATA_OUT, "network_summary.txt")

num_keywords <- nrow(NetMatrix)
num_links    <- sum(NetMatrix > 0) / 2
total_weight <- sum(NetMatrix) / 2

kw_strength <- rowSums(NetMatrix)
top_kw <- sort(kw_strength, decreasing = TRUE)[1:20]

sink(summary_file)

cat("NETWORK SUMMARY\n")
cat("=============================\n")
cat("Keyword sayısı           :", num_keywords, "\n")
cat("Bağlantı sayısı          :", num_links, "\n")
cat("Toplam bağ ağırlığı      :", total_weight, "\n\n")

cat("En güçlü 20 keyword (strength):\n")
for (i in seq_along(top_kw)) {
  cat(names(top_kw)[i], ":", top_kw[i], "\n")
}

sink()

cat("✅ Network summary dosyaya yazıldı\n")
cat("📁 Dosya:", summary_file, "\n")

# ------------------------------------------------------------------
# 10. HEATMAP EXPORT (PNG)
# ------------------------------------------------------------------

heatmap_file <- file.path(DATA_OUT, "keyword_cooccurrence_heatmap.png")

png(
  filename = heatmap_file,
  width = 2000,
  height = 2000,
  res = 200
)

heatmap(
  NetMatrix,
  Rowv = NA,
  Colv = NA,
  scale = "none",
  col = colorRampPalette(c("white", "darkred"))(100),
  margins = c(6, 6)
)

dev.off()

cat("✅ Heatmap dosyası oluşturuldu\n")
cat("📁 Dosya:", heatmap_file, "\n")
