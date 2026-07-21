# Multi-Dataset Runtime and Memory Benchmark Protocol

Use at least three independently sourced, legally redistributable datasets representing small, medium, and large reviews. Record the source, record count, operating system, R version, processor, memory, commit, and dependency lock-file checksum.

Run each dataset after a clean R session at least five times. Store raw run-level results; report the median and interquartile range for elapsed time and approximate memory. Do not treat the two synthetic test fixtures in this repository as independent performance evidence. The manifest is a runnable format example only.
