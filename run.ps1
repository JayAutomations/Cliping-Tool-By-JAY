# NeonClipping launcher (Windows). Creates .venv on first run, starts the app, opens the browser.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

# Check if already running on port 8770
$alreadyRunning = $false
try {
    $res = Invoke-RestMethod -Uri 'http://127.0.0.1:8770/healthz' -TimeoutSec 2 -ErrorAction SilentlyContinue
    if ($res.ok) { $alreadyRunning = $true }
} catch {}

if ($alreadyRunning) {
    Write-Host "Cliping Tool By JAY pehle se chal raha hai! Browser mein open kar rahe hain..." -ForegroundColor Green
    Start-Process 'http://127.0.0.1:8770'
    exit 0
}

$gyanBin = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.WinGet.Source_8wekyb3d8bbwe\ffmpeg-9.1-full_build\bin"
if (Test-Path $gyanBin) { $env:Path = "$gyanBin;$env:Path" }
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";$env:Path"

# Agar Python missing hai to install karein
if (-not (Get-Command python -ErrorAction SilentlyContinue) -and -not (Test-Path .venv/Scripts/python.exe)) {
    Write-Host "Python nahi mila. Auto-install shuru ho raha hai..." -ForegroundColor Yellow
    winget install Python.Python.3.12 --accept-source-agreements --accept-package-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";$env:Path"
}

# Agar FFmpeg missing hai to install karein
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "FFmpeg nahi mila. Auto-install shuru ho raha hai..." -ForegroundColor Yellow
    winget install Gyan.FFmpeg --accept-source-agreements --accept-package-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";$env:Path"
}
if (-not (Test-Path .venv/Scripts/python.exe)) {
    python -m venv .venv
    .venv/Scripts/python.exe -m pip install -r requirements.txt
}
Start-Process 'http://127.0.0.1:8770'
.venv/Scripts/python.exe app.py
