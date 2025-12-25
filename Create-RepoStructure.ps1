
<#
.SYNOPSIS
  SLR Suite klasör yapısını ve başlangıç dosyalarını oluşturur. (Windows PowerShell)
.DESCRIPTION
  - Klasörleri ve dosyaları oluşturur.
  - Bazı dosyalara örnek içerikler yazar.
  - İsteğe bağlı olarak git init ve GitHub push yapar.
.PARAMETER RepoName
  Oluşturulacak repo klasör adı (varsayılan: slr-suite)
.PARAMETER InitGit
  Git başlat ve commit/push yap (varsayılan: $false)
.PARAMETER GithubRemote
  Remote URL (örn: https://github.com/<kullanıcı-adınız>/slr-suite.git)
.EXAMPLE
  .\Create-RepoStructure.ps1 -RepoName slr-suite
.EXAMPLE
  .\Create-RepoStructure.ps1 -RepoName slr-suite -InitGit $true -GithubRemote "https://github.com/USERNAME/slr-suite.git"
#>

param(
    [string]$RepoName = "slr-suite",
    [bool]$InitGit = $false,
    [string]$GithubRemote = ""
)

# ---- Yardımcı çıktı fonksiyonları ----
function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "[OK]   $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "[ERR]  $msg" -ForegroundColor Red }

# ---- Dosya/Klasör yardımcıları ----
function Ensure-Dir([string]$path) {
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
        Write-Ok "Klasör oluşturuldu: $path"
    } else {
        Write-Warn "Klasör zaten var: $path"
    }
}

function Ensure-FileText([string]$path, [string]$content) {
    if (!(Test-Path $path)) {
        New-Item -ItemType File -Path $path -Force | Out-Null
        Set-Content -Path $path -Value $content -Encoding UTF8
        Write-Ok "Dosya oluşturuldu: $path"
    } else {
        Write-Warn "Dosya zaten var, içerik güncellenmedi: $path"
    }
}

function Ensure-FileLines([string]$path, [string[]]$lines) {
    if (!(Test-Path $path)) {
        New-Item -ItemType File -Path $path -Force | Out-Null
        Set-Content -Path $path -Value $lines -Encoding UTF8
        Write-Ok "Dosya oluşturuldu: $path"
    } else {
        Write-Warn "Dosya zaten var, içerik güncellenmedi: $path"
    }
}

# ---- Kök klasör ----
$root = Join-Path (Get-Location) $RepoName
if (!(Test-Path $root)) {
    New-Item -ItemType Directory -Path $root | Out-Null
    Write-Ok "Repo kök klasörü oluşturuldu: $root"
} else {
    Write-Warn "Repo kök klasörü zaten var: $root (Devam ediliyor)"
}

Write-Info "Klasör yapısı oluşturuluyor..."

# .github/workflows
Ensure-Dir (Join-Path $root ".github")
Ensure-Dir (Join-Path $root ".github/workflows")

# config
Ensure-Dir (Join-Path $root "config")

# data üç alt klasör
Ensure-Dir (Join-Path $root "data")
Ensure-Dir (Join-Path $root "data/raw")
Ensure-Dir (Join-Path $root "data/interim")
Ensure-Dir (Join-Path $root "data/processed")

# scripts
Ensure-Dir (Join-Path $root "scripts")

# docs/paper/figures
Ensure-Dir (Join-Path $root "docs")
Ensure-Dir (Join-Path $root "docs/paper")
Ensure-Dir (Join-Path $root "docs/paper/figures")

# notebooks
Ensure-Dir (Join-Path $root "notebooks")

Write-Info "Dosyalar oluşturuluyor..."

# ---- README.md (ASCII tree, Unicode yok) ----
$readmeLines = @(
'# SLR Suite',
'',
'Bu repo, sistematik literatür derlemesi (SLR) için kurgulanmış bir uçtan uca iş akışını içerir:',
'- Veri edinme ve temizleme',
'- Tarama (screening)',
'- Bibliyometrik analiz',
'- VOSviewer dışa aktarım',
'- TCCM matrisi',
'- Tematik evrim',
'- Atıf etkisi',
'- SPAR ile gelecek araştırma ajandası',
'',
'## Klasör Yapısı',
'```',
'slr-suite/',
'|-- README.md',
'|-- LICENSE',
'|-- CITATION.cff',
'|-- .github/',
'|   |-- workflows/',
'|       |-- r-cmd-check.yaml',
'|       |-- quarto-publish.yaml',
'|-- config/',
'|   |-- search_protocol.yaml',
'|   |-- screen_criteria.yaml',
'|   |-- tccm_codebook.yaml',
'|-- data/',
'|   |-- raw/',
'|   |-- interim/',
'|   |-- processed/',
'|-- scripts/',
'|   |-- 01_acquire_and_dedupe.R',
'|   |-- 02_screening.R',
'|   |-- 03_biblio_analysis.R',
'|   |-- 04_vosviewer_export.R',
'|   |-- 05_tccm_matrix.R',
'|   |-- 06_thematic_evolution.R',
'|   |-- 07_citation_impact.R',
'|   |-- 08_future_agenda_SPAR.R',
'|-- docs/',
'|   |-- paper/',
'|       |-- manuscript.qmd',
'|       |-- references.bib',
'|       |-- figures/',
'|-- notebooks/',
'|   |-- 00_playground.Rmd',
'```',
'',
'## Hızlı Başlangıç',
'- R paket ihtiyaçlarınızı `renv` ile kilitleyebilir,',
'- Quarto ile `docs/paper/manuscript.qmd` dosyasını render/publish edebilirsiniz.'
)
Ensure-FileLines (Join-Path $root "README.md") $readmeLines

# ---- LICENSE (MIT basit) ----
$licenseLines = @(
'MIT License',
'',
'Copyright (c) ' + (Get-Date -Format yyyy),
'',
'Permission is hereby granted, free of charge, to any person obtaining a copy',
'of this software and associated documentation files (the "Software"), to deal',
'in the Software without restriction, including without limitation the rights',
'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell',
'copies of the Software, and to permit persons to whom the Software is',
'furnished to do so, subject to the following conditions:',
'',
'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR',
'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,',
'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.'
)
Ensure-FileLines (Join-Path $root "LICENSE") $licenseLines

# ---- CITATION.cff ----
$dateReleased = Get-Date -Format yyyy-MM-dd
$citationLines = @(
'cff-version: 1.2.0',
'title: SLR Suite',
'message: Please cite this work if you use it.',
'authors:',
'  - family-names: Akbulut',
'    given-names: Metin',
'doi: 10.0000/example.doi',
"date-released: $dateReleased"
)
Ensure-FileLines (Join-Path $root "CITATION.cff") $citationLines

# ---- GitHub Actions: r-cmd-check.yaml ----
# Not: PowerShell'de kaçış için \" kullanmayın; ya tek tırnaklı string kullanın
# ya da içteki tek tırnakları çiftleyin (''), aşağıda bu yöntem kullanıldı.
$rCmdCheckLines = @(
'name: R-CMD-check',
'',
'on:',
'  push:',
'    branches: [ main ]',
'  pull_request:',
'',
'jobs:',
'  R-CMD-check:',
'    runs-on: ubuntu-latest',
'    steps:',
'      - uses: actions/checkout@v4',
'      - uses: r-lib/actions/setup-r@v2',
'      - uses: r-lib/actions/setup-pandoc@v2',
'      - name: Install dependencies',
'        run: Rscript -e ''install.packages(c("devtools","rmarkdown"))''',
'      - name: Check (no package)',
'        run: Rscript -e ''sessionInfo(); cat("OK\n")'''
)
Ensure-FileLines (Join-Path $root ".github/workflows/r-cmd-check.yaml") $rCmdCheckLines

# ---- GitHub Actions: quarto-publish.yaml ----
$quartoPublishLines = @(
'name: Publish Quarto to GitHub Pages',
'',
'on:',
'  push:',
'    branches: [ main ]',
'',
'jobs:',
'  build-deploy:',
'    runs-on: ubuntu-latest',
'    permissions:',
'      contents: write',
'      pages: write',
'      id-token: write',
'    steps:',
'      - uses: actions/checkout@v4',
'      - uses: quarto-dev/quarto-actions/setup@v2',
'      - name: Render site',
'        run: quarto render docs/paper/manuscript.qmd',
'      - name: Upload artifact',
'        uses: actions/upload-pages-artifact@v3',
'        with:',
'          path: docs/paper',
'      - name: Deploy to GitHub Pages',
'        uses: actions/deploy-pages@v4'
)
Ensure-FileLines (Join-Path $root ".github/workflows/quarto-publish.yaml") $quartoPublishLines

# ---- config/ şablonları ----
$searchProtocolLines = @(
'# Search Protocol',
'database: [Scopus, Web of Science]',
'keywords:',
'  - "artificial intelligence"',
'  - "digital transformation"',
'date_range: "2015-2025"',
'export_format: bibtex'
)
Ensure-FileLines (Join-Path $root "config/search_protocol.yaml") $searchProtocolLines

$screenCriteriaLines = @(
'# Screening Criteria',
'include:',
'  - language: English or Turkish',
'  - peer_reviewed: true',
'exclude:',
'  - document_type: editorial'
)
Ensure-FileLines (Join-Path $root "config/screen_criteria.yaml") $screenCriteriaLines

$tccmCodebookLines = @(
'# TCCM Codebook',
'# T: Theory, C: Context, C: Characteristics, M: Methodology',
'categories:',
'  - Theory',
'  - Context',
'  - Characteristics',
'  - Methodology',
'coding_rules:',
'  - rule: One primary category per study'
)
Ensure-FileLines (Join-Path $root "config/tccm_codebook.yaml") $tccmCodebookLines

# ---- scripts/ şablon dosyaları ----
$scripts = @(
'01_acquire_and_dedupe.R',
'02_screening.R',
'03_biblio_analysis.R',
'04_vosviewer_export.R',
'05_tccm_matrix.R',
'06_thematic_evolution.R',
'07_citation_impact.R',
'08_future_agenda_SPAR.R'
)
foreach ($s in $scripts) {
    $scriptPath = Join-Path $root ("scripts/" + $s)
    $scriptLines = @(
        '# ' + $s,
        '# TODO: Implement pipeline step.',
        '',
        '# İpucu: config/ içindeki YAML dosyalarını okumak için:',
        '# library(yaml)',
        "# cfg <- yaml::read_yaml('config/search_protocol.yaml')",
        ''
    )
    Ensure-FileLines $scriptPath $scriptLines
}

# ---- docs/paper: Quarto & bib ----
$manuscriptLines = @(
'---',
'title: "SLR Suite: Sistematik İnceleme Çalışması"',
'author: "Metin Akbulut"',
'format:',
'  pdf: default',
'  html:',
'    toc: true',
'    theme: cosmo',
'---',
'',
'## Özet',
'Bu dosya, çalışma kapsamında üretilecek tüm bölümleri barındıran Quarto belgesidir.',
'',
'## Giriş',
'Buraya çalışmanın motivasyonu, kapsamı ve katkıları yazılacak.',
'',
'## Yöntem',
'Arama protokolü ve tarama kriterleri için `config/` içeriğine bakınız.',
'',
'## Bulgular',
'Bibliyometrik analizler, tematik evrim ve atıf etkisi sonuçları.',
'',
'## Tartışma ve Gelecek Araştırma Ajandası (SPAR)',
'SPAR çerçevesi ile öneriler.',
'',
'## Kaynakça',
'```{bibliography}',
'docs/paper/references.bib',
'```'
)
Ensure-FileLines (Join-Path $root "docs/paper/manuscript.qmd") $manuscriptLines

$referencesLines = @(
'@article{example2025,',
'  title={Example Reference},',
'  author={Doe, John},',
'  journal={Journal of Examples},',
'  year={2025},',
'  volume={1},',
'  number={1},',
'  pages={1--10}',
'}'
)
Ensure-FileLines (Join-Path $root "docs/paper/references.bib") $referencesLines

# ---- notebooks/ ----
$playgroundLines = @(
'---',
'title: "Playground"',
'output: html_document',
'---',
'',
'```{r}',
'# Kurulum testleri',
'sessionInfo()',
'```'
)
Ensure-FileLines (Join-Path $root "notebooks/00_playground.Rmd") $playgroundLines

Write-Ok "Yapı ve dosyalar hazır: $root"

# ---- (Opsiyonel) Git işlemleri ----
if ($InitGit) {
    Write-Info "Git işlemleri başlatılıyor..."
    $gitExists = (Get-Command git -ErrorAction SilentlyContinue) -ne $null
    if (-not $gitExists) {
        Write-Err "Git bulunamadı. Lütfen Git for Windows kurun: https://git-scm.com/download/win"
        exit 1
    }

    Push-Location $root
    if (!(Test-Path (Join-Path $root ".git"))) {
        git init | Out-Null
        Write-Ok "Git repo başlatıldı."
    } else {
        Write-Warn ".git zaten var, yeniden başlatılmadı."
    }

    git add .
    git commit -m "Initial commit: SLR Suite structure" | Out-Null
    Write-Ok "Commit oluşturuldu."

    if ([string]::IsNullOrWhiteSpace($GithubRemote)) {
        Write-Warn "GithubRemote belirtilmedi. Remote eklenmedi ve push yapılmadı."
    } else {
        git branch -M main
        git remote remove origin 2>$null
        git remote add origin $GithubRemote
        git push -u origin main
        Write-Ok "GitHub'a push tamamlandı: $GithubRemote (branch: main)"
    }
    Pop-Location
}

Write-Ok "İşlem tamamlandı."
