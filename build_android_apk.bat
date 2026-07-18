@echo off
setlocal EnableExtensions

cd /d "%~dp0"

set "ERROR_MESSAGE="

if not defined CLOUD_URL (
  set "CLOUD_URL=https://majiskif-kese-cloud-api.onrender.com/api/v1/cloud"
)

set "APK_SOURCE=%~dp0build\app\outputs\flutter-apk\app-release.apk"
set "APK_DIST=%~dp0dist\KESE.apk"

where flutter >nul 2>nul
if errorlevel 1 (
  set "ERROR_MESSAGE=Flutter est introuvable dans le PATH. Verifie l'installation Flutter ou lance ce script depuis un terminal Flutter."
  goto :fail
)

if not exist "%~dp0lib\main_release.dart" (
  set "ERROR_MESSAGE=Le point d'entree Flutter est introuvable: %~dp0lib\main_release.dart"
  goto :fail
)

echo [1/3] Nettoyage des anciens builds
if exist "%~dp0build" rmdir /s /q "%~dp0build"
if exist "%~dp0dist\KESE.apk" del /f /q "%~dp0dist\KESE.apk"
if exist "%~dp0.flutter-plugins-dependencies" del /f /q "%~dp0.flutter-plugins-dependencies"

echo.
echo [2/3] Preparation des dependances Flutter
call flutter pub get
if errorlevel 1 (
  set "ERROR_MESSAGE=Echec de la preparation des dependances Flutter."
  goto :fail
)

echo.
echo [3/3] Generation APK Android release depuis le code actuel
call flutter build apk --release -t lib/main_release.dart --no-tree-shake-icons "--dart-define=KESE_CLOUD_BASE_URL=%CLOUD_URL%"
if errorlevel 1 (
  set "ERROR_MESSAGE=Generation APK echouee."
  goto :fail
)

if not exist "%APK_SOURCE%" (
  set "ERROR_MESSAGE=APK introuvable: %APK_SOURCE%"
  goto :fail
)

echo.
echo Copie dans dist
if not exist "%~dp0dist" mkdir "%~dp0dist"
copy /Y "%APK_SOURCE%" "%APK_DIST%" >nul
if errorlevel 1 (
  set "ERROR_MESSAGE=Echec de la copie de l'APK vers dist."
  goto :fail
)

echo.
echo APK cree:
echo   %APK_SOURCE%
echo Copie:
echo   %APK_DIST%

endlocal
exit /b 0

:fail
echo.
echo %ERROR_MESSAGE%
if /i not "%PAUSE_ON_ERROR%"=="0" pause
endlocal
exit /b 1
