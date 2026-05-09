#!/usr/bin/env pwsh
# Install latest debug or release APK to a connected Android device.
#
# Usage:
#   .\scripts\install_phone.ps1                    # Installs release APK
#   .\scripts\install_phone.ps1 -Debug             # Installs debug APK
#   .\scripts\install_phone.ps1 -Apk path\to.apk   # Installs given APK
#
# Requires: USB-debugging enabled phone, ADB on PATH or at default Android SDK location.

param(
    [switch]$Debug,
    [string]$Apk
)

$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot

if (-not $Apk) {
    if ($Debug) {
        $Apk = Join-Path $repo 'build\nightseed-survivor.apk'
    } else {
        $Apk = Join-Path $repo 'build\nightseed-survivor-release.apk'
    }
}

if (-not (Test-Path $Apk)) {
    Write-Error "APK not found: $Apk`nBuild first or pass -Apk <path>."
}

$adb = (Get-Command adb -ErrorAction SilentlyContinue).Source
if (-not $adb) {
    $defaultAdb = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
    if (Test-Path $defaultAdb) {
        $adb = $defaultAdb
    } else {
        Write-Error "ADB not found. Install Android SDK platform-tools or add adb to PATH."
    }
}

Write-Host "Using adb: $adb" -ForegroundColor Cyan
Write-Host "Installing: $Apk" -ForegroundColor Cyan

& $adb devices
$devices = & $adb devices | Select-String -Pattern '\sdevice$'
if (-not $devices) {
    Write-Error "No device connected. Plug in your phone with USB debugging enabled."
}

& $adb install -r $Apk
if ($LASTEXITCODE -ne 0) {
    Write-Error "Install failed. If you switched signing keys, uninstall the previous app first: adb uninstall com.nightseed.survivor"
}

Write-Host "Done. Launch 'Nightseed Survivor' on your phone." -ForegroundColor Green
