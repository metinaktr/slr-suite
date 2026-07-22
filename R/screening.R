read_screening_criteria <- function(path) {
  if (!requireNamespace("yaml", quietly = TRUE)) {
    stop("The yaml package is required to read screening criteria.", call. = FALSE)
  }
  if (!file.exists(path)) {
    stop("Screening criteria file was not found: ", path, call. = FALSE)
  }
  criteria <- yaml::read_yaml(path)
  if (is.null(criteria$fields) || is.null(criteria$required_fields)) {
    stop("Screening criteria must define fields and required_fields.", call. = FALSE)
  }
  criteria
}

screen_records <- function(records, criteria) {
  fields <- unlist(criteria$fields, use.names = TRUE)
  required <- unlist(criteria$required_fields, use.names = FALSE)
  missing_mappings <- setdiff(required, names(fields))
  if (length(missing_mappings)) {
    stop("Required field mappings are missing: ", paste(missing_mappings, collapse = ", "), call. = FALSE)
  }

  reasons <- rep(NA_character_, nrow(records))
  add_reason <- function(current_reasons, hit, reason) {
    active <- hit & !is.na(hit)
    current_reasons[active] <- ifelse(
      is.na(current_reasons[active]), reason,
      paste(current_reasons[active], reason, sep = "; ")
    )
    current_reasons
  }

  for (field_name in required) {
    column <- unname(fields[[field_name]])
    if (!column %in% names(records)) {
      reasons <- add_reason(reasons, rep(TRUE, nrow(records)), paste0("missing required column: ", column))
    } else {
      values <- trimws(as.character(records[[column]]))
      reasons <- add_reason(reasons, is.na(values) | !nzchar(values), paste0("missing ", field_name))
    }
  }

  language_column <- unname(fields[["language"]])
  allowed_languages <- unlist(criteria$include$languages, use.names = FALSE)
  if (!is.null(language_column) && language_column %in% names(records) && length(allowed_languages)) {
    language <- trimws(as.character(records[[language_column]]))
    known <- !is.na(language) & nzchar(language)
    reasons <- add_reason(reasons, known & !tolower(language) %in% tolower(allowed_languages), "language not included")
  }

  type_column <- unname(fields[["document_type"]])
  if (!is.null(type_column) && type_column %in% names(records)) {
    document_type <- as.character(records[[type_column]])
    included_types <- unlist(criteria$include$document_types, use.names = FALSE)
    excluded_types <- unlist(criteria$exclude$document_types, use.names = FALSE)
    known <- !is.na(document_type) & nzchar(trimws(document_type))
    if (length(included_types)) {
      reasons <- add_reason(reasons, known & !tolower(document_type) %in% tolower(included_types), "document type not included")
    }
    if (length(excluded_types)) {
      reasons <- add_reason(reasons, known & tolower(document_type) %in% tolower(excluded_types), "excluded document type")
    }
  }

  year_column <- unname(fields[["year"]])
  if (!is.null(year_column) && year_column %in% names(records)) {
    year <- suppressWarnings(as.integer(records[[year_column]]))
    if (!is.null(criteria$include$year$minimum)) {
      reasons <- add_reason(reasons, !is.na(year) & year < as.integer(criteria$include$year$minimum), "year below minimum")
    }
    if (!is.null(criteria$include$year$maximum)) {
      reasons <- add_reason(reasons, !is.na(year) & year > as.integer(criteria$include$year$maximum), "year above maximum")
    }
  }

  text_columns <- intersect(unname(fields[c("title", "abstract")]), names(records))
  combined_text <- if (length(text_columns)) {
    apply(records[text_columns], 1, function(x) paste(x, collapse = " "))
  } else {
    rep("", nrow(records))
  }
  excluded_patterns <- unlist(criteria$exclude$text_patterns, use.names = FALSE)
  if (length(excluded_patterns)) {
    pattern <- paste(excluded_patterns, collapse = "|")
    reasons <- add_reason(reasons, grepl(pattern, combined_text, ignore.case = TRUE, perl = TRUE), "excluded text pattern")
  }

  records$SCREENING_DECISION <- ifelse(is.na(reasons), "include", "exclude")
  records$SCREENING_REASON <- ifelse(is.na(reasons), "configured criteria satisfied", reasons)
  records
}
