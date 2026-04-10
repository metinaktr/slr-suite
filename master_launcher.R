# ==============================================================================
# master_launcher.R - HARD RESET PROOF (TAM KORUMALI)
# ==============================================================================
# 1. LOG DİZİNİ VE KASA HAZIRLIĞI
if (!require("here")) install.packages("here")
library(here)

# Log klasörünü oluştur (Yoksa)
if (!dir.exists(here("logs"))) dir.create(here("logs"))

if (!exists(".slr_internal")) {
  .slr_internal <- new.env(parent = emptyenv())
  
  # LOG YAZMA FONKSİYONU
  .slr_internal$write_log <- function(message_text, type = "INFO") {
    log_file <- here("logs", paste0("slr_log_", Sys.Date(), ".txt"))
    timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    log_entry <- paste0("[", timestamp, "] [", type, "] ", message_text)
    
    # Hem dosyaya yaz hem konsola bas
    write(log_entry, file = log_file, append = TRUE)
  }
  
  # ÇALIŞTIRMA FONKSİYONU (Log Entegreli)
  .slr_internal$run_step <- function(script_path, desc) {
    full_path <- normalizePath(script_path, mustWork = FALSE)
    
    if (file.exists(full_path)) {
      start_msg <- paste0(desc, " başlatılıyor...")
      .slr_internal$write_log(start_msg, "START")
      message("\n>>> ", start_msg)
      
      tryCatch({
        source(full_path, local = FALSE, encoding = "UTF-8")
        success_msg <- paste0(desc, " başarıyla tamamlandı.")
        .slr_internal$write_log(success_msg, "SUCCESS")
        message("✔ ", success_msg, "\n")
      }, error = function(e) {
        err_msg <- paste0(desc, " HATASI: ", e$message)
        .slr_internal$write_log(err_msg, "ERROR")
        message("❌ ", err_msg)
      })
    } else {
      missing_msg <- paste0("Dosya bulunamadı: ", full_path)
      .slr_internal$write_log(missing_msg, "CRITICAL")
      message("❌ ", missing_msg)
    }
  }
  
  lockBinding(".slr_internal", .GlobalEnv)
}
# 1. EN ÜST DÜZEY KORUMA: Gizli bir ortam yarat ve onu Global'den ayır
if (!exists(".slr_internal")) {
  # Gizli ortamı yarat
  .slr_internal <- new.env(parent = emptyenv())
  
  # Sistemi kuran ana motoru bu gizli kasanın içine tanımla
  .slr_internal$setup <- function() {
    # Çalıştırma fonksiyonunu kasanın içine tanımla
    .slr_internal$run_step <- function(script_path, desc) {
      full_path <- normalizePath(script_path, mustWork = FALSE)
      if (file.exists(full_path)) {
        message("\n>>> ", desc, " başlatılıyor...")
        tryCatch({
          source(full_path, local = FALSE, encoding = "UTF-8")
          message("✔ ", desc, " başarıyla tamamlandı.\n")
        }, error = function(e) {
          message("❌ HATA (", desc, "): ", e$message)
        })
      } else {
        message("❌ Hata: Dosya bulunamadı! Yol: ", full_path)
      }
    }
  }
  
  # Kurulumu bir kez yap
  .slr_internal$setup()
  
  # Kasayı kilitli hale getir (rm(list=ls()) ile silinemez)
  lockBinding(".slr_internal", .GlobalEnv)
}

# 2. AYARLAR VE DİZİN
options(rstudioapi.check.presence = FALSE)
if (!require("here")) install.packages("here")
library(here)

# 3. ANA DÖNGÜ
# ------------------------------------------------------------------------------
while (TRUE) {
  # KRİTİK: Hafıza tamamen silinse bile .slr_internal gizli olduğu için kalır.
  # Fonksiyonu doğrudan kasanın içinden çağırıyoruz:
  run_step <- .slr_internal$run_step
  
  cat("\n======================================================\n")
  cat("   SLR-SUITE: AKADEMİK İŞ AKIŞI YÖNETİCİSİ\n")
  cat("======================================================\n")
  cat(" 1 : [CI/TEST] CI Testlerini Çalıştır\n")
  cat(" 2 : [ADIM 01] Veri Edinme & Tekilleştirme\n")
  cat(" 3 : [ADIM 02] Tarama & Filtreleme (Screening)\n")
  cat(" 4 : [ADIM 03] Bibliyometrik Analiz\n")
  cat(" 5 : [ADIM 04] VOSviewer Dışa Aktarım\n")
  cat(" 6 : [ADIM 05] TCCM Matrisi Oluşturma\n")
  cat(" 7 : [ADIM 06] Tematik Evrim Analizi\n")
  cat(" 8 : [ADIM 07] PRISMA 2020 Flow Diagram\n")
  cat(" 9 : [ADIM 08] Thesaurus\n")
  cat(" 10 : [TÜMÜ]    Tüm Pipeline'ı Baştan Sona Çalıştır\n")
  cat(" 0 : Çıkış\n")
  cat("======================================================\n")
  
  cat("Seçiminiz: ")
  con <- if (interactive()) stdin() else "stdin"
  line <- readLines(con, n = 1)
  
  if (length(line) == 0 || line == "") next
  choice <- as.integer(line)
  
  if (is.na(choice)) next
  
  if (choice == 1) {
    run_step(here("test_all.R"), "Sistem CI Testleri")
  } else if (choice == 2) {
    run_step(here("scripts", "01_acquire_and_dedupe.R"), "Veri Edinme")
  } else if (choice == 3) {
    run_step(here("scripts", "02_screening.R"), "Screening")
  } else if (choice == 4) {
    run_step(here("scripts", "03_biblio_analysis.R"), "Bibliyometrik Analiz")
  } else if (choice == 5) {
     run_step(here("scripts", "04_vosviewer_export.R"), "VOSviewer Export")
  } else if (choice == 6) {
     run_step(here("scripts", "05_tccm_matrix.R"), "TCCM Matrisi")
  } else if (choice == 7) {
    run_step(here("scripts", "06_thematic_evolution.R"), "Tematik Evrim")
  } else if (choice == 8) {
    run_step(here("scripts", "09_prisma_flow.R"), "Prisma")  
  } else if (choice == 9) {
    run_step(here("scripts", "vos_thesaurus.R"), "Thesaurus")    
  } else if (choice == 10) {
    step_files <- list.files(here("scripts"), pattern = "^0.*\\.R$", full.names = TRUE)
    for(s in sort(step_files)) run_step(s, basename(s))
    message("⭐ Tüm süreç başarıyla tamamlandı!")
  } else if (choice == 0) {
    rm(list = ls()); gc()
    message("Güle güle akademisyen peer!")
    break
  }
}
