@echo off
setlocal
TITLE SLR-Suite Pipeline Manager
cd /d "%~dp0"

set "RSCRIPT="
for /f "delims=" %%I in ('where Rscript.exe 2^>nul') do if not defined RSCRIPT set "RSCRIPT=%%I"

if not defined RSCRIPT if exist "%ProgramFiles%\R" (
  for /f "delims=" %%I in ('dir /b /ad /o-n "%ProgramFiles%\R\R-*" 2^>nul') do (
    if not defined RSCRIPT if exist "%ProgramFiles%\R\%%I\bin\Rscript.exe" set "RSCRIPT=%ProgramFiles%\R\%%I\bin\Rscript.exe"
  )
)

if not defined RSCRIPT (
  echo Rscript.exe was not found on PATH or under "%ProgramFiles%\R".
  echo Install R from https://cran.r-project.org/ or open slr-suite.Rproj in RStudio.
  pause
  exit /b 1
)

echo Using Rscript: "%RSCRIPT%"
"%RSCRIPT%" --vanilla master_launcher.R menu
if errorlevel 1 echo SLR-Suite stopped with an error. Review the message above.
pause
endlocal
