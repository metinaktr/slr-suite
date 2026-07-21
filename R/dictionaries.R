read_tccm_dictionaries <- function(path) {
  if (!requireNamespace("yaml", quietly = TRUE)) {
    stop("The yaml package is required to read the TCCM dictionary.", call. = FALSE)
  }
  if (!file.exists(path)) {
    stop("TCCM dictionary file was not found: ", path, call. = FALSE)
  }
  dictionary <- yaml::read_yaml(path)
  if (is.null(dictionary$dimensions) || !length(dictionary$dimensions)) {
    stop("The TCCM dictionary must contain at least one dimension.", call. = FALSE)
  }
  invalid <- vapply(dictionary$dimensions, function(dimension) {
    !is.list(dimension) || !length(dimension) || any(!nzchar(names(dimension)))
  }, logical(1))
  if (any(invalid)) {
    stop("Every TCCM dimension must contain named labels and pattern lists.", call. = FALSE)
  }
  dictionary$dimensions
}
