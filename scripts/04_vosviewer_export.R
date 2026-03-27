# 04_vosviewer_export.R

load("data/processed/biblio/NetMatrix_keywords.rda")

write.csv(NetMatrix,
          file = "data/processed/biblio/vosviewer_keywords.csv",
          row.names = TRUE)

message("✔ VOSviewer export tamamlandı.")
