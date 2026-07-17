# Typed conditions used across the orchestration layer.

slr_abort <- function(message, class = "slr_error", ..., call = sys.call(-1)) {
  condition <- structure(
    c(list(message = message, call = call), list(...)),
    class = c(class, "slr_error", "error", "condition")
  )
  stop(condition)
}

slr_assert <- function(condition, message, class = "slr_validation_error", ...) {
  if (!isTRUE(condition)) slr_abort(message, class = class, ...)
  invisible(TRUE)
}

slr_wrap_error <- function(error, step) {
  if (inherits(error, "slr_step_error")) return(error)
  structure(
    list(
      message = sprintf("Pipeline step '%s' failed: %s", step, conditionMessage(error)),
      call = NULL,
      step = step,
      parent = error
    ),
    class = c("slr_step_error", "slr_error", "error", "condition")
  )
}
