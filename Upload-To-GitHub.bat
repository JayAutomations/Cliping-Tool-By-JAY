@echo off
title Upload Cliping Tool By JAY to GitHub
cd /d "%~dp0"
echo ========================================================
echo   Uploading Cliping Tool By JAY to GitHub (JayAutomations)
echo ========================================================
echo.

set "PATH=C:\Users\jayro\AppData\Local\Microsoft\WinGet\Packages\GitHub.cli_Microsoft.Winget.Source_8wekyb3d8bbwe\bin;C:\Users\jayro\AppData\Local\Microsoft\WinGet\Packages\Git.MinGit_Microsoft.Winget.Source_8wekyb3d8bbwe\cmd;%PATH%"

call gh auth status >nul 2>&1
if %errorlevel% neq 0 (
    echo [Step 1] GitHub Login:
    echo Niche ek 8-digit code (jaise XXXX-XXXX) aayega aur wo code
    echo automatically clipboard par copy bhi ho jayega!
    echo.
    echo Jab "Press Enter to open github.com in your browser" likha aaye,
    echo to bas Enter dabayein aur browser mein code Paste karke Authorize karein.
    echo.
    call gh auth login -h github.com -p https -w -s repo -c
)

echo.
echo [Step 2] Git credentials setup ho rahe hain...
call gh auth setup-git

echo.
echo [Step 3] Code upload (push) ho raha hai...
call git push -u origin main

echo.
echo ========================================================
if %errorlevel% equ 0 (
    echo [SUCCESS] Tool GitHub par successfully upload ho gaya hai!
    echo Check karein: https://github.com/JayAutomations/Cliping-Tool-By-JAY
) else (
    echo Upload mein koi issue aaya.
)
echo ========================================================
echo.
pause
