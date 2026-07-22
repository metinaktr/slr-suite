source(file.path(slr_project_root(), "R", "screening.R"))
source(file.path(slr_project_root(), "R", "document_types.R"))
source(file.path(slr_project_root(), "R", "dictionaries.R"))

test_that("document types are normalized while unknown values are retained", {
  input <- c("Article; Early Access", "review article", "EDITORIAL", "Custom Type", NA)
  expect_equal(
    normalize_document_type(input),
    c("Article", "Review", "Editorial Material", "Custom Type", NA_character_)
  )
})

test_that("YAML screening criteria produce auditable decisions", {
  criteria <- read_screening_criteria(file.path(slr_project_root(), "config", "screen_criteria.yaml"))
  records <- data.frame(
    TI = c("Eligible study", "", "Editorial note", "French study"),
    AB = c("Abstract", "Abstract", "Abstract", "Abstract"),
    LA = c("English", "English", "English", "French"),
    DT = c("Article", "Article", "Editorial Material", "Article"),
    PY = c("2024", "2024", "2024", "2024"),
    stringsAsFactors = FALSE
  )
  result <- screen_records(records, criteria)
  expect_equal(result$SCREENING_DECISION, c("include", "exclude", "exclude", "exclude"))
  expect_match(result$SCREENING_REASON[2], "missing title")
  expect_match(result$SCREENING_REASON[3], "document type")
  expect_match(result$SCREENING_REASON[4], "language")
})

test_that("user dictionary loads from YAML", {
  dictionary <- read_tccm_dictionaries(
    file.path(slr_project_root(), "config", "tccm_dictionaries.yaml")
  )
  expect_true(all(c("Theory", "Context", "Characteristics", "Methodology") %in% names(dictionary)))
  expect_true("Utilitarian Ethics" %in% names(dictionary$Theory))
})

test_that("multiple synthetic datasets exercise distinct screening outcomes", {
  root <- slr_project_root()
  criteria <- read_screening_criteria(file.path(root, "config", "screen_criteria.yaml"))
  paths <- file.path(root, "tests", "fixtures", c("screening_dataset_a.csv", "screening_dataset_b.csv"))
  results <- lapply(paths, function(path) screen_records(read.csv(path), criteria))
  expect_equal(vapply(results, nrow, integer(1)), c(3L, 3L))
  expect_equal(sum(results[[1]]$SCREENING_DECISION == "include"), 1L)
  expect_equal(sum(results[[2]]$SCREENING_DECISION == "include"), 2L)
})
