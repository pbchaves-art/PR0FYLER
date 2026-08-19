@echo off
setlocal EnableExtensions DisableDelayedExpansion

:: Window title
title P R 0 F Y L E R

echo ============================================
echo            P R 0 F Y L E R - 1.03
echo            Electropherogram to PDF 
echo            Author: Paulo B. Chaves
echo    Laboratorio de Biologia e DNA Forense
echo     Policia Cientifica de Goias - PCI/GO
echo ============================================
echo. 
echo BEFORE YOU BEGIN, MAKE SURE THAT:
echo.
echo  1 - The correct Default Database is set on Genemapper 
echo  (see https://github.com/pbchaves-art/PR0FYLER/blob/main/Troubleshooting)
echo.
echo  2 - Genemapper is not running 
echo  (close Genemapper before running P R 0 F Y L E R)
echo.

:: ==========================================================
:: 1) LOGIN CREDENTIALS AND PROJECT ID 
:: ==========================================================
echo ENTER YOUR GENEMAPPER LOGIN CREDENTIALS AND PROJECT NAME
echo.

:ask_user
set "USERNAME="
set /p "USERNAME=User Name: "
if "%USERNAME%"=="" goto :ask_user

:ask_pass
set "PASSWORD="
for /f "delims=" %%p in ('powershell -NoProfile -Command "$pword = Read-Host 'Password: ' -AsSecureString; $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); [System.Runtime.InteropServices.Marshal]::PtrToStringUni($BSTR)"') do set "PASSWORD=%%p"

if not defined PASSWORD goto :ask_pass

:ask_proj
set "PROJECT="
set /p "PROJECT=Project Name: "
if "%PROJECT%"=="" goto :ask_proj

echo.

:: ==========================================================
:: 2) SMART SEARCH FOR THE GENEMAPPER EXECUTABLE
:: ==========================================================
set "EXECUTABLE="

echo Searching for GeneMapper.exe...

:: --- SEARCH A: FAST PATH (Scan C: first for speed) ---
if exist "C:\AppliedBiosystems" (
    echo Looking into C:\AppliedBiosystems...
    for /f "delims=" %%F in ('dir /s /b "C:\AppliedBiosystems\GeneMapper.exe" 2^>nul') do (
        set "EXECUTABLE=%%F"
        goto :found_check
    )
)

:: --- SEARCH B: DEEP SEARCH (If not in C:, scan drives with WMIC) ---
echo Searching in additional drives (this can take a while)...
for /f "skip=1 tokens=1" %%D in ('wmic logicaldisk get name') do (
    :: Ignores drive C:
    if /I not "%%D"=="C:" (
        if exist "%%D\AppliedBiosystems" (
            for /f "delims=" %%F in ('dir /s /b "%%D\AppliedBiosystems\GeneMapper.exe" 2^>nul') do (
                set "EXECUTABLE=%%F"
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
echo.
echo ============================================================================
echo [WARNING] GeneMapper executable not found.
echo.
echo Type the FULL PATH to the executable file (.exe).
echo You can drag and drop the file from Windows Explorer here to copy the path.
echo Examples:
echo          C:\AppliedBiosystems\GeneMapperID-X\Client\app\GeneMapperIDX16.exe
echo          D:\Programas\GeneMapper\GM.exe
echo ============================================================================

set "EXEPATH="
set /p "EXEPATH=Executable path: "

:: Remove quotation marks if they exist
for %%A in ("%EXEPATH%") do set "EXEPATH=%%~A"

if not defined EXEPATH goto :ask_executable

:: Check whether the file exists
if not exist "%EXEPATH%" (
    echo.
    echo [ERROR] The specified path does not correspond to a valid executable file.
    echo.
    echo Typed path:
    echo "%EXEPATH%"
    echo.
    echo Please try again.
    goto :ask_executable
)

set "EXECUTABLE=%EXEPATH%"

:check_exist

:: ==========================================================
:: FINAL VALIDATION
:: ==========================================================
if not exist "%EXECUTABLE%" (
    echo.
    echo [CRITICAL ERROR] Executable file not found:
    echo "%EXECUTABLE%"
    echo.
    echo Check if the patch is correct.
    echo Press any key to exit...
    pause >nul
    exit /b
)

echo Valid executable found: "%EXECUTABLE%"
echo.

:: ==========================================================
:: 4) PREPARING FOR EXPORT
:: ==========================================================
set "EXPORTDIR=%USERPROFILE%\Desktop\%PROJECT%"

if not exist "%EXPORTDIR%" (
    mkdir "%EXPORTDIR%"
    if errorlevel 1 (
        echo [ERROR] Unable to create folder "%EXPORTDIR%".
        echo Check for invalid characters on the project's name.
        pause
        exit /b
    )
)

echo Output folder: "%EXPORTDIR%"
echo.

:: ==========================================================
:: 5) RUN
:: ==========================================================
echo Running GeneMapper...
echo Wait for the process to finish...
echo.

:: 1. Extract ONLY the executable's directory path
for %%E in ("%EXECUTABLE%") do set "EXEC_DIR=%%~dpE"

:: 2. Changes to the executable's directory, ensuring that -commandline works
PUSHD "%EXEC_DIR%"

:: 3. Runs the command using ONLY the executable's name (%%~nxE)
::    (This ensures that the program is in the correct directory)
for %%E in ("%EXECUTABLE%") do (
    "%%~nxE" -commandline -username "%USERNAME%" -password "%PASSWORD%" -project "%PROJECT%" -exportsampleplot "%EXPORTDIR%" -splitfile "true" -outputfilename "samplefilename" > "%EXPORTDIR%\log_execucao.txt" 2>&1
)

:: 4. Goes back to the script's directory
POPD

echo ===========================
echo    PROCESS FINISHED
echo ===========================
echo    PDF files in: "%EXPORTDIR%"
echo    Log file:  "%EXPORTDIR%\log_execucao.txt"
echo ===========================
echo.
pause
endlocal
exit /b
