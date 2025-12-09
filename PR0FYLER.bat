@echo off
setlocal EnableExtensions DisableDelayedExpansion

:: Define título da janela para ficar mais profissional
title Exportador GeneMapper Automotivo

echo ============================================
echo            P R 0 F Y L E R - 1.01
echo            Electropherogram to PDF 
echo            Autor: Paulo B. Chaves
echo    Laboratorio de Biologia e DNA Forense
echo     Policia Cientifica de Goias - PCI/GO
echo ============================================
echo.

:: ==========================================================
:: 1) COLETAR DADOS COM VALIDAÇÃO
:: ==========================================================
:ask_user
set "USERNAME="
set /p "USERNAME=Digite o username: "
if "%USERNAME%"=="" goto :ask_user
:ask_pass
set "PASSWORD="
echo Digite a senha:
:: Oculta comando PowerShell para o usuário não ver o código técnico
for /f "delims=" %%p in ('powershell -NoProfile -Command "$pword = Read-Host -AsSecureString; $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); [System.Runtime.InteropServices.Marshal]::PtrToStringUni($BSTR)"') do set "PASSWORD=%%p"
:ask_proj
set "PROJECT="
echo.
set /p "PROJECT=Digite o nome do projeto: "
if "%PROJECT%"=="" goto :ask_proj
echo.

:: ==========================================================
:: 2) BUSCA INTELIGENTE DO EXECUTÁVEL
:: ==========================================================
set "EXECUTABLE="

echo Procurando GeneMapper.exe...

:: --- ESTRATÉGIA A: FAST PATH (Checa C: direto para ganhar velocidade) ---
if exist "C:\AppliedBiosystems" (
    echo Verificando C:\AppliedBiosystems...
    for /f "delims=" %%F in ('dir /s /b "C:\AppliedBiosystems\GeneMapper.exe" 2^>nul') do (
        set "EXECUTABLE=%%F"
        goto :found_check
    )
)

:: --- ESTRATÉGIA B: DEEP SEARCH (Se não achou no C:, varre outros drives com WMIC) ---
echo Buscando em outros drives (isso pode demorar)...
for /f "skip=1 tokens=1" %%D in ('wmic logicaldisk get name') do (
    :: Ignora o drive C: pois já verificamos acima (otimização)
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
:: 3) TRATAMENTO MANUAL (Fallback)
:: ==========================================================
if defined EXECUTABLE goto :check_exist

echo.
echo ============================================================================
echo [AVISO] Nao localizei o executavel automaticamente.
echo.
echo Informe o CAMINHO COMPLETO do arquivo executavel.
echo Voce pode arrastar o arquivo do Windows Explorer aqui.
echo Exemplos:
echo          C:\AppliedBiosystems\GeneMapperID-X\Client\app\genemapperidx16.exe
echo          D:\Programas\GeneMapper\GM.exe
echo ============================================================================
set /p "EXEPATH=Caminho completo: "

:: Remove aspas se existirem
for %%A in ("%EXEPATH%") do set "EXEPATH=%%~A"

if "%EXEPATH%"=="" goto :found_check

:: Agora EXEPATH deve ser um arquivo. Validaremos isso.
if exist "%EXEPATH%" (
    set "EXECUTABLE=%EXEPATH%"
) else (
    echo.
    echo [ERRO] O caminho informado nao corresponde a um arquivo existente.
    echo Caminho digitado:
    echo "%EXEPATH%"
    echo.
    echo Tente novamente.
    goto :found_check
)

:check_exist
:: ==========================================================
:: VALIDAÇÃO FINAL ANTES DE EXECUTAR
:: ==========================================================
if not exist "%EXECUTABLE%" (
    echo.
    echo [ERRO CRITICO] O arquivo executavel nao foi encontrado:
    echo "%EXECUTABLE%"
    echo.
    echo Verifique se o caminho esta correto.
    echo Pressione qualquer tecla para sair...
    pause >nul
    exit /b
)

echo Executavel valido: "%EXECUTABLE%"
echo.

:: ==========================================================
:: 4) PREPARAÇÃO DA EXPORTAÇÃO
:: ==========================================================
set "EXPORTDIR=%USERPROFILE%\Desktop\%PROJECT%"

if not exist "%EXPORTDIR%" (
    mkdir "%EXPORTDIR%"
    if errorlevel 1 (
        echo [ERRO] Nao foi possivel criar a pasta "%EXPORTDIR%".
        echo Verifique se o nome do projeto contem caracteres invalidos.
        pause
        exit /b
    )
)

echo Pasta de destino: "%EXPORTDIR%"
echo.

:: ==========================================================
:: 5) EXECUÇÃO
:: ==========================================================
echo Executando GeneMapper...
echo Aguarde o termino do processo...
echo.

:: 1. Extrai APENAS o caminho do diretório do executável
for %%E in ("%EXECUTABLE%") do set "EXEC_DIR=%%~dpE"

:: 2. Muda para o diretório do executável, garantindo que o -commandline funcione
PUSHD "%EXEC_DIR%"

:: 3. Executa o comando, usando APENAS o nome do executável (%%~nxE)
::    (Isso garante que o programa se encontre no diretório correto)
for %%E in ("%EXECUTABLE%") do (
    "%%~nxE" -commandline -username "%USERNAME%" -password "%PASSWORD%" -project "%PROJECT%" -exportsampleplot "%EXPORTDIR%" -splitfile "true" -outputfilename "samplefilename" > "%EXPORTDIR%\log_execucao.txt" 2>&1
)

:: 4. Retorna ao diretório de onde o script foi chamado
POPD

echo ===========================
echo    PROCESSO FINALIZADO
echo ===========================
echo    Arquivos em: "%EXPORTDIR%"
echo    Log gerado:  "%EXPORTDIR%\log_execucao.txt"
echo ===========================
echo.
pause
endlocal
exit /b
echo ===========================
echo   PROCESSO FINALIZADO
echo ===========================
echo   Arquivos em: "%EXPORTDIR%"
echo   Log gerado:  "%EXPORTDIR%\log_execucao.txt"
echo ===========================
echo.
pause
endlocal
exit /b