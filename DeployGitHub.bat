@echo off
setlocal EnableExtensions

rem ============================================================
rem  DeployGitHub.bat
rem  One-button GitHub deployment for the MajiskifFlutter project.
rem  - Shows the project inventory at startup
rem  - Initializes Git if .git is missing
rem  - Stages all tracked files, new files, folders, and deletions
rem  - Skips generated caches and local logs
rem  - Creates a numbered commit with date and time
rem  - Pushes to origin/main without interactive prompts
rem  - Writes every step to deploy.log
rem  - Pauses at the end so the result stays visible
rem ============================================================

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "REMOTE_NAME=origin"
set "REMOTE_URL=https://github.com/DanMus2025/majiskif-flutter.git"
set "REMOTE_BRANCH=main"
set "LOG_FILE=%ROOT%\deploy.log"
set "DEPLOY_NUM=0"
set "LOCAL_HASH="
set "REMOTE_HASH="
set "REMOTE_EXIST="
set "GIT_TERMINAL_PROMPT=0"

if exist "%LOG_FILE%" del /f /q "%LOG_FILE%" >nul 2>&1

call :say ============================================================
call :say Deploy GitHub launcher
call :say Project dir : %ROOT%
call :say Remote      : %REMOTE_NAME%
call :say Branch      : %REMOTE_BRANCH%
call :say Log file    : %LOG_FILE%
call :say ============================================================
call :say

where git >nul 2>&1
if errorlevel 1 goto :no_git

pushd "%ROOT%" >nul 2>&1 || goto :bad_root

call :say 0/6 - Inventory of the current project root
call :say ------------------------------------------------------------
dir /b /a
>> "%LOG_FILE%" echo ============================================================
>> "%LOG_FILE%" echo Deploy GitHub launcher
>> "%LOG_FILE%" echo Project dir : %ROOT%
>> "%LOG_FILE%" echo Remote      : %REMOTE_NAME%
>> "%LOG_FILE%" echo Branch      : %REMOTE_BRANCH%
>> "%LOG_FILE%" echo Log file    : %LOG_FILE%
>> "%LOG_FILE%" echo ============================================================
>> "%LOG_FILE%" echo.
>> "%LOG_FILE%" echo 0/6 - Inventory of the current project root
>> "%LOG_FILE%" echo ------------------------------------------------------------
dir /b /a >> "%LOG_FILE%" 2>&1

call :say 1/6 - Initializing or reopening Git
if not exist ".git\" (
    call :say   - .git not found, running git init
    git init >> "%LOG_FILE%" 2>&1 || goto :git_failed
)
git branch -M %REMOTE_BRANCH% >> "%LOG_FILE%" 2>&1 || goto :git_failed

git config --local core.longpaths true >> "%LOG_FILE%" 2>&1 || goto :git_failed
git config --local user.name "DanMus2025" >> "%LOG_FILE%" 2>&1 || goto :git_failed
git config --local user.email "DanMus2025@users.noreply.github.com" >> "%LOG_FILE%" 2>&1 || goto :git_failed

if not exist ".git\info\" (
    mkdir ".git\info" >> "%LOG_FILE%" 2>&1 || goto :git_failed
)
> ".git\info\exclude" (
    echo # Local deploy-only exclusions
    echo .dart_tool/
    echo .gradle-cache/
    echo .idea/
    echo .vscode/
    echo .venv/
    echo build/
    echo dist/
    echo android/build/
    echo android/.gradle/
    echo windows/flutter/ephemeral/
    echo linux/flutter/ephemeral/
    echo macos/Flutter/ephemeral/
    echo ios/Pods/
    echo *.log
    echo *.out
    echo *.err
    echo error.txt
)

set "REMOTE_EXIST="
for /f "delims=" %%I in ('git remote get-url %REMOTE_NAME% 2^>nul') do set "REMOTE_EXIST=%%I"
if defined REMOTE_EXIST (
    git remote set-url %REMOTE_NAME% "%REMOTE_URL%" >> "%LOG_FILE%" 2>&1 || goto :git_failed
) else (
    git remote add %REMOTE_NAME% "%REMOTE_URL%" >> "%LOG_FILE%" 2>&1 || goto :git_failed
)

call :say 2/6 - Staging every file, folder, and deletion
call :say   - Using git add -A

if exist ".git\index.lock" (
    call :say   - Removing stale .git\index.lock
    del /f /q ".git\index.lock" >> "%LOG_FILE%" 2>&1 || goto :git_failed
)


git status --short >> "%LOG_FILE%" 2>&1

git add -A >> "%LOG_FILE%" 2>&1 || goto :git_failed
git status --short >> "%LOG_FILE%" 2>&1
git diff --cached --stat >> "%LOG_FILE%" 2>&1

for /f %%I in ('git rev-list --count HEAD 2^>nul') do set "DEPLOY_NUM=%%I"
if not defined DEPLOY_NUM set "DEPLOY_NUM=0"
set /a DEPLOY_NUM+=1
set "COMMIT_MSG=Deploy #%DEPLOY_NUM% - %DATE% %TIME%"

call :say 3/6 - Committing deployment #%DEPLOY_NUM%
git commit --allow-empty -m "%COMMIT_MSG%" >> "%LOG_FILE%" 2>&1 || goto :git_failed

call :say 4/6 - Pushing to GitHub main (non-interactive)
git push --force -u %REMOTE_NAME% HEAD:%REMOTE_BRANCH% >> "%LOG_FILE%" 2>&1 || goto :git_failed

call :say 5/6 - Reading final hashes
for /f %%I in ('git rev-parse --short HEAD 2^>nul') do set "LOCAL_HASH=%%I"
for /f "tokens=1" %%I in ('git ls-remote %REMOTE_NAME% refs/heads/%REMOTE_BRANCH% 2^>nul') do set "REMOTE_HASH=%%I"

call :say 6/6 - Done
call :say ============================================================
call :say SUCCESS
call :say Local commit : %LOCAL_HASH%
if defined REMOTE_HASH (
    call :say Remote hash  : %REMOTE_HASH%
) else (
    call :say Remote hash  : unavailable
)
call :say GitHub should now show the latest deployment on %REMOTE_BRANCH%.
call :say Log file     : %LOG_FILE%
call :say ============================================================
call :say

>> "%LOG_FILE%" echo.
>> "%LOG_FILE%" echo ============================================================
>> "%LOG_FILE%" echo SUCCESS
>> "%LOG_FILE%" echo Local commit : %LOCAL_HASH%
if defined REMOTE_HASH (
    >> "%LOG_FILE%" echo Remote hash  : %REMOTE_HASH%
) else (
    >> "%LOG_FILE%" echo Remote hash  : unavailable
)
>> "%LOG_FILE%" echo GitHub should now show the latest deployment on %REMOTE_BRANCH%.
>> "%LOG_FILE%" echo Log file     : %LOG_FILE%
>> "%LOG_FILE%" echo ============================================================

popd >nul 2>&1
pause
exit /b 0

:no_git
call :fail Git is not installed or is not available in PATH.
goto :eof

:bad_root
call :fail The project folder could not be opened: %ROOT%
goto :eof

:git_failed
call :fail A Git command failed. Check %LOG_FILE% for the full output.
goto :eof

:fail
set "ERR_MSG=%*"
echo.
echo ============================================================
echo FAILED
echo %ERR_MSG%
echo See: %LOG_FILE%
echo ============================================================
>> "%LOG_FILE%" echo.
>> "%LOG_FILE%" echo ============================================================
>> "%LOG_FILE%" echo FAILED
>> "%LOG_FILE%" echo %ERR_MSG%
>> "%LOG_FILE%" echo See: %LOG_FILE%
>> "%LOG_FILE%" echo ============================================================
popd >nul 2>&1
pause
exit /b 1

:say
if "%~1"=="" (
    echo.
) else (
    echo %*
)
if "%~1"=="" (
    >> "%LOG_FILE%" echo.
) else (
    >> "%LOG_FILE%" echo %*
)
goto :eof
