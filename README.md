# SLR Suite

A lightweight, web-based support tool for conducting transparent and reproducible Systematic Literature Reviews (SLR). 

SLR Suite is designed to help researchers structure, document, and transparently report the methodological stages of a systematic literature review. The tool focuses on methodological clarity rather than analytical interpretation and is intended for academic use in theses, journal articles, and research projects. 

🌐 Live application: https://metinaktr.github.io/slr-suite/

✨ Key Highlights 

📚 Supports core stages of Systematic Literature Reviews (SLR) 

🧩 Improves methodological transparency and traceability 

📝 Produces method-section–ready documentation 

🌍 Fully web-based — no installation required 

🎓 Designed for academic research and graduate education 

Important: SLR Suite does not analyze or interpret literature content. It supports the documentation of the review methodology. 

🧭 What Is SLR Suite? 

SLR Suite is an academic support tool developed to assist researchers in explicitly structuring and documenting the workflow of a systematic literature review. It enables users to record how research questions, search strategies, inclusion criteria, exclusion criteria, and review decisions are defined and applied. 

Its primary aim is to enhance: 

Reproducibility 

Methodological rigor 

Transparency of the review process 

👥 Who Is It For? 

SLR Suite is suitable for: 

Academics and independent researchers 

PhD and master’s students 

Authors of systematic reviews or structured literature reviews 

Research teams seeking transparent and auditable review procedures 

This repository contains an end-to-end workflow designed for a systematic literature review (SLR):
- Data acquisition and cleaning
- Screening
- Bibliometric analysis
- VOSviewer export
- TCCM matrix
- Thematic evolution
- Citation impact
- Future research agenda with SPAR

## Folder Structure
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

 

🚀 Getting Started 

Accessing the Tool 

Open the application directly in your web browser: 

 https://metinaktr.github.io/slr-suite/ 


No installation, registration, or configuration is required. 

Typical Use Workflow 

Define the scope and structure of the literature review 

Document search strategies and selection decisions 

Use the generated structure in the methodology section of the study 

Cite SLR Suite as a supporting methodological tool 

🧩 #Core Capabilities 

Structuring systematic review stages 

Documenting inclusion and exclusion logic 

Supporting method-section reporting 

Reducing ambiguity in review procedures 

SLR Suite can be used alongside established SLR guidelines such as: 

PRISMA 

Kitchenham (2004, 2007) 

Other domain-specific systematic review frameworks 

 📖 How to Cite 

If SLR Suite is used in an academic study, citation is recommended to ensure methodological transparency. 

##APA (7th Edition) 

1     Akbulut, M. (2026). *SLR Suite: A web-based support tool for systematic literature reviews* [Web application]. https://metinaktr.github.io/slr-suite/ 

#In-text citation 

(Akbulut, 2026) 
