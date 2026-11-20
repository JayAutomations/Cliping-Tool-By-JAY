# NeonClipping launcher (Windows). Creates .venv on first run, starts the app, opens the browser.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$gyanBin = "C:\Users\jayro\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.WinGet.Source_8wekyb3d8bbwe\ffmpeg-9.1-full_build\bin"
if (Test-Path $gyanBin) { $env:Path = "$gyanBin;$env:Path" }
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";$env:Path"
if (-not (Test-Path .venv/Scripts/python.exe)) {
    python -m venv .venv
    .venv/Scripts/python.exe -m pip install -r requirements.txt
}
Start-Process 'http://127.0.0.1:8770'
.venv/Scripts/python.exe app.py
