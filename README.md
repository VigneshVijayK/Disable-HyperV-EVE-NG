# Hyper-V Complete Disabler

> Fully automated script to disable Hyper-V, VBS, Device Guard, Credential Guard, and Memory Integrity on Windows 10 / 11 — including 24H2.

**By [VigneshVijayK](https://github.com/VigneshVijayK)**

Free your VT-x / AMD-V so you can run **EVE-NG**, **VMware Workstation**, **VirtualBox**, **GNS3**, or **QEMU** without conflicts.

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

### Option C : Download and Run Manually

If you prefer to inspect the script before running it:

1. Download [Disable-HyperV-EVE-NG.ps1](https://raw.githubusercontent.com/VigneshVijayK/Disable-HyperV-EVE-NG/main/Disable-HyperV-EVE-NG.ps1)
2. Right-click the downloaded file → **Properties** → check **Unblock** → **OK**
3. Open **PowerShell as Administrator**, navigate to the download folder, and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Disable-HyperV-EVE-NG.ps1
```

---

## How to Open CMD / PowerShell as Administrator

1. Press **Win + S** and type `cmd` or `powershell`
2. Right-click the result and select **Run as administrator**
3. Click **Yes** on the UAC prompt
4. Paste the command from above and press **Enter**

---

## What the Script Does

The script runs through **9 automated steps** and shows you the result of each one in colour — green for success, yellow for a warning, red for a failure.

| Step | Action | Details |
|:----:|--------|---------|
| 0 | **Pre-flight checks** | Confirms Administrator privileges and reads your Windows version |
| 1 | **Stop Hyper-V services** | Stops and disables all Hyper-V background services (`vmms`, `vmcompute`, `HvHost`, etc.) |
| 2 | **Remove Windows features** | Disables Hyper-V, Windows Hypervisor Platform, Virtual Machine Platform, and WSL |
| 3 | **BCD boot config** | Sets `hypervisorlaunchtype = Off` so the hypervisor does not load at boot |
| 4 | **Disable Device Guard / VBS** | Clears Device Guard and Virtualization-Based Security registry keys |
| 5 | **Disable Memory Integrity** | Turns off HVCI / Core Isolation via registry |
| 6 | **Disable Device Guard / Credential Guard** | Removes CI policy files, cleans EFI partition, and creates the BCD entry that triggers the F3 prompt *(no internet needed)* |
| 7 | **BCD verification** | Double-checks the boot setting and re-applies it if something was missed |
| 8 | **Verification dump** | Takes a DISM and registry snapshot and saves it to the log file |

At the end, the script asks if you want to reboot now or later.

---

## What Gets Changed on Your System

For full transparency, here is exactly what the script modifies:

### BCD (Boot Configuration Data)
```
hypervisorlaunchtype = Off
```

### Registry Keys Set to 0 (Disabled)

| Path | Value |
|------|-------|
| `HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard` | `EnableVirtualizationBasedSecurity` |
| `HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard` | `RequirePlatformSecurityFeatures` |
| `HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard` | `Locked` |
| `HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard` | `EnableVirtualizationBasedSecurity` |
| `HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard` | `RequirePlatformSecurityFeatures` |
| `HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard` | `HVCIPolicy` |
| `HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard` | `HypervisorEnforcedCodeIntegrity` |
| `HKLM:\SYSTEM\CurrentControlSet\Control\Lsa` | `LsaCfgFlags` |
| `HKLM:\...\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity` | `Enabled` |
| `HKLM:\...\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity` | `Locked` |

### Windows Features Disabled
- `Microsoft-Hyper-V-All` (and all sub-features)
- `HypervisorPlatform`
- `VirtualMachinePlatform`
- `Microsoft-Windows-Subsystem-Linux`

---

## Important — During the Reboot

After rebooting, Windows may show a blue screen asking you to confirm a security change.

> **If that screen appears — press F3 to confirm.**

This is normal and only happens once. It is most common on Windows 11 24H2.

---

## Confirm It Worked

After rebooting, open **CMD as Administrator** and run:

```cmd
bcdedit /enum {current}
```

Look for this line in the output:

```
hypervisorlaunchtype        Off
```

If it says `Off` — Hyper-V is fully disabled and you can now run EVE-NG, VMware, VirtualBox, or any other bare-metal hypervisor.

---

## Troubleshooting

### "This script must be run as Administrator"
Close your terminal and reopen it using **right-click → Run as administrator**.

### EVE-NG / VMware still shows a VT-x error after reboot
1. Run the script again and reboot.
2. Enter your **BIOS/UEFI settings** and verify that **VT-x** (Intel) or **AMD-V / SVM** (AMD) is **enabled**. This is a separate hardware setting that must be on.

### Windows Hello PIN stopped working
This is expected after Step 6. The DG Readiness Tool disables Credential Guard, which Windows Hello PIN depends on. After the second reboot, set up your PIN again from **Settings → Accounts → Sign-in options** and it will work normally.

### DG_Readiness_Tool download note
Step 6 performs all Device Guard and Credential Guard disable operations **inline** — no internet is required. Microsoft deprecated the DG_Readiness_Tool download, so the script no longer depends on it. If you happen to have the tool available, the script will run it as an extra safeguard, but it is **not required**.

### Script shows `[ WARN ]` for a service or feature
This is expected. A warning means the service or feature was not installed on your machine, so the script skipped it. Only `[ FAIL ]` entries indicate a problem.

### Where are the logs?
Every run saves a full transcript to:
```
C:\HyperV-Disabler-Logs\
```
If something fails, open that folder and review the `.log` file. Search for `[ FAIL ]` or `[ WARN ]` entries.

---

## Undo Everything — Re-enable Hyper-V

To reverse all changes and bring Hyper-V back:

1. Open **CMD as Administrator** and run:

```cmd
bcdedit /set hypervisorlaunchtype auto
```

2. Go to **Control Panel → Programs → Turn Windows features on or off**
3. Tick **Hyper-V**, **Windows Hypervisor Platform**, and any other features you need
4. Reboot

---

## Requirements

| Requirement | Details |
|---|---|
| **OS** | Windows 10 (Build 19041+) or Windows 11 |
| **Privileges** | Must run as Administrator |
| **PowerShell** | Version 5.1 or later (included in Windows 10/11) |
| **Internet** | Not required. The script is fully self-contained. |
| **BIOS** | VT-x (Intel) or AMD-V / SVM (AMD) must be **enabled** in BIOS/UEFI |

---

## Tested On

- Windows 10 21H2+
- Windows 11 22H2
- Windows 11 23H2
- Windows 11 24H2

---

## Disclaimer

This script modifies Windows boot configuration, registry settings, and security features. While every change is reversible (see "Undo Everything" above), **use it at your own risk**. Always ensure you have a current backup or system restore point before running system-level tools.

---

## License

This project is provided as-is for educational and professional use. Feel free to fork, modify, and distribute with attribution.

---

*v2.0.0 — [VigneshVijayK](https://github.com/VigneshVijayK)*
