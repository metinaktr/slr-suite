slr_thematic_breaks <- function(years) {
  years <- suppressWarnings(as.numeric(as.character(years)))
  years <- sort(unique(years[is.finite(years)]))
  if (!length(years)) stop("Thematic evolution has no valid publication years.")
  if (length(years) == 1L) {
    stop(structure(
      list(
        message = "Not applicable: thematic evolution requires at least two distinct publication years.",
        call = NULL
      ),
      class = c("slr_not_applicable", "error", "condition")
    ))
  }
  as.numeric(floor((min(years) + max(years)) / 2))
}
