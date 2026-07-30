# Hyper-V Complete Disabler  v5.0.0

> Fully automated script to disable Hyper-V, VBS, Device Guard, Credential Guard, and Memory Integrity on Windows 10 / 11 — including 24H2.

**By [VigneshVijayK](https://github.com/VigneshVijayK)** | [LinkedIn](https://in.linkedin.com/in/vignesh-vijay-k)

---

## Features

- **Pre-action confirmation menu** — review your license details before proceeding
- **Step-counter progress** — clear `[1/4]` → `[4/4]` indicators throughout
- **Post-execution summary** — full report with license info, timestamp, and log path
- **Smart failure detection** — yellow "Completed with warnings" if any step fails, green "Completed" only when everything succeeds
- **Automatic logging** — every action is logged to `%TEMP%\hyperv-disabler.log` (append mode, keeps history across runs)
- **Empty key validation** — exits immediately if no key is entered, no wasted API calls
- **Color-coded output** — Cyan (headers), Yellow (steps/prompts), Green (success), Red (errors)

---

## Compatible With

| Platform | Status |
|---|---|
| **EVE-NG** | ✅ Supported |
| **VMware Workstation** | ✅ Supported |
| **VirtualBox** | ✅ Supported |
| **GNS3** | ✅ Supported |
| **QEMU** | ✅ Supported |

---

## How It Works

```mermaid
flowchart TD
    A[Run as Administrator] --> B[Enter license key]
    B --> C[Validate license against server]
    C --> D{Valid?}
    D -->|No - Expired| E[Press R to renew]
    D -->|No - Invalid| F[Press B to buy]
    D -->|No - Server error| G[Press R to report]
    D -->|Yes| H[Pre-action menu]
    H --> I{Choice}
    I -->|1. Proceed| J[Download & execute payload]
    I -->|2. View license| K[Show details → re-menu]
    I -->|3. Exit| L[Clean exit]
    J --> M[Summary screen]
    M --> N[Reboot prompt from disabler]
```

1. **Enter license key** — validated against the license server
2. **Pre-action menu** — choose to proceed, view license details, or exit
3. **Download & execute** — payload runs in-memory (never touches disk)
4. **Summary screen** — shows status, log path, and next steps
5. **Reboot prompt** — the disabler asks if you want to reboot now

---

## Quick Start — One Command

### Option A : Run from Command Prompt (CMD)

Open **CMD as Administrator** and paste this:

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/VigneshVijayK/Disable-HyperV-EVE-NG/main/Disable-HyperV-EVE-NG.ps1 | iex"
```

### Option B : Run from PowerShell

Open **PowerShell as Administrator** and paste this:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
irm https://raw.githubusercontent.com/VigneshVijayK/Disable-HyperV-EVE-NG/main/Disable-HyperV-EVE-NG.ps1 | iex
```

---

## License Key

This script requires a valid license key to run.

- **Don't have a key?** [Purchase a license here](https://vigneshvijayk.github.io/VigneshVijayK/)
- **Need to renew?** [Renew your license here](https://vigneshvijayk.github.io/VigneshVijayK/)
- **Have a key?** Enter it when prompted.

| Scenario | Action |
|----------|--------|
| Invalid key | Press **B** to visit purchase page |
| Expired key | Press **R** to visit renewal page |
| Server unreachable | Press **R** to report to developer |
| Empty key (Enter pressed) | Exits automatically — no API call made |

---

## How to Open CMD / PowerShell as Administrator

1. Press **Win + S** and type `cmd` or `powershell`
2. Right-click the result and select **Run as administrator**
3. Click **Yes** on the UAC prompt

---

## Requirements

| Requirement | Details |
|---|---|
| **OS** | Windows 10 (Build 19041+) or Windows 11 |
| **Privileges** | Must run as Administrator |
| **PowerShell** | Version 5.1 or later |
| **Internet** | Required for license validation |
| **BIOS** | VT-x (Intel) or AMD-V (AMD) must be enabled |

---

## Logging

All actions are automatically logged to:

```
%TEMP%\hyperv-disabler.log
```

- **Append mode** — history is preserved across multiple runs
- **Session separator** — each run starts with a timestamped separator line
- **Machine info** — computer name and OS version recorded per session
- **All actions logged** — license validation, menu choices, downloads, execution, errors

To view your log:

```powershell
notepad %TEMP%\hyperv-disabler.log
```

---

## License

All Rights Reserved.
