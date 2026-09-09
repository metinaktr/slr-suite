normalize_tccm_text <- function(text) {
  text <- tidyr::replace_na(as.character(text), "")
  text <- stringr::str_to_lower(text)
  text <- stringi::stri_replace_all_regex(text, "[^\\p{L}\\p{N}\\s-]", " ")
  stringr::str_squish(text)
}

tccm_field_or_empty <- function(records, field) {
  if (field %in% names(records)) {
    return(tidyr::replace_na(as.character(records[[field]]), ""))
  }
  rep("", nrow(records))
}

build_tccm_record_text <- function(records) {
  normalize_tccm_text(paste(
    tccm_field_or_empty(records, "TI"),
    tccm_field_or_empty(records, "AB"),
    tccm_field_or_empty(records, "DE"),
    tccm_field_or_empty(records, "ID")
  ))
}

match_category <- function(record_text, dimension_dictionary) {
  if (length(record_text) != 1L) {
    stop("match_category() requires one record-level text string.", call. = FALSE)
  }
  if (!is.list(dimension_dictionary) || is.null(names(dimension_dictionary))) {
    stop("A TCCM dimension must contain named labels and pattern lists.", call. = FALSE)
  }

  record_text <- tidyr::replace_na(as.character(record_text), "")
  matched_labels <- names(dimension_dictionary)[
    vapply(
      dimension_dictionary,
      function(patterns) {
        if (!length(patterns)) return(FALSE)
        isTRUE(stringr::str_detect(
          record_text,
          stringr::regex(paste(patterns, collapse = "|"), ignore_case = TRUE)
        ))
      },
      logical(1)
    )
  ]

  if (!length(matched_labels)) return(NA_character_)
  paste(unique(matched_labels), collapse = "; ")
}

classify_tccm_records <- function(record_text, dictionaries) {
  if (!is.character(record_text)) {
    stop("record_text must be a character vector.", call. = FALSE)
  }
  if (!is.list(dictionaries) || is.null(names(dictionaries))) {
    stop("TCCM dictionaries must contain named dimensions.", call. = FALSE)
  }

  assignments <- lapply(dictionaries, function(dimension_dictionary) {
    vapply(
      seq_along(record_text),
      function(index) match_category(record_text[[index]], dimension_dictionary),
      character(1)
    )
  })

  assignments <- tibble::as_tibble(assignments, .name_repair = "check_unique")
  stopifnot(nrow(assignments) == length(record_text))
  assignments
}
