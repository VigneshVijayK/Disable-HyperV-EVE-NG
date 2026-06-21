#Requires -RunAsAdministrator

$ApiBase = "https://disable-hyperv-license-api.onrender.com"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  HYPER-V COMPLETE DISABLER" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$LicenseKey = Read-Host "Enter your license key"

try {
    Write-Host "`nValidating license..." -ForegroundColor Yellow
    $Response = Invoke-RestMethod -Uri "$ApiBase/validate?key=$LicenseKey" -Method GET -TimeoutSec 15

    if (-not $Response.valid) {
        Write-Host "`n  LICENSE ERROR: $($Response.error)" -ForegroundColor Red
        Write-Host "  Visit https://github.com/VigneshVijayK/Disable-HyperV-EVE-NG`n" -ForegroundColor Red
        exit 1
    }

    Write-Host "  License valid (expires: $($Response.expires))`n" -ForegroundColor Green
}
catch {
    Write-Host "`n  ERROR: Could not contact license server." -ForegroundColor Red
    Write-Host "  Check your internet connection or try again later.`n" -ForegroundColor Red
    exit 1
}

try {
    Write-Host "Downloading script..." -ForegroundColor Yellow
    $ScriptResponse = Invoke-WebRequest -Uri "$ApiBase/download?key=$LicenseKey" -UseBasicParsing -TimeoutSec 30

    if ($ScriptResponse.StatusCode -ne 200) {
        Write-Host "Download failed (HTTP $($ScriptResponse.StatusCode))" -ForegroundColor Red
        exit 1
    }

    $ScriptContent = $ScriptResponse.Content

    if ([string]::IsNullOrWhiteSpace($ScriptContent)) {
        Write-Host "Downloaded script is empty." -ForegroundColor Red
        exit 1
    }

    Write-Host "Executing...`n" -ForegroundColor Green
    Invoke-Expression $ScriptContent
}
catch {
    Write-Host "Download failed: $_" -ForegroundColor Red
    exit 1
}
