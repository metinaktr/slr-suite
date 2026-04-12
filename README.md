# SLR Suite

A lightweight, web-based support tool for conducting transparent and reproducible Systematic Literature Reviews (SLR). 

SLR Suite is designed to help researchers structure, document, and transparently report the methodological stages of a systematic literature review. The tool focuses on methodological clarity rather than analytical interpretation and is intended for academic use in theses, journal articles, and research projects. 

🌐 Live application: https://metinaktr\.github\.io/slr\-suite/ 
https://metinaktr.github.io/slr-suite/

Bu repo, sistematik literatür derlemesi (SLR) için kurgulanmış bir uçtan uca iş akışını içerir:
- Veri edinme ve temizleme
- Tarama (screening)
- Bibliyometrik analiz
- VOSviewer dışa aktarım
- TCCM matrisi
- Tematik evrim
- Atıf etkisi
- SPAR ile gelecek araştırma ajandası

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
|-- ci/
      |--03_biblio_core_ci.R
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
    |-- 09_prisma_flow.R
|-- docs/
|   |-- paper/
|       |-- manuscript.qmd
|       |-- references.bib
|       |-- figures/
|-- notebooks/
|   |-- 00_playground.Rmd
```

## Hızlı Başlangıç
- R paket ihtiyaçlarınızı `renv` ile kilitleyebilir,
- Quarto ile `docs/paper/manuscript.qmd` dosyasınızı render/publish edebilirsiniz.
