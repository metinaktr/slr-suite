args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) {
  stop("Usage: Rscript experiments/evaluate_classification.R <coded.csv> <metrics.csv>", call. = FALSE)
}
data <- read.csv(args[[1]], stringsAsFactors = FALSE, na.strings = c("", "NA"))
required <- c("coder_1_label", "coder_2_label", "consensus_label", "predicted_label")
if (!all(required %in% names(data))) {
  stop("Coding file is missing required columns: ", paste(setdiff(required, names(data)), collapse = ", "), call. = FALSE)
}
complete <- data[complete.cases(data[required]), required, drop = FALSE]
if (!nrow(complete)) stop("No completed coding rows were found.", call. = FALSE)

labels <- sort(unique(c(complete$consensus_label, complete$predicted_label)))
confusion <- table(factor(complete$consensus_label, levels = labels), factor(complete$predicted_label, levels = labels))
agreement <- mean(complete$coder_1_label == complete$coder_2_label)
p1 <- prop.table(table(factor(complete$coder_1_label, levels = labels)))
p2 <- prop.table(table(factor(complete$coder_2_label, levels = labels)))
expected <- sum(p1 * p2)
kappa <- if (expected == 1) NA_real_ else (agreement - expected) / (1 - expected)

metrics <- do.call(rbind, lapply(seq_along(labels), function(i) {
  tp <- confusion[i, i]
  fp <- sum(confusion[, i]) - tp
  fn <- sum(confusion[i, ]) - tp
  precision <- if ((tp + fp) == 0) NA_real_ else tp / (tp + fp)
  recall <- if ((tp + fn) == 0) NA_real_ else tp / (tp + fn)
  f1 <- if (is.na(precision) || is.na(recall) || (precision + recall) == 0) NA_real_ else 2 * precision * recall / (precision + recall)
  data.frame(label = labels[i], precision = precision, recall = recall, f1 = f1)
}))
metrics$n <- nrow(complete)
metrics$inter_rater_agreement <- agreement
metrics$cohens_kappa <- kappa
write.csv(metrics, args[[2]], row.names = FALSE)
