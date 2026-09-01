@echo off
setlocal EnableExtensions DisableDelayedExpansion

:: Window title
title P R 0 F Y L E R

echo ==================================================
echo               P R 0 F Y L E R - 1.04
echo               Electropherogram to PDF
echo               Author: Paulo B. Chaves
echo       Laboratorio de Biologia e DNA Forense
echo    Policia Cientifica de Goias - PCI/GO, Brazil
echo ==================================================
echo.
echo ---------BEFORE YOU BEGIN, MAKE SURE THAT---------
echo.
echo  1 - The correct Default Database is set on GeneMapper
echo      (see https://github.com/pbchaves-art/PR0FYLER/blob/main/Troubleshooting)
echo.
echo  2 - GeneMapper is not running
echo      (close GeneMapper on your computer before running PR0FYLER)
echo.
echo --------------------------------------------------
echo.

:: ==========================================================
:: 0) SMART SEARCH FOR POWERSHELL
:: ==========================================================
:: Search for Microsoft PowerShell
set "PS_EXE=powershell.exe"
"%PS_EXE%" -NoProfile -Command "exit 0" >nul 2>&1

:: Skip the fallback if the first attempt succeeded
if not errorlevel 1 goto :powershell_found

:: Try the standard Windows PowerShell path
set "PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
"%PS_EXE%" -NoProfile -Command "exit 0" >nul 2>&1

if errorlevel 1 (
    echo.
    echo [ERROR] Microsoft PowerShell is not available.
    echo PR0FYLER requires PowerShell to run.
    echo.
    pause
    exit /b
)

:powershell_found

:: ==========================================================
:: 1) LOGIN CREDENTIALS AND PROJECT ID 
:: ==========================================================
echo ENTER YOUR GENEMAPPER LOGIN CREDENTIALS AND PROJECT NAME(S)
echo.

:ask_user
set "USERNAME="
set /p "USERNAME=User Name: "
if "%USERNAME%"=="" goto :ask_user

:ask_pass
set "PASSWORD="
:: ADICIONADO O @ ANTES DA VARIÁVEL "%PS_EXE%" PARA EVITAR CORTE DE ASPAS PELO CMD
for /f "delims=" %%p in ('@"%PS_EXE%" -NoProfile -Command "$pword = Read-Host ''Password'' -AsSecureString; $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); [System.Runtime.InteropServices.Marshal]::PtrToStringUni($BSTR)"') do set "PASSWORD=%%p"

if not defined PASSWORD goto :ask_pass

:ask_proj
set "PROJECTS="
set /p "PROJECTS=Project Name(s) (separated by commas): "
if "%PROJECTS%"=="" goto :ask_proj

echo.
echo --------------------------------------------------
echo.
:: ==========================================================
:: 2) SMART SEARCH FOR THE GENEMAPPER EXECUTABLE
:: ==========================================================
set "EXECUTABLE="

echo Searching for GeneMapper.exe...
echo.

:: First, search in C:\AppliedBiosystems (fastest)
if exist "C:\AppliedBiosystems" (
    echo Looking into C:\AppliedBiosystems...
    for /f "delims=" %%F in ('dir /s /b "C:\AppliedBiosystems\GeneMapper.exe" 2^>nul') do (
        set "EXECUTABLE=%%F"
        echo Found: "%%F"
        goto :found_check
    )
)

:: If not found in C:\, search all other filesystem drives
echo Searching in additional drives. 
echo Please wait...
:: ADICIONADO O @ AQUI TAMBÉM
for /f "delims=" %%D in ('@"%PS_EXE%" -NoProfile -Command "Get-PSDrive | Where-Object { $_.Provider.Name -eq 'FileSystem' } | Select-Object -ExpandProperty Name"') do (
    if /I not "%%D"=="C" (
        if exist "%%D:\AppliedBiosystems" (
            echo Looking into %%D:\AppliedBiosystems...
            for /f "delims=" %%F in ('dir /s /b "%%D:\AppliedBiosystems\GeneMapper.exe" 2^>nul') do (
                set "EXECUTABLE=%%F"
                echo Found: "%%F"
                goto :found_check
            )
        )
    )
)

:found_check
:: ==========================================================
:: 3) USER INFORMED EXECUTABLE PATH (Fallback)
:: ==========================================================
if defined EXECUTABLE goto :check_exist

:ask_executable
echo ============================================================================
echo [WARNING!] GeneMapper executable not found.
echo.
echo Type the FULL PATH to the executable file (.exe).
echo You can drag and drop the file from Windows Explorer here to copy the path.
echo Examples:
echo          C:\AppliedBiosystems\GeneMapperID-X\Client\app\GeneMapperIDX16.exe
echo          D:\Programas\GeneMapper\GM.exe
echo ============================================================================

set "EXEPATH="
set /p "EXEPATH=Executable path: "
for %%A in ("%EXEPATH%") do set "EXEPATH=%%~A"
if not defined EXEPATH goto :ask_executable
if not exist "%EXEPATH%" goto :ask_executable
set "EXECUTABLE=%EXEPATH%"

:check_exist
if not exist "%EXECUTABLE%" (
    pause >nul
    exit /b
)

echo Valid executable found: "%EXECUTABLE%"

:: ==========================================================
:: 4) TEMPORARY FILE W/ PROJECT NAMES & DESKTOP PATH
:: ==========================================================
:: Get the actual Desktop path configured by Windows
set "DESKTOP_DIR="

:: ADICIONADO O @ AQUI TAMBÉM
for /f "delims=" %%D in ('@"%PS_EXE%" -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DESKTOP_DIR=%%D"

if not defined DESKTOP_DIR (
    echo.
    echo [ERROR] Could not determine the Windows Desktop folder.
    echo.
    pause
    exit /b
)

:: Get the directory containing the GeneMapper executable
for %%E in ("%EXECUTABLE%") do set "EXEC_DIR=%%~dpE"

PUSHD "%EXEC_DIR%"

set "TMPFILE=%TEMP%\PR0FYLER_PROJECTS_%RANDOM%.txt"

"%PS_EXE%" -NoProfile -Command "$projects='%PROJECTS%'.Split(','); $projects | ForEach-Object {$_.Trim()} | Set-Content '%TMPFILE%'"

for /f "usebackq delims=" %%P in ("%TMPFILE%") do (
    call :PROCESS_PROJECT "%%P"
)

set "PASSWORD="

del "%TMPFILE%" >nul 2>&1

POPD
goto :FINISHED

:: ==========================================================
:: 5) CREATE PROJECT FOLDER ON DESKTOP
:: ==========================================================
:PROCESS_PROJECT
set "PROJECT=%~1"
if "%PROJECT%"=="" exit /b

:: Build the export folder path using the actual Windows Desktop path
set "EXPORTDIR=%DESKTOP_DIR%\%PROJECT%"

if not exist "%EXPORTDIR%" mkdir "%EXPORTDIR%"

if not exist "%EXPORTDIR%" (
    echo.
    echo [ERROR] Could not create the export folder:
    echo "%EXPORTDIR%"
    echo.
    exit /b
)

:: ==========================================================
:: 6) RUN
:: ==========================================================
echo.
echo Exporting project "%PROJECT%"
echo Please wait...

for %%E in ("%EXECUTABLE%") do (
    "%%~nxE" -commandline -username "%USERNAME%" -password "%PASSWORD%" -project "%PROJECT%" -exportsampleplot "%EXPORTDIR%" -splitfile "true" -outputfilename "samplefilename" -pagesize "A4" > "%EXPORTDIR%\log_execucao.txt" 2>&1
)

:: Verify whether at least one PDF was generated
dir /b "%EXPORTDIR%\*.pdf" >nul 2>&1

if errorlevel 1 (
    echo.
    echo [ERROR] No PDF files were generated for project "%PROJECT%"
    echo Check the log file:
    echo "%EXPORTDIR%\log_execucao.txt"
    echo.
    exit /b
)

echo [OK] PDF export completed successfully for project "%PROJECT%"

exit /b

:FINISHED
echo ==================================================
echo    PROCESS FINISHED
echo    Find PDF and Log files on your Desktop folder
echo ==================================================
echo.
pause
endlocal
exit /b
