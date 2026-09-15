# Static two-period Sankey renderer. Widths preserve the computed flow weights.
slr_thematic_export <- function(te, prefix) {
  nodes <- te$Nodes
  edges <- te$Edges
  a <- match(edges$from, nodes$id)
  b <- match(edges$to, nodes$id)
  w <- if ("lineage_strength" %in% names(edges)) edges$lineage_strength else edges$Inc_Weighted
  ok <- !is.na(a) & !is.na(b) & is.finite(w) & w > 0
  if (!any(ok)) stop("No valid positive thematic flows are available.")
  a <- a[ok]
  b <- b[ok]
  w <- w[ok]
  left <- unique(a)
  right <- unique(b)
  if (length(intersect(left, right))) stop("Static Sankey requires two disjoint periods.")
  total <- sum(w)
  gap <- 0.015
  scale <- (0.86 - gap * (max(length(left), length(right)) - 1)) / total
  lo <- hi <- numeric(nrow(nodes))
  for (side in list(left, right)) {
    cursor <- 0.94
    for (i in side) {
      amount <- sum(w[if (i %in% left) a == i else b == i])
      hi[i] <- cursor
      lo[i] <- cursor - amount * scale
      cursor <- lo[i] - gap
    }
  }
  top_a <- hi
  top_b <- hi
  bands <- vector("list", length(w))
  for (k in seq_along(w)) {
    height <- w[k] * scale
    bands[[k]] <- c(
      top_a[a[k]], top_a[a[k]] - height,
      top_b[b[k]], top_b[b[k]] - height
    )
    top_a[a[k]] <- top_a[a[k]] - height
    top_b[b[k]] <- top_b[b[k]] - height
  }
  draw <- function() {
    graphics::par(mar = c(0, 0, 0, 0), xaxs = "i", yaxs = "i")
    graphics::plot.new()
    graphics::plot.window(xlim = c(0, 1), ylim = c(0, 1))
    t <- seq(0, 1, length.out = 100)
    ease <- 3 * t^2 - 2 * t^3
    x <- 0.29 + 0.42 * t
    for (k in seq_along(w)) {
      z <- bands[[k]]
      upper <- z[1] + (z[3] - z[1]) * ease
      lower <- z[2] + (z[4] - z[2]) * ease
      col <- grDevices::adjustcolor(nodes$color[a[k]], alpha.f = 0.55)
      graphics::polygon(c(x, rev(x)), c(upper, rev(lower)), col = col, border = NA)
    }
    for (i in c(left, right)) {
      is_left <- i %in% left
      x0 <- if (is_left) 0.275 else 0.71
      graphics::rect(x0, lo[i], x0 + 0.015, hi[i], col = nodes$color[i], border = "gray40")
      graphics::text(
        if (is_left) 0.267 else 0.733, (lo[i] + hi[i]) / 2,
        labels = nodes$name[i], adj = if (is_left) 1 else 0, cex = 0.9
      )
    }
    graphics::text(
      c(0.28, 0.72), 0.985,
      labels = c(as.character(nodes$group[left[1]]), as.character(nodes$group[right[1]])),
      font = 2, cex = 1.1
    )
  }
  dir.create(dirname(prefix), recursive = TRUE, showWarnings = FALSE)
  grDevices::png(paste0(prefix, ".png"), width = 2400, height = 1600, res = 180)
  tryCatch(draw(), finally = grDevices::dev.off())
  grDevices::svg(paste0(prefix, ".svg"), width = 13.33, height = 8.89)
  tryCatch(draw(), finally = grDevices::dev.off())
  invisible(list(flows = length(w), total_weight = total))
}
