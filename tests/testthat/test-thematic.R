source(testthat::test_path('..','..','R','thematic.R'))
source(testthat::test_path('..','..','R','thematic_static.R'))

test_that('thematic cut is interior and single-year input is not applicable', {
  expect_equal(slr_thematic_breaks(c(2020,2026)),2023)
  expect_equal(slr_thematic_breaks(c(2024,2025)),2024)
  expect_error(slr_thematic_breaks(c(2024,2024)),class='slr_not_applicable')
  expect_error(slr_thematic_breaks(c(NA,NA)),'no valid')
})

test_that('static export preserves flows and creates PNG and SVG', {
  te <- list(Nodes=data.frame(id=c('a','b'),name=c('first','second'),
    group=c('2020','2021'),color=c('#336699','#993333')),
    Edges=data.frame(from='a',to='b',lineage_strength=0.5))
  before <- serialize(te,NULL)
  folder <- tempfile('sankey-'); dir.create(folder)
  on.exit(unlink(folder,recursive=TRUE),add=TRUE)
  result <- slr_thematic_export(te,file.path(folder,'sankey'))
  expect_equal(result$flows,1L)
  expect_identical(before,serialize(te,NULL))
  expect_true(file.info(file.path(folder,'sankey.png'))$size>0)
  expect_true(file.info(file.path(folder,'sankey.svg'))$size>0)
  te$Edges$lineage_strength <- 0
  expect_error(slr_thematic_export(te,file.path(folder,'empty')),'No valid')
})

test_that('not-applicable steps are logged as skipped and pipeline continues', {
  folder <- tempfile('skip-');dir.create(folder)
  on.exit(unlink(folder,recursive=TRUE),add=TRUE)
  skipped <- file.path(folder,'skip.R'); next_step <- file.path(folder,'next.R')
  writeLines("stop(structure(list(message='Not applicable',call=NULL),class=c('slr_not_applicable','error','condition')))",skipped)
  writeLines('invisible(TRUE)',next_step)
  log <- slr_run_pipeline(root=folder,steps=c(skipped,next_step))
  expect_equal(log$status,c('skipped','success'))
})
