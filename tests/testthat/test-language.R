test_that("executable R sources use portable English text", {
  source_files <- list.files(
    c("R", "scripts", "ci"),
    pattern = "[.]R$",
    recursive = TRUE,
    full.names = TRUE
  )
  source_files <- c(source_files, "master_launcher.R", "test_all.R")
  source_files <- unique(source_files[file.exists(source_files)])

  turkish_terms <- c(
    "başlat", "adım", "işlem", "kayıt", "çıktı", "sözlük", "hata",
    "bulunamadı", "önce", "tamamlandı", "oluşturuldu", "anahtar",
    "yükle", "tekilleştir", "dizin", "okuma fonksiyonu"
  )

  violations <- character()
  for (path in source_files) {
    lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
    for (line_number in seq_along(lines)) {
      line <- lines[[line_number]]
      has_non_ascii <- grepl("[^\\x01-\\x7F]", line, perl = TRUE)
      has_turkish_text <- any(vapply(
        turkish_terms,
        grepl,
        logical(1),
        x = tolower(line),
        fixed = TRUE
      ))
      if (has_non_ascii || has_turkish_text) {
        violations <- c(violations, sprintf("%s:%d", path, line_number))
      }
    }
  }

  expect_length(
    violations,
    0,
    info = paste("Non-portable or non-English R source text:", paste(violations, collapse = ", "))
  )
})
