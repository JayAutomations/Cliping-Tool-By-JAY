@echo off
title Upload Cliping Tool By JAY to GitHub
cd /d "%~dp0"
echo ========================================================
echo   Uploading Cliping Tool By JAY to GitHub: JayAutomations
echo ========================================================
echo.

set "PATH=C:\Users\jayro\AppData\Local\Microsoft\WinGet\Packages\GitHub.cli_Microsoft.Winget.Source_8wekyb3d8bbwe\bin;C:\Users\jayro\AppData\Local\Microsoft\WinGet\Packages\Git.MinGit_Microsoft.Winget.Source_8wekyb3d8bbwe\cmd;%PATH%"

call gh auth status >nul 2>&1
if %errorlevel% neq 0 goto :login
goto :push

:login
echo [Step 1] GitHub Login zaroori hai.
echo Niche ek 8-digit code aayega aur wo clipboard par copy ho jayega.
echo Jab "Press Enter to open github.com in your browser" likha aaye, to Enter dabayein.
echo Browser khulega, wahan code paste karke Authorize karein.
echo.
call gh auth login -h github.com -p https -w -s repo -c
if %errorlevel% neq 0 goto :failed

:push
echo.
echo [Step 2] Git credentials setup ho rahe hain...
call gh auth setup-git

echo.
echo [Step 3] Code upload ho raha hai...
call git push -u origin main

if %errorlevel% neq 0 goto :failed

echo.
echo ========================================================
echo [SUCCESS] Tool GitHub par successfully upload ho gaya hai!
echo Check karein: https://github.com/JayAutomations/Cliping-Tool-By-JAY
echo ========================================================
goto :done

:failed
echo.
echo ========================================================
echo Upload mein koi problem aayi.
echo ========================================================

:done
echo.
pause
