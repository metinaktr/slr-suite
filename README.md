# SLR Suite

Bu repo, sistematik literatür derlemesi (SLR) için kurgulanmış bir uçtan uca iş akışını içerir:
- Veri edinme ve temizleme
- Tarama (screening)
- Bibliyometrik analiz
- VOSviewer dÄ±ÅŸa aktarÄ±m
- TCCM matrisi
- Tematik evrim
- AtÄ±f etkisi
- SPAR ile gelecek araÅŸtÄ±rma ajandasÄ±

## Klasör Yapısı
```
slr-suite/
|-- README.md
|-- LICENSE
|-- CITATION.cff
|-- .github/
|   |-- workflows/
|       |-- r-cmd-check.yaml
|       |-- quarto-publish.yaml
|-- config/
|   |-- search_protocol.yaml
|   |-- screen_criteria.yaml
|   |-- tccm_codebook.yaml
|-- data/
|   |-- raw/
|   |-- interim/
|   |-- processed/
|-- scripts/
|   |-- 01_acquire_and_dedupe.R
|   |-- 02_screening.R
|   |-- 03_biblio_analysis.R
|   |-- 04_vosviewer_export.R
|   |-- 05_tccm_matrix.R
|   |-- 06_thematic_evolution.R
|   |-- 07_citation_impact.R
|   |-- 08_future_agenda_SPAR.R
|-- docs/
|   |-- paper/
|       |-- manuscript.qmd
|       |-- references.bib
|       |-- figures/
|-- notebooks/
|   |-- 00_playground.Rmd
```

## HÄ±zlÄ± BaÅŸlangÄ±Ã§
- R paket ihtiyaÃ§larÄ±nÄ±zÄ± `renv` ile kilitleyebilir,
- Quarto ile `docs/paper/manuscript.qmd` dosyasÄ±nÄ± render/publish edebilirsiniz.
