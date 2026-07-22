# End-to-End Benchmark Report

## Method

The complete nine-module SLR Suite pipeline was executed five times for each of three bibliographic collections in a disposable working copy. Interim, processed, and log directories were recreated before every run. Source files were read without modification. Elapsed wall-clock time and the summed working set of active `Rscript` processes were sampled at 100 ms intervals. The memory measure is therefore an approximate Windows peak working set, not a platform-independent allocation metric.

Environment: Microsoft Windows 11 Pro 10.0.26200; Intel Core i7-10510U, 8 logical processors; 15.84 GB RAM; R 4.5.1; commit `6bbe5b7538d1a97e6ac0ddb59c5989fb263e8270`.

## Collections

| Dataset | Records | Input type | SHA-256 |
|---|---:|---|---|
| small-20 | 20 | WoS Plain Text bundled example | `8210989C7794629AC94C28DF7DA2407EE4DE894668F07B4BA886E4E60C6E53E8` |
| medium-208 | 208 | WoS Plain Text (`38708.txt`) | `12421BA557CB4E6BAC7E9E109F7649C286DF39477895216B5A6A650729E3942C` |
| large-500 | 500 | BibexPy harmonized TXT (`2020_2025_Merged_Vos.txt`) | `E676EF6E765259822C9547B3B6FF40A40A7173C9FBEFDAD3350103414AE4A6CF` |

The medium and large collections had no shared UT identifiers. The small collection shared no UT identifiers with the medium collection and one UT identifier with the large collection. The supplied `scopus.csv` contained only a header and one incomplete row and was excluded from benchmarking.

## Results

| Dataset | Successful runs | Elapsed time, median (Q1–Q3), s | Approximate peak memory, median (Q1–Q3), MB |
|---|---:|---:|---:|
| small-20 | 5/5 | 17.173 (16.851–20.755) | 462.21 (462.04–463.67) |
| medium-208 | 5/5 | 42.675 (42.164–45.227) | 489.28 (489.19–490.24) |
| large-500 | 5/5 | 80.131 (76.383–80.328) | 532.08 (531.98–532.18) |

All 135 module executions (three collections × five runs × nine modules) completed successfully. Results describe this hardware and software environment and should not be generalized as universal performance guarantees.
