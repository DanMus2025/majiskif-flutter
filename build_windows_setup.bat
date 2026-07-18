@echo off
setlocal EnableExtensions

cd /d "%~dp0"

set "ERROR_MESSAGE="
set "RELEASE_DIR=%~dp0build\windows\x64\runner\Release"
set "SCRIPT=%~dp0installer\kese_inno_setup.iss"
set "ISCC="
set "SIGNTOOL_EXE=%SIGNTOOL_EXE%"
set "WINDOWS_CERT_PFX=%WINDOWS_CERT_PFX%"
set "WINDOWS_CERT_PASSWORD=%WINDOWS_CERT_PASSWORD%"
set "WINDOWS_TIMESTAMP_URL=%WINDOWS_TIMESTAMP_URL%"
set "SIGNING_REQUIRED=%REQUIRE_WINDOWS_SIGNATURE%"
set "SIGNING_ENABLED=0"

if not defined CLOUD_URL (
  set "CLOUD_URL=https://majiskif-kese-cloud-api.onrender.com/api/v1/cloud"
)

if "%WINDOWS_TIMESTAMP_URL%"=="" set "WINDOWS_TIMESTAMP_URL=http://timestamp.digicert.com"

where flutter >nul 2>nul
if errorlevel 1 (
  set "ERROR_MESSAGE=Flutter est introuvable dans le PATH. Verifie l'installation Flutter ou lance ce script depuis un terminal Flutter."
  goto :fail
)

if not exist "%~dp0lib\main_release.dart" (
  set "ERROR_MESSAGE=Le point d'entree Flutter est introuvable: %~dp0lib\main_release.dart"
  goto :fail
)

if not exist "%SCRIPT%" (
  set "ERROR_MESSAGE=Script Inno Setup introuvable: %SCRIPT%"
  goto :fail
)

if not "%~1"=="" set "ISCC=%~1"
if "%ISCC%"=="" if not "%INNO_ISCC%"=="" set "ISCC=%INNO_ISCC%"
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if exist "%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe" set "ISCC=%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe"

if "%SIGNTOOL_EXE%"=="" (
  for /f "delims=" %%I in ('where signtool.exe 2^>nul') do (
    if "%SIGNTOOL_EXE%"=="" set "SIGNTOOL_EXE=%%I"
  )
)

if not "%SIGNTOOL_EXE%"=="" if not "%WINDOWS_CERT_PFX%"=="" if not "%WINDOWS_CERT_PASSWORD%"=="" (
  set "SIGNING_ENABLED=1"
)

if "%SIGNING_REQUIRED%"=="1" if "%SIGNING_ENABLED%"=="0" (
  set "ERROR_MESSAGE=Signature Windows requise, mais la configuration est incomplete. Renseigne SIGNTOOL_EXE, WINDOWS_CERT_PFX et WINDOWS_CERT_PASSWORD."
  goto :fail
)

if "%ISCC%"=="" (
  set "ERROR_MESSAGE=Inno Setup 6 est introuvable. Installe-le avec: winget install JRSoftware.InnoSetup"
  goto :fail
)

echo [1/4] Nettoyage des anciens builds
if exist "%~dp0build" rmdir /s /q "%~dp0build"
if exist "%~dp0dist\KESE-Setup.exe" del /f /q "%~dp0dist\KESE-Setup.exe"
if exist "%~dp0.flutter-plugins-dependencies" del /f /q "%~dp0.flutter-plugins-dependencies"

echo.
echo [2/4] Preparation des dependances Flutter
call flutter pub get
if errorlevel 1 (
  set "ERROR_MESSAGE=Echec de la preparation des dependances Flutter."
  goto :fail
)

echo.
echo [3/4] Generation build Windows release depuis le code actuel
call flutter build windows --release -t lib/main_release.dart "--dart-define=KESE_CLOUD_BASE_URL=%CLOUD_URL%"
if errorlevel 1 (
  set "ERROR_MESSAGE=Generation Windows echouee."
  goto :fail
)

if not exist "%RELEASE_DIR%\KESE.exe" (
  set "ERROR_MESSAGE=Le build Windows est introuvable: %RELEASE_DIR%\KESE.exe"
  goto :fail
)

if "%SIGNING_ENABLED%"=="1" (
  echo Signature du binaire Windows...
  call :sign_file "%RELEASE_DIR%\KESE.exe"
  if errorlevel 1 goto :fail
) else (
  echo Avertissement: signature Windows non configuree, generation en mode non signe.
)

echo.
echo [4/4] Creation installateur Windows
if not exist "%~dp0dist" mkdir "%~dp0dist"
"%ISCC%" "%SCRIPT%"

if errorlevel 1 (
  set "ERROR_MESSAGE=Creation de l'installateur echouee."
  goto :fail
)

if "%SIGNING_ENABLED%"=="1" (
  echo Signature de l'installateur Windows...
  call :sign_file "%~dp0dist\KESE-Setup.exe"
  if errorlevel 1 goto :fail
)

echo.
echo Installateur Windows disponible:
echo   %~dp0dist\KESE-Setup.exe

endlocal
exit /b 0

:fail
echo.
echo %ERROR_MESSAGE%
if /i not "%PAUSE_ON_ERROR%"=="0" pause
endlocal
exit /b 1

:sign_file
if not exist "%~1" (
  echo Fichier a signer introuvable:
  echo   %~1
  exit /b 1
)
"%SIGNTOOL_EXE%" sign /f "%WINDOWS_CERT_PFX%" /p "%WINDOWS_CERT_PASSWORD%" /tr "%WINDOWS_TIMESTAMP_URL%" /td SHA256 /fd SHA256 "%~1"
if errorlevel 1 (
  echo.
  echo Echec de la signature de:
  echo   %~1
  exit /b 1
)
exit /b 0
