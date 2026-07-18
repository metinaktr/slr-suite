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

:menu
echo.
echo SLR Suite
echo 1^) Run complete pipeline
echo 2^) 01_acquire_and_dedupe.R
echo 3^) 02_screening.R
echo 4^) 03_biblio_analysis.R
echo 5^) 04_vosviewer_export.R
echo 6^) 05_tccm_matrix.R
echo 7^) 06_thematic_evolution.R
echo 8^) 07_citation_impact.R
echo 9^) 08_future_agenda_SPAR.R
echo 10^) 09_prisma_flow.R
echo 11^) Run validation experiment
echo 12^) Exit
set "SLR_CHOICE="
set /p "SLR_CHOICE=Select an option [1-12]: "
if errorlevel 1 goto done

if "%SLR_CHOICE%"=="1" goto run_all
if "%SLR_CHOICE%"=="2" goto run_step_1
if "%SLR_CHOICE%"=="3" goto run_step_2
if "%SLR_CHOICE%"=="4" goto run_step_3
if "%SLR_CHOICE%"=="5" goto run_step_4
if "%SLR_CHOICE%"=="6" goto run_step_5
if "%SLR_CHOICE%"=="7" goto run_step_6
if "%SLR_CHOICE%"=="8" goto run_step_7
if "%SLR_CHOICE%"=="9" goto run_step_8
if "%SLR_CHOICE%"=="10" goto run_step_9
if "%SLR_CHOICE%"=="11" goto run_validation
if "%SLR_CHOICE%"=="12" goto done

echo Enter a number from 1 to 12.
goto menu

:run_all
call :run_command run
goto menu

:run_step_1
call :run_command step 1
goto menu

:run_step_2
call :run_command step 2
goto menu

:run_step_3
call :run_command step 3
goto menu

:run_step_4
call :run_command step 4
goto menu

:run_step_5
call :run_command step 5
goto menu

:run_step_6
call :run_command step 6
goto menu

:run_step_7
call :run_command step 7
goto menu

:run_step_8
call :run_command step 8
goto menu

:run_step_9
call :run_command step 9
goto menu

:run_validation
call :run_command validate
goto menu

:run_command
echo.
"%RSCRIPT%" --vanilla master_launcher.R %*
if errorlevel 1 (
  echo.
  echo SLR-Suite stopped with an error. Review the message above.
) else (
  echo.
  echo Command completed successfully.
)
pause
exit /b 0

:done
endlocal
exit /b 0
