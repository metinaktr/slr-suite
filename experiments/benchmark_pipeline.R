args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) {
  stop("Usage: Rscript experiments/benchmark_pipeline.R <manifest.csv> <results.csv>", call. = FALSE)
}
manifest <- read.csv(args[[1]], stringsAsFactors = FALSE)
required <- c("dataset_id", "input_path", "command")
if (!all(required %in% names(manifest))) {
  stop("Benchmark manifest must contain dataset_id, input_path, and command.", call. = FALSE)
}
if (!all(file.exists(manifest$input_path))) stop("One or more benchmark inputs do not exist.", call. = FALSE)

results <- do.call(rbind, lapply(seq_len(nrow(manifest)), function(i) {
  before <- gc(reset = TRUE)
  timing <- system.time(status <- system(manifest$command[i], intern = FALSE, ignore.stdout = TRUE, ignore.stderr = FALSE))
  after <- gc()
  data.frame(
    dataset_id = manifest$dataset_id[i],
    records = if ("records" %in% names(manifest)) manifest$records[i] else NA_integer_,
    elapsed_seconds = unname(timing[["elapsed"]]),
    memory_mb_approx = sum(after[, 2] - before[, 2]),
    exit_status = if (is.null(status)) 0L else as.integer(status),
    timestamp_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)
  )
}))
write.csv(results, args[[2]], row.names = FALSE)
