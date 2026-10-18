# ArtCraft Apps Installer & Manager

A lightweight, cross-platform CLI toolset developed by **Dyal Solutions** to download, install, update, and manage the **ArtCraft** suite of creative, office, and multimedia applications hosted by [storytold](https://github.com/storytold).

---

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [⚡ Direct Download & Run (One-Liner)](#-direct-download--run-one-liner)
- [Supported Applications](#supported-applications)
- [System Requirements & Prerequisites](#system-requirements--prerequisites)
- [Quick Start (Manual)](#quick-start-manual)
  - [Windows](#windows)
  - [Linux](#linux)
- [Directory Structure](#directory-structure)
- [Deployment Modes](#deployment-modes)
- [Rollback & Version Selection](#rollback--version-selection)
- [Troubleshooting](#troubleshooting)
- [Credits](#credits)

---

## 🚀 Overview

The ArtCraft Downloader scripts automate retrieving the appropriate releases from GitHub without requiring manual browsing or downloading. They automatically query the GitHub API, identify suitable system architecture binaries, handle downloading, and set up portable or installer installations.

Both **Windows** (`.bat`) and **Linux** (`.sh`) environments are supported natively.

---

## ✨ Key Features

- **Automated Platform & Architecture Detection:**
  - **Windows:** Auto-detects 64-bit (`x64`), `ARM64`, and 32-bit (`x86`).
  - **Linux:** Auto-detects `x86_64` / `amd64`, `aarch64` / `arm64`, and `riscv64`.
  - **Cross-Platform Target Switching:** Easily download assets for other platforms (Windows, Linux, macOS) directly from the settings menu.
- **Dual Deployment Options:**
  - **Portable:** Downloads self-contained executables, `.zip`, `.tar.gz`, or `.AppImage` files. Automatically extracts archives and sets executable permissions (`chmod +x`).
  - **Installer:** Downloads native setup packages (`.exe`, `.msi`, `.deb`, `.rpm`, `.pkg.tar.zst`, `.flatpak`).
- **Distribution-Aware Linux Packaging:**
  - Automatically identifies Debian/Ubuntu (`.deb`), Fedora/RHEL (`.rpm`), Arch Linux (`.pkg.tar.zst`), or defaults to universal `AppImage`.
- **Version History & Rollbacks:**
  - Browse past releases directly from GitHub.
  - Inspect local downloaded versions to quickly revert or reinstall.
- **Zero Heavy Dependencies:**
  - Built with native shell scripts using PowerShell on Windows and Bash/Python3/cURL on Linux.

---

## ⚡ Direct Download & Run (One-Liner)

You can download and launch the installer directly with a single copy-and-paste command into your terminal without cloning the repository:

### 🪟 Windows

**PowerShell** (recommended):
```powershell
irm https://raw.githubusercontent.com/dyal96/Artcraft-Apps-Downloader/main/Artcraft_Downloader_Windows.bat -OutFile Artcraft_Downloader_Windows.bat; .\Artcraft_Downloader_Windows.bat
```

**Command Prompt (`cmd.exe`)**:
```cmd
curl -fLo Artcraft_Downloader_Windows.bat https://raw.githubusercontent.com/dyal96/Artcraft-Apps-Downloader/main/Artcraft_Downloader_Windows.bat && Artcraft_Downloader_Windows.bat
```

### 🐧 Linux

**Using `curl`**:
```bash
curl -fsSL https://raw.githubusercontent.com/dyal96/Artcraft-Apps-Downloader/main/Artcraft_Downloader_Linux.sh -o Artcraft_Downloader_Linux.sh && chmod +x Artcraft_Downloader_Linux.sh && ./Artcraft_Downloader_Linux.sh
```

**Using `wget`**:
```bash
wget -qO Artcraft_Downloader_Linux.sh https://raw.githubusercontent.com/dyal96/Artcraft-Apps-Downloader/main/Artcraft_Downloader_Linux.sh && chmod +x Artcraft_Downloader_Linux.sh && ./Artcraft_Downloader_Linux.sh
```

---

## 📦 Supported Applications

The scripts manage the following 13 applications from the [storytold](https://github.com/storytold) repository:

| # | Application | App Key | GitHub Repository |
|---|-------------|---------|-------------------|
| 1 | Adobe PDF (pdfcraft) | `adobepdf` | `storytold/pdfcraft` |
| 2 | Photoshop (photocraft) | `photoshop` | `storytold/photocraft` |
| 3 | Lightroom (lightcraft) | `lightroom` | `storytold/lightcraft` |
| 4 | After Effects (effectcraft) | `aftereffect` | `storytold/effectcraft` |
| 5 | Illustrator (vectorcraft) | `illustrator` | `storytold/vectorcraft` |
| 6 | Premiere Pro (filmcraft) | `premiere` | `storytold/filmcraft` |
| 7 | InDesign (designcraft) | `indesign` | `storytold/designcraft` |
| 8 | Microsoft Word (wordcraft) | `word` | `storytold/wordcraft` |
| 9 | Microsoft Excel (gridcraft) | `excel` / `gridcraft` | `storytold/gridcraft` |
| 10 | AutoCAD (cadcraft) | `autocad` / `cadcraft` | `storytold/cadcraft` |
| 11 | Avid Pro Tools (soundcraft) | `protools` / `soundcraft` | `storytold/soundcraft` |
| 12 | Custom Fonts (craft-fonts) | `fonts` / `craft-fonts` | `storytold/craft-fonts` |
| 13 | ArtCraft Suite (artcraft) | `artcraft` | `storytold/artcraft` |

---

## ⚙️ System Requirements & Prerequisites

### Windows
- **OS:** Windows 7 / 8 / 10 / 11 or Windows Server (32-bit, 64-bit, or ARM64)
- **PowerShell:** PowerShell 5.1 or newer (pre-installed on Windows 10/11)
- **Internet Connection:** To query GitHub API and download release assets

### Linux
- **OS:** Any modern Linux distribution (Debian, Ubuntu, Arch, Fedora, openSUSE, etc.)
- **Shell:** `bash`
- **Downloader:** `curl` or `wget`
- **JSON Parser:** `python3` (recommended) or `jq`
- **Archive Utilities (Optional):** `tar` and `unzip` (used when extracting portable packages)

---

## 🏁 Quick Start (Manual)

### Windows

1. Double-click `Artcraft_Downloader_Windows.bat` or run it from Command Prompt / PowerShell:
   ```cmd
   Artcraft_Downloader_Windows.bat
   ```
2. From the main menu:
   - Choose `1` to **Browse & Install / Update Apps**.
   - Select the number corresponding to the application.
   - Choose **Portable** (Option 1) or **Installer** (Option 2).
   - The script will query GitHub, fetch the latest compatible asset, download it into `ArtCraft\`, and extract it if it is a portable ZIP.

### Linux

1. Open your terminal in the directory and ensure the script has execution rights:
   ```bash
   chmod +x Artcraft_Downloader_Linux.sh
   ```
2. Launch the script:
   ```bash
   ./Artcraft_Downloader_Linux.sh
   ```
3. Follow the interactive menu prompts to select your application and preferred package format.

---

## 📁 Directory Structure

Downloaded files and extracted portable apps are stored inside the `ArtCraft/` folder alongside the scripts:

```
Artcraft/
├── Artcraft_Downloader_Windows.bat   # Windows installer script
├── Artcraft_Downloader_Linux.sh      # Linux installer script
├── README.md                         # Documentation
└── ArtCraft/                         # Local storage & runtime directory
    ├── Portable/                     # Portable applications
    │   ├── photoshop/                # Extracted portable Photoshop app
    │   └── <app_key>/                # Other portable applications
    └── Installers/                   # Standalone setup packages
        └── <app_key>/                # Installers (.exe, .msi, .deb, etc.)
```

---

## 🛠️ Deployment Modes

- **Portable:**
  - Installs into `ArtCraft/Portable/<app_key>/`.
  - Windows: Automatically extracts `.zip` packages so applications can be run immediately without installation.
  - Linux: Downloads `.AppImage` or `.tar.gz` files, marks AppImages as executable (`chmod +x`), and unpacks archives.
- **Installer:**
  - Downloads into `ArtCraft/Installers/<app_key>/`.
  - Downloads native setup packages (e.g. `.exe`, `.msi`, `.deb`, `.rpm`) ready for system-wide manual installation.

---

## 🔄 Rollback & Version Selection

If an update causes issues or you need a legacy release:

1. **GitHub Releases History (Online):**
   - Select an app and choose **Check Updates / Select Specific Version**.
   - Browse the numbered list of previous release tags and select the desired release.
2. **Local Rollback Manager (Offline):**
   - Choose **Rollback to a Previous Version** from the main menu.
   - View previously downloaded archives and installers stored in your local `ArtCraft/` folders.

---

## ❓ Troubleshooting

- **GitHub API Rate Limits:**
  - If you encounter rate-limiting errors (`403 API rate limit exceeded`), wait a few minutes before trying again or avoid rapid consecutive release queries.
- **PowerShell Execution Policy (Windows):**
  - The batch script automatically uses `-ExecutionPolicy Bypass` for internal PowerShell calls. If blocked by corporate policy, run PowerShell as Administrator and run:
    ```powershell
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
    ```
- **Missing Python3 on Linux:**
  - Install Python 3 using your system package manager:
    ```bash
    sudo apt install python3      # Debian / Ubuntu
    sudo dnf install python3      # Fedora / RHEL
    sudo pacman -S python         # Arch Linux
    ```

---

## 👨‍💻 Credits

- **Developer:** Dyal Solutions ([@dyal96](https://github.com/dyal96))
- **Installer Repository:** [dyal96/Artcraft-Apps-Downloader](https://github.com/dyal96/Artcraft-Apps-Downloader)
- **Application Binaries Host:** [storytold](https://github.com/storytold)
