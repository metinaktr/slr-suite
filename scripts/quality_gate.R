root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
r_files <- list.files(root, pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
r_files <- r_files[!grepl("/(renv|\\.Rproj\\.user)/", gsub("\\\\", "/", r_files))]

parse_failures <- vapply(r_files, function(path) {
  tryCatch({ parse(path, keep.source = FALSE); "" }, error = conditionMessage)
}, character(1))
if (any(nzchar(parse_failures))) {
  stop("R syntax gate failed:\n", paste(names(parse_failures)[nzchar(parse_failures)], parse_failures[nzchar(parse_failures)], collapse = "\n"))
}

content <- vapply(r_files, function(path) paste(readLines(path, warn = FALSE), collapse = "\n"), character(1))
banned <- c("install\\.packages\\s*\\(" = "runtime package installation", "rm\\s*\\(\\s*list\\s*=\\s*ls" = "global workspace clearing")
for (pattern in names(banned)) {
  offenders <- names(content)[grepl(pattern, content)]
  if (length(offenders)) stop("Quality gate found ", banned[[pattern]], ": ", paste(offenders, collapse = ", "))
}

if (requireNamespace("lintr", quietly = TRUE)) {
  lint_files <- list.files(file.path(root, "R"), pattern = "\\.R$", full.names = TRUE)
  lints <- unlist(lapply(lint_files, lintr::lint), recursive = FALSE)
  if (length(lints)) print(lints)
  if (length(lints)) stop("lintr gate failed with ", length(lints), " finding(s).")
}

message("Quality gate passed for ", length(r_files), " R files.")
