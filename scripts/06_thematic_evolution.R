library(bibliometrix)
library(ggplot2)
library(dplyr)
library(readr)

# 1. Veri Okuma ve Hazırlık
df <- read_csv("data/interim/collection_screened.csv")
df <- as.data.frame(df) # bibliometrix için klasik data.frame şart

OUT_DIR <- "data/processed/thematic"
if (!dir.exists(OUT_DIR)) dir.create(OUT_DIR, recursive=TRUE)

# 2. Akıllı Yıl Kesme Mekanizması (Hata Giderici)
year_min <- min(df$PY, na.rm=TRUE)
year_max <- max(df$PY, na.rm=TRUE)

# Eğer yıl aralığı çok darsa (örn: sadece 2024 ve 2025 varsa) otomatik tek kırılım yap
if (year_max - year_min <= 1) {
  safe_breaks <- c(year_min, year_max)
} else {
  mid <- floor(year_min + (year_max - year_min) / 2)
  safe_breaks <- unique(sort(c(year_min, mid, year_max)))
}

# Kritik Kontrol: Eğer hala unique değilse manuel zorla
if (length(safe_breaks) < 2) {
  safe_breaks <- c(year_min, year_min + 1)
}

message(">> Kullanılan Yıl Kırılımları: ", paste(safe_breaks, collapse = " - "))

# 3. Tematik Evrim Analizi
# field="ID" (Keywords Plus) genelde WoS verilerinde daha yoğun sonuç verir
TE <- tryCatch({
  thematicEvolution(df, 
                    field = "ID", 
                    years = safe_breaks, 
                    n = 250, 
                    minFreq = 2)
}, error = function(e) {
  message("❌ Hata: Tematik evrim hesaplanamadı. Veri azlığı olabilir.")
  return(NULL)
})

# 4. Görselleştirme (Sankey Diyagramı)
if (!is.null(TE)) {
  png(file.path(OUT_DIR, "thematic_sankey.png"), width=2200, height=1400, res=220)
  # Sankey diyagramı üzerinde başlık ekleyelim
  plot(TE)
  dev.off()
  message("✔ Tematik evrim başarıyla tamamlandı.")
}
