normalize_document_type <- function(x) {
  original <- trimws(as.character(x))
  normalized <- tolower(original)
  normalized <- gsub("[_-]+", " ", normalized)
  normalized <- gsub("\\s*;\\s*early access\\s*$", "", normalized)
  normalized <- gsub("\\s+", " ", normalized)

  labels <- c(
    "article" = "Article",
    "review" = "Review",
    "review article" = "Review",
    "proceedings paper" = "Proceedings Paper",
    "conference paper" = "Proceedings Paper",
    "book chapter" = "Book Chapter",
    "editorial material" = "Editorial Material",
    "editorial" = "Editorial Material",
    "letter" = "Letter",
    "meeting abstract" = "Meeting Abstract",
    "correction" = "Correction"
  )

  result <- unname(labels[normalized])
  unknown <- is.na(result) & !is.na(original) & nzchar(original)
  result[unknown] <- tools::toTitleCase(normalized[unknown])
  result[is.na(original) | !nzchar(original)] <- NA_character_
  result
}
