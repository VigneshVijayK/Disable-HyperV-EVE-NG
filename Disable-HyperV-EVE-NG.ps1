#Requires -RunAsAdministrator

# ============================================================
#  Hyper-V Complete Disabler - Launcher
#  Version : 5.0.0
#  Author  : VigneshVijayK
# ============================================================

$Version   = "5.0.0"
$ApiBase   = "https://disable-hyperv-license-api-0n56.onrender.com"
$BuyUrl    = "https://vigneshvijayk.github.io/VigneshVijayK/"
$LinkedIn  = "https://in.linkedin.com/in/vignesh-vijay-k"
$LogPath   = Join-Path $env:TEMP "hyperv-disabler.log"
$ExeUrl    = "https://github.com/VigneshVijayK/Disable-HyperV-EVE-NG/releases/download/v3.0/pack_3.0.exe"
$ExeName   = "pack_3.0.exe"

# ------------------------------------------------------------
# Helper: Write-Log
#   Writes a timestamped line to both the console (color-coded)
#   and the log file. Append mode keeps history across runs.
# ------------------------------------------------------------
function Write-Log {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet("Cyan","Yellow","Green","Red","DarkGray","White")]
        [string]$Color = "White"
    )
    $stamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $LogPath -Value "[$stamp] $Message" -ErrorAction SilentlyContinue
}

# ------------------------------------------------------------
# Helper: Write-Step
#   Prints a numbered step header like [1/4] Validating...
# ------------------------------------------------------------
function Write-Step {
    param(
        [Parameter(Mandatory)][int]$Step,
        [Parameter(Mandatory)][int]$Total,
        [Parameter(Mandatory)][string]$Message
    )
    Write-Log "[$Step/$Total] $Message" -Color Yellow
}

# ------------------------------------------------------------
# Helper: Get-MaskedKey
#   Returns the license key with all but the last 4 chars
#   replaced by X (e.g. XXXX-XXXX-XXXX-AB12).
# ------------------------------------------------------------
function Get-MaskedKey {
    param([string]$Key)
    if ([string]::IsNullOrWhiteSpace($Key)) { return "****" }
    if ($Key.Length -le 4) { return "****" }
    return ("X" * ($Key.Length - 4)) + $Key.Substring($Key.Length - 4)
}

# ============================================================
#  START
# ============================================================

# Session separator in the log file (append mode)
Add-Content -Path $LogPath -Value "`n========================================" -ErrorAction SilentlyContinue
Add-Content -Path $LogPath -Value "SESSION START - $(Get-Date)" -ErrorAction SilentlyContinue
Add-Content -Path $LogPath -Value "Machine: $env:COMPUTERNAME  |  OS: $([System.Environment]::OSVersion.VersionString)" -ErrorAction SilentlyContinue
Add-Content -Path $LogPath -Value "========================================`n" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  HYPER-V COMPLETE DISABLER  v$Version" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  First run may take up to 30s (server cold start).`n" -ForegroundColor DarkGray

# ------------------------------------------------------------
# [1/4] LICENSE INPUT + VALIDATION
# ------------------------------------------------------------
$LicenseKey = Read-Host "Enter your license key"
if ([string]::IsNullOrWhiteSpace($LicenseKey)) {
    Write-Log "  No license key entered. Exiting." -Color Red
    exit 1
}
Write-Log "License key entered (masked): $(Get-MaskedKey $LicenseKey)" -Color DarkGray

Write-Step 1 5 "Validating license..."
try {
    $Response = Invoke-RestMethod -Uri "$ApiBase/validate?key=$LicenseKey" -Method GET -TimeoutSec 15

    if (-not $Response.valid) {
        Write-Log "  LICENSE ERROR: $($Response.error)" -Color Red

        if ($Response.error -eq "License expired") {
            Write-Log "  Press R to renew your license, or any other key to exit." -Color Yellow
            $choice = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($choice.Character -eq 'R' -or $choice.Character -eq 'r') {
                Write-Log "  Opening renewal page..." -Color Green
                Start-Process $BuyUrl
            } else {
                Write-Log "  User chose to exit without renewing." -Color DarkGray
            }
        } else {
            Write-Log "  Press B to buy a license, or any other key to exit." -Color Yellow
            $choice = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($choice.Character -eq 'B' -or $choice.Character -eq 'b') {
                Write-Log "  Opening purchase page..." -Color Green
                Start-Process $BuyUrl
            } else {
                Write-Log "  User chose to exit without purchasing." -Color DarkGray
            }
        }
        exit 1
    }

    Write-Log "  License valid (expires: $($Response.expires))" -Color Green
}
catch {
    Write-Log "  ERROR: Could not contact license server." -Color Red
    Write-Log "  Check your internet connection or try again later." -Color Red
    Write-Log "  Press R to report this to the developer, or any other key to exit." -Color Yellow
    $choice = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($choice.Character -eq 'R' -or $choice.Character -eq 'r') {
        Write-Log "  Opening report page..." -Color Green
        Start-Process $BuyUrl
    } else {
        Write-Log "  User chose to exit without reporting." -Color DarkGray
    }
    exit 1
}

# ------------------------------------------------------------
# PRE-ACTION CONFIRMATION MENU
# ------------------------------------------------------------
$menuLoop = $true
while ($menuLoop) {
    Write-Host ""
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host "  What would you like to do?" -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host "    1. Proceed to disable Hyper-V" -ForegroundColor White
    Write-Host "    2. View license details" -ForegroundColor White
    Write-Host "    3. Exit" -ForegroundColor White
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    $menuChoice = (Read-Host "Enter your choice (1-3)").Trim()

    switch ($menuChoice) {
        "1" {
            Write-Log "  User chose: Proceed to disable Hyper-V" -Color DarkGray
            $menuLoop = $false
        }
        "2" {
            Write-Host ""
            Write-Host "  License Details" -ForegroundColor Cyan
            Write-Host "  --------------------------------" -ForegroundColor Cyan
            Write-Host "    Key     : $(Get-MaskedKey $LicenseKey)" -ForegroundColor White
            Write-Host "    Expires : $($Response.expires)" -ForegroundColor White
            Write-Host "  --------------------------------`n" -ForegroundColor Cyan
            Write-Log "  User viewed license details" -Color DarkGray
        }
        "3" {
            Write-Log "  User chose: Exit" -Color DarkGray
            exit 0
        }
        default {
            Write-Host "`n  Invalid choice. Please enter 1, 2, or 3.`n" -ForegroundColor Red
        }
    }
}

# ------------------------------------------------------------
# [2/4] DOWNLOAD PAYLOAD
# ------------------------------------------------------------
Write-Step 2 5 "Downloading script..."
try {
    $ScriptResponse = Invoke-WebRequest -Uri "$ApiBase/download?key=$LicenseKey" -UseBasicParsing -TimeoutSec 30

    if ($ScriptResponse.StatusCode -ne 200) {
        Write-Log "  Download failed (HTTP $($ScriptResponse.StatusCode))" -Color Red
        exit 1
    }

    $ScriptContent = $ScriptResponse.Content

    if ([string]::IsNullOrWhiteSpace($ScriptContent)) {
        Write-Log "  Downloaded script is empty." -Color Red
        exit 1
    }

    Write-Log "  Download complete ($($ScriptContent.Length) bytes)" -Color Green
}
catch {
    Write-Log "  Download failed: $_" -Color Red
    exit 1
}

# ------------------------------------------------------------
# [3/4] EXECUTE PAYLOAD
# ------------------------------------------------------------
Write-Step 3 5 "Executing..."
$LauncherTranscript = Join-Path $env:TEMP "hyperv-launcher-capture.log"
try {
    # Start a launcher-side transcript to capture all console output
    # (including the payload's [FAIL] markers) so we can detect failures
    # without modifying the payload. Only output text is captured, never
    # the payload source code — no extraction risk.
    Start-Transcript -Path $LauncherTranscript -Force -ErrorAction SilentlyContinue | Out-Null

    Write-Host ""
    Invoke-Expression $ScriptContent
    Write-Log "  Execution completed" -Color Green
}
catch {
    Write-Log "  Execution failed: $_" -Color Red
    Stop-Transcript -ErrorAction SilentlyContinue | Out-Null
    exit 1
}
finally {
    Stop-Transcript -ErrorAction SilentlyContinue | Out-Null
}

# Scan the captured transcript for any [FAIL] markers from the payload
$PayloadHadFailures = $false
if (Test-Path $LauncherTranscript) {
    $captured = Get-Content -Path $LauncherTranscript -ErrorAction SilentlyContinue
    if ($captured -match '\[FAIL\]') {
        $PayloadHadFailures = $true
    }
    Remove-Item -Path $LauncherTranscript -ErrorAction SilentlyContinue
}

# ------------------------------------------------------------
# [4/5] DOWNLOAD AND INSTALL EVE-NG INTEGRATION PACK
# ------------------------------------------------------------
Write-Step 4 5 "Downloading EVE-NG Integration Pack..."
$ExePath = Join-Path $env:TEMP $ExeName
$ExeInstalled = $false
try {
    # Download the EXE from GitHub Releases (99MB — allow extra time)
    Invoke-WebRequest -Uri $ExeUrl -OutFile $ExePath -UseBasicParsing -TimeoutSec 120
    if (-not (Test-Path $ExePath)) {
        Write-Log "  EXE download failed - file not saved." -Color Red
    } elseif ((Get-Item $ExePath).Length -eq 0) {
        Write-Log "  EXE download failed - file is empty." -Color Red
    } else {
        $sizeMB = [math]::Round((Get-Item $ExePath).Length / 1MB, 1)
        Write-Log "  Integration pack downloaded ($sizeMB MB)" -Color Green

        Write-Step 5 5 "Installing EVE-NG Integration Pack..."
        Write-Log "  Launching installer - please follow the on-screen prompts..." -Color Yellow
        # Run the EXE normally (interactive installer) and wait for it to finish
        $proc = Start-Process -FilePath $ExePath -Wait -PassThru
        if ($proc.ExitCode -eq 0) {
            Write-Log "  Integration pack installed successfully." -Color Green
        } else {
            Write-Log "  Installer exited with code $($proc.ExitCode)" -Color Yellow
        }
        $ExeInstalled = $true
    }
}
catch {
    Write-Log "  EXE download/install failed: $_" -Color Red
}
finally {
    # Clean up the downloaded EXE from temp
    Remove-Item -Path $ExePath -ErrorAction SilentlyContinue
}

# ------------------------------------------------------------
# [5/5] SUMMARY SCREEN
# ------------------------------------------------------------
Write-Step 5 5 "Done"
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OPERATION SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    License Key : $(Get-MaskedKey $LicenseKey)" -ForegroundColor White
Write-Host "    License Exp : $($Response.expires)" -ForegroundColor White
Write-Host "    Script Ver  : $Version" -ForegroundColor White
Write-Host "    Executed At : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host "    Log File    : $LogPath" -ForegroundColor White
if ($ExeInstalled) {
    Write-Host "    EVE-NG Pack : Installed" -ForegroundColor Green
} else {
    Write-Host "    EVE-NG Pack : Not installed" -ForegroundColor Yellow
}
if ($PayloadHadFailures) {
    Write-Host "    Status      : Completed with warnings" -ForegroundColor Yellow
    Write-Host "    Note        : Some steps failed - check output above" -ForegroundColor Yellow
} else {
    Write-Host "    Status      : Completed" -ForegroundColor Green
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Note: If you did not reboot via the prompt above," -ForegroundColor Yellow
Write-Host "        reboot manually before using EVE-NG / VMware." -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Log "  Thank you for using Hyper-V Disabler!" -Color Cyan
Start-Process $LinkedIn
