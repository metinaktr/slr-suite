@echo off
TITLE SLR-Suite Pipeline Manager
where Rscript >nul 2>nul
if errorlevel 1 (
  echo Rscript was not found on PATH. Open slr-suite.Rproj in RStudio instead.
  exit /b 1
)
Rscript master_launcher.R menu
pause
