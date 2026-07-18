# ==============================================================================
# 04_vosviewer_export.R
# VOSviewer Keyword Co-occurrence Export (FINAL & STABLE)
# ==============================================================================
suppressPackageStartupMessages({
  library(bibliometrix)
  library(Matrix)
})

cat(">>> Starting VOSviewer export...\n")

# ------------------------------------------------------------------
# 1. Input / Output
# ------------------------------------------------------------------
DATA_IN  <- "data/interim/collection_screened.rds"
DATA_OUT <- "data/processed"

if (!dir.exists(DATA_OUT)) {
  dir.create(DATA_OUT, recursive = TRUE)
}

if (!file.exists(DATA_IN)) {
  stop("❌ collection_screened.rds was not found. Run 02_screening.R first.")
}

M <- readRDS(DATA_IN)

# ------------------------------------------------------------------
# 2. Defensive cleaning (convert all fields to character)
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
# 3. FALLBACK (If DE and ID are unavailable)
# ------------------------------------------------------------------
if (
  (!"DE" %in% names(M) || all(is.na(M$DE))) &&
  (!"ID" %in% names(M) || all(is.na(M$ID)))
) {
  cat("⚠ DE and ID are empty; keywords are being derived from the TI field.\n")
  M$DE <- as.character(M$TI)
}

# ------------------------------------------------------------------
# 4. Single active keyword field
# ------------------------------------------------------------------
use_id   <- ("ID" %in% names(M)) && any(nzchar(M$ID))
KW_FIELD <- if (use_id) "ID" else "DE"

cat("✅ Active keyword field:", KW_FIELD, "\n")

# For bibliometrix compatibility, keywords are always stored in DE.: keyword'ler DAİMA DE'de bulunur
if (KW_FIELD == "ID") {
  M$DE <- M$ID
}

if (all(is.na(M$DE))) {
  stop("❌ No usable keyword field is available.")
}

# ------------------------------------------------------------------
# 4.1 Minimum requirement for co-occurrence analysis
# ------------------------------------------------------------------
M <- M[grepl(";", M$DE), , drop = FALSE]

cat(">>> Records eligible for co-occurrence analysis", nrow(M), "\n")

if (nrow(M) < 2) {
  stop("❌ Co-occurrence analysis could not be generated: insufficient records.")
}

# ------------------------------------------------------------------
# 4.2 Actual co-occurrence filter
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
  stop("❌ No keyword pair occurs in more than one document.")
}

cat("✅ Valid keyword pairs:", length(valid_pairs), "\n")

# ------------------------------------------------------------------
# 4.3 Keyword frequency filter
# ------------------------------------------------------------------
kw_freq <- table(trimws(unlist(strsplit(M$DE, ";"))))
kw_freq <- sort(kw_freq, decreasing = TRUE)

valid_kw <- names(kw_freq[kw_freq >= 2])
cat(">>> Number of valid keywords:", length(valid_kw), "\n")

M$DE <- sapply(strsplit(M$DE, ";"), function(x) {
  x <- intersect(trimws(x), valid_kw)
  if (length(x) == 0) NA_character_ else paste(x, collapse = "; ")
})

M <- M[!is.na(M$DE), , drop = FALSE]

cat(">>> Records remaining after frequency filtering:", nrow(M), "\n")

if (nrow(M) < 2) {
  stop("❌ Insufficient data remain for co-occurrence analysis.")
}

# ------------------------------------------------------------------
# 5.Required data sanitization for bibliometrix
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
  cat(">>> Converting the sparse matrix to a dense matrix...\n")
  NetMatrix <- as.matrix(NetMatrix)
}

if (!is.matrix(NetMatrix)) {
  stop("❌ The network object is not a matrix.")
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

cat("✅ VOSviewer export completed.\n")
cat("📁 File:", OUT_FILE, "\n")
cat("➡ VOSviewer: Create → Map based on network data → Read from file\n")

# ------------------------------------------------------------------
# 9. NETWORK SUMMARY (QUALITY CHECK)
# ------------------------------------------------------------------

# Basic statistics
num_keywords <- nrow(NetMatrix)
num_links    <- sum(NetMatrix > 0) / 2
total_weight <- sum(NetMatrix) / 2

cat("🔹 Number of keywords    :", num_keywords, "\n")
cat("🔹 Number of links    :", num_links, "\n")
cat("🔹 Total link strength :", total_weight, "\n")

# The most central keywords (degree)
kw_strength <- rowSums(NetMatrix)
top_kw <- sort(kw_strength, decreasing = TRUE)[1:15]

cat("🔝Top 15 keywords by strength:\n")
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

cat("✅ Network summary written to file.\n")
cat("📁 File:", summary_file, "\n")

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

cat("✅ Heatmap file created.\n")
cat("📁 File:", heatmap_file, "\n")
