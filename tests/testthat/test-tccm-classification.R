source(file.path(slr_project_root(), "R", "tccm.R"), encoding = "UTF-8")

test_that("TCCM classification is applied independently to every record", {
  dictionaries <- list(
    Theory = list(Utilitarian = "utilitarian", Deontological = "deontolog"),
    Context = list(Tourism = "tourism", Healthcare = "healthcare")
  )
  records <- data.frame(
    TI = c("Utilitarian tourism", "Deontological healthcare", "Unrelated title"),
    AB = c(NA, "A duty-based study", "No configured concepts"),
    DE = c("travel", NA, NA),
    ID = c(NA, "hospital", NA),
    stringsAsFactors = FALSE
  )

  record_text <- build_tccm_record_text(records)
  result <- classify_tccm_records(record_text, dictionaries)

  expect_equal(nrow(result), nrow(records))
  expect_equal(result$Theory, c("Utilitarian", "Deontological", NA_character_))
  expect_equal(result$Context, c("Tourism", "Healthcare", NA_character_))
})

test_that("one record can retain multiple labels without affecting another record", {
  dictionary <- list(
    Ethics = "ethic",
    Privacy = "privacy",
    Safety = "safety"
  )

  expect_equal(
    match_category("ethical privacy practices", dictionary),
    "Ethics; Privacy"
  )
  expect_equal(match_category("safety engineering", dictionary), "Safety")
  expect_true(is.na(match_category("unmatched record", dictionary)))
})

test_that("match_category rejects a multi-record text vector", {
  dictionary <- list(Tourism = "tourism")

  expect_error(
    match_category(c("tourism record", "healthcare record"), dictionary),
    "one record-level text string",
    fixed = TRUE
  )
})

test_that("missing bibliographic fields are converted to empty record text", {
  records <- data.frame(TI = c("Tourism", NA), stringsAsFactors = FALSE)

  expect_equal(build_tccm_record_text(records), c("tourism", ""))
})
