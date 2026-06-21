# Hyper-V Complete Disabler

> Fully automated script to disable Hyper-V, VBS, Device Guard, Credential Guard, and Memory Integrity on Windows 10 / 11 — including 24H2.

**By [VigneshVijayK](https://github.com/VigneshVijayK)**

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

## License

All Rights Reserved.
