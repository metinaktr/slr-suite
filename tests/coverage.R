root <- getwd()

stopifnot(isTRUE(slr_assert(TRUE, "ok")))
validation_error <- tryCatch(slr_assert(FALSE, "invalid"), error = identity)
stopifnot(inherits(validation_error, "slr_validation_error"))

wrapped <- slr_wrap_error(simpleError("parent"), "coverage")
stopifnot(inherits(wrapped, "slr_step_error"), wrapped$step == "coverage")

stopifnot(slr_project_root() == normalizePath(root, winslash = "/"))
stopifnot(length(slr_steps(root)) >= 9L)
stopifnot(isTRUE(slr_check_dependencies("base")))
dependency_error <- tryCatch(slr_check_dependencies("not_a_real_package"), error = identity)
stopifnot(inherits(dependency_error, "slr_dependency_error"))

valid_menu_input <- textConnection("2")
stopifnot(slr_menu_select(c("Run", "Exit"), input = valid_menu_input) == 2L)
close(valid_menu_input)

retry_menu_input <- textConnection(c("invalid", "1"))
stopifnot(slr_menu_select(c("Run", "Exit"), input = retry_menu_input) == 1L)
close(retry_menu_input)

empty_menu_input <- textConnection(character())
stopifnot(slr_menu_select(c("Run", "Exit"), input = empty_menu_input) == 2L)
close(empty_menu_input)

workspace <- tempfile("coverage-pipeline-")
dir.create(file.path(workspace, "scripts"), recursive = TRUE)
file.create(file.path(workspace, "slr-suite.Rproj"))
writeLines("writeLines('ok', 'output.txt')", file.path(workspace, "scripts", "01_ok.R"))
old <- setwd(workspace)
result <- slr_run_step(file.path(workspace, "scripts", "01_ok.R"), root = workspace)
stopifnot(result$status == "success", file.exists("output.txt"))

writeLines("stop('expected')", file.path(workspace, "scripts", "02_fail.R"))
step_error <- tryCatch(
  slr_run_step(file.path(workspace, "scripts", "02_fail.R"), root = workspace),
  error = identity
)
stopifnot(inherits(step_error, "slr_step_error"))
setwd(old)

normalized_types <- normalize_document_type(c(
  "Article; Early Access",
  "review article",
  "conference-paper",
  "EDITORIAL",
  "custom_type",
  "",
  NA_character_
))
stopifnot(
  identical(
    normalized_types,
    c(
      "Article",
      "Review",
      "Proceedings Paper",
      "Editorial Material",
      "Custom Type",
      NA_character_,
      NA_character_
    )
  )
)

criteria_path <- file.path(root, "config", "screen_criteria.yaml")
criteria <- read_screening_criteria(criteria_path)
missing_criteria_error <- tryCatch(
  read_screening_criteria(tempfile("missing-criteria-")),
  error = identity
)
stopifnot(inherits(missing_criteria_error, "error"))

invalid_criteria_path <- tempfile(fileext = ".yaml")
yaml::write_yaml(list(version = 1), invalid_criteria_path)
invalid_criteria_error <- tryCatch(
  read_screening_criteria(invalid_criteria_path),
  error = identity
)
stopifnot(inherits(invalid_criteria_error, "error"))

criteria$include$year$minimum <- 2020
criteria$include$year$maximum <- 2024
criteria$exclude$text_patterns <- c("retracted", "withdrawn")
screening_records <- data.frame(
  TI = c("Eligible", "", "French", "Editorial", "Retracted study", "Future"),
  AB = c("Abstract", "Abstract", "Abstract", "Abstract", "Abstract", "Abstract"),
  LA = c("English", "English", "French", "English", "English", "Turkish"),
  DT = c("Article", "Article", "Review", "Editorial Material", "Article", "Proceedings Paper"),
  PY = c(2022, 2022, 2022, 2022, 2019, 2025),
  stringsAsFactors = FALSE
)
screened <- screen_records(screening_records, criteria)
stopifnot(
  identical(
    screened$SCREENING_DECISION,
    c("include", "exclude", "exclude", "exclude", "exclude", "exclude")
  ),
  grepl("missing title", screened$SCREENING_REASON[2]),
  grepl("language not included", screened$SCREENING_REASON[3]),
  grepl("document type not included", screened$SCREENING_REASON[4]),
  grepl("excluded document type", screened$SCREENING_REASON[4]),
  grepl("year below minimum", screened$SCREENING_REASON[5]),
  grepl("excluded text pattern", screened$SCREENING_REASON[5]),
  grepl("year above maximum", screened$SCREENING_REASON[6])
)

missing_column_records <- data.frame(AB = "Abstract", stringsAsFactors = FALSE)
missing_column_result <- screen_records(missing_column_records, criteria)
stopifnot(
  missing_column_result$SCREENING_DECISION == "exclude",
  grepl("missing required column", missing_column_result$SCREENING_REASON)
)

invalid_mapping <- criteria
invalid_mapping$required_fields <- c("title", "abstract", "doi")
mapping_error <- tryCatch(
  screen_records(screening_records, invalid_mapping),
  error = identity
)
stopifnot(inherits(mapping_error, "error"))

dictionary_path <- file.path(root, "config", "tccm_dictionaries.yaml")
dictionaries <- read_tccm_dictionaries(dictionary_path)
stopifnot(length(dictionaries) >= 4L, "Theory" %in% names(dictionaries))

missing_dictionary_error <- tryCatch(
  read_tccm_dictionaries(tempfile("missing-dictionary-")),
  error = identity
)
stopifnot(inherits(missing_dictionary_error, "error"))

empty_dictionary_path <- tempfile(fileext = ".yaml")
yaml::write_yaml(list(version = 1, dimensions = list()), empty_dictionary_path)
empty_dictionary_error <- tryCatch(
  read_tccm_dictionaries(empty_dictionary_path),
  error = identity
)
stopifnot(inherits(empty_dictionary_error, "error"))

invalid_dictionary_path <- tempfile(fileext = ".yaml")
yaml::write_yaml(
  list(version = 1, dimensions = list(Theory = list())),
  invalid_dictionary_path
)
invalid_dictionary_error <- tryCatch(
  read_tccm_dictionaries(invalid_dictionary_path),
  error = identity
)
stopifnot(inherits(invalid_dictionary_error, "error"))
