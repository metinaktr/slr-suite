@echo off
setlocal
TITLE SLR-Suite Pipeline Manager
cd /d "%~dp0"

where Rscript.exe >nul 2>nul
if errorlevel 1 (
  echo Rscript was not found on PATH. Open slr-suite.Rproj in RStudio instead.
  pause
  exit /b 1
)

Rscript.exe --vanilla master_launcher.R menu
if errorlevel 1 echo SLR-Suite stopped with an error. Review the message above.
pause
endlocal
