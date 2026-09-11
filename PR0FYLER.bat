@echo off
setlocal EnableExtensions DisableDelayedExpansion

:: Window title
title P R 0 F Y L E R

echo ==================================================
echo               P R 0 F Y L E R - 1.05
echo               Electropherogram to PDF
echo               Author: Paulo B. Chaves
echo       Laboratorio de Biologia e DNA Forense
echo    Policia Cientifica de Goias - PCI/GO, Brazil
echo ==================================================
echo.
echo ---------BEFORE YOU BEGIN, MAKE SURE THAT---------
echo.
echo  1 - The correct Default Database is set on GeneMapper.
echo      - See https://github.com/pbchaves-art/PR0FYLER/blob/main/Troubleshooting
echo.
echo  2 - GeneMapper is not running.
echo      - PR0FYLER will try to close GeneMapper automatically before it asks for your credentials.
echo      - If it can't, you may need to close GeneMapper yourself or restart your computer or the Database computer.
echo      - [WARNING!] Save your work before running PR0FYLER.
echo.
echo --------------------------------------------------
echo.
:: ==========================================================
:: 1) SEARCH FOR MICROSOFT POWERSHELL
:: ==========================================================
set "PS_EXE=powershell.exe"

%PS_EXE% -NoProfile -Command "exit 0" >nul 2>&1

if errorlevel 1 (
    set "PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
)

"%PS_EXE%" -NoProfile -Command "exit 0" >nul 2>&1

if errorlevel 1 goto :ask_powershell

set "PS_RUN=%PS_EXE%"
goto :powershell_found

:ask_powershell
echo ============================================================================
echo [WARNING!] Microsoft PowerShell not found.
echo PR0FYLER requires PowerShell to run.
echo.
echo Type the FULL PATH to the PowerShell executable file.
echo You can drag and drop the file from Windows Explorer here to copy the path.
echo Examples:
echo          C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
echo          C:\Program Files\PowerShell\7\pwsh.exe
echo ============================================================================

set "PSEXEPATH="
set /p "PSEXEPATH=PowerShell executable path: "

:: Remove quotes if the user dragged and dropped the file
for %%A in ("%PSEXEPATH%") do set "PSEXEPATH=%%~A"
if not defined PSEXEPATH goto :ask_powershell
if not exist "%PSEXEPATH%" goto :ask_powershell

:: Verify that the provided executable works as PowerShell
"%PSEXEPATH%" -NoProfile -Command "if ($PSVersionTable.PSVersion) { exit 0 } else { exit 1 }" >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] The provided file is not a valid PowerShell executable or is failing to run.
    echo.
    goto :ask_powershell
)

set "PS_EXE=%PSEXEPATH%"
set PS_RUN="%PS_EXE%"

:powershell_found
:: ==========================================================
:: 2) CLOSE GENEMAPPER 
:: ==========================================================
:: Close visible GeneMapper windows without affecting common applications
%PS_RUN% -NoProfile -Command "Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like 'GeneMapper*' -and $_.ProcessName -notin @('chrome','chromium','msedge','firefox','brave','opera','vivaldi','iexplore','winword','powerpnt','excel','msaccess','mspub','outlook','onenote','notepad','notepad++','wordpad','code','devenv','sublime_text','atom','soffice','soffice.bin','swriter','scalc','simpress','acrord32','acrobat','foxitpdfreader','sumatrapdf','explorer','SearchHost','ApplicationFrameHost','cmd','conhost','powershell','pwsh','WindowsTerminal','mspaint','Photos','Microsoft.Photos','photoshop','illustrator','thunderbird','slack','teams','ms-teams') } | Stop-Process -Force -ErrorAction SilentlyContinue" >nul 2>&1

:: Close hidden GeneMapper processes with known process names
%PS_RUN% -NoProfile -Command "Get-Process -Name 'GMprw','GMpprw','GeneMapper*' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue" >nul 2>&1

:: ==========================================================
:: 3) LOGIN CREDENTIALS AND PROJECT ID 
:: ==========================================================
echo ENTER YOUR GENEMAPPER LOGIN CREDENTIALS AND PROJECT NAME(S)
echo.

:ask_user
set "USERNAME="
set /p "USERNAME=User Name: "
if "%USERNAME%"=="" goto :ask_user

:ask_pass
set "PASSWORD="
for /f "delims=" %%p in ('%PS_RUN% -NoProfile -Command "$pword = Read-Host ''Password'' -AsSecureString; $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); [System.Runtime.InteropServices.Marshal]::PtrToStringUni($BSTR)"') do set "PASSWORD=%%p"

if not defined PASSWORD goto :ask_pass

:ask_proj
set "PROJECTS="
set /p "PROJECTS=Project Name(s) (separated by commas): "
if "%PROJECTS%"=="" goto :ask_proj

echo.
echo --------------------------------------------------
echo.
:: ==========================================================
:: 4) SMART SEARCH FOR THE GENEMAPPER EXECUTABLE
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
for /f "delims=" %%D in ('%PS_RUN% -NoProfile -Command "Get-PSDrive | Where-Object { $_.Provider.Name -eq 'FileSystem' } | Select-Object -ExpandProperty Name"') do (
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
:: 5) USER INFORMED EXECUTABLE PATH (Fallback)
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
:: 6) TEMPORARY FILE W/ PROJECT NAMES & DESKTOP PATH
:: ==========================================================
:: Get the actual Desktop path configured by Windows
set "DESKTOP_DIR="

for /f "delims=" %%D in ('%PS_RUN% -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DESKTOP_DIR=%%D"

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

:: Split project names by comma using pure batch (no PowerShell)
type nul > "%TMPFILE%"
set "_PROJ_REMAINING=%PROJECTS%"

:split_loop
if not defined _PROJ_REMAINING goto :split_done
for /f "tokens=1* delims=," %%a in ("%_PROJ_REMAINING%") do (
    for /f "tokens=*" %%t in ("%%a") do echo %%t>>"%TMPFILE%"
    set "_PROJ_REMAINING=%%b"
)
goto :split_loop
:split_done

for /f "usebackq delims=" %%P in ("%TMPFILE%") do (
    call :PROCESS_PROJECT "%%P"
)

set "PASSWORD="

del "%TMPFILE%" >nul 2>&1

POPD
goto :FINISHED

:: ==========================================================
:: 7) CREATE PROJECT FOLDER ON DESKTOP
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
:: 8) RUN
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
