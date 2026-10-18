@echo off
setlocal EnableDelayedExpansion
title ArtCraft Apps Installer by Dyal Solutions

:: ==========================================
:: CONFIGURATION & MAPPINGS
:: ==========================================
set "REPO_OWNER=storytold"

:: Define Apps (Format: Key|Display Name|GitHub Repo Name)
set "app_count=13"
set "app[1]=adobepdf|Adobe PDF (pdfcraft)|pdfcraft"
set "app[2]=photoshop|Photoshop (photocraft)|photocraft"
set "app[3]=lightroom|Lightroom (lightcraft)|lightcraft"
set "app[4]=aftereffect|After Effects (effectcraft)|effectcraft"
set "app[5]=illustrator|Illustrator (vectorcraft)|vectorcraft"
set "app[6]=premiere|Premiere Pro (filmcraft)|filmcraft"
set "app[7]=indesign|InDesign (designcraft)|designcraft"
set "app[8]=word|Microsoft Word (wordcraft)|wordcraft"
set "app[9]=excel|Microsoft Excel (gridcraft)|gridcraft"
set "app[10]=autocad|AutoCAD (cadcraft)|cadcraft"
set "app[11]=protools|Avid Pro Tools (soundcraft)|soundcraft"
set "app[12]=fonts|Custom Fonts (craft-fonts)|craft-fonts"
set "app[13]=artcraft|ArtCraft (artcraft)|artcraft"

:: Setup Working Directories
set "BASE_DIR=%~dp0ArtCraft"
set "PORTABLE_DIR=%BASE_DIR%\Portable"
set "INSTALLER_DIR=%BASE_DIR%\Installers"

if not exist "%PORTABLE_DIR%" mkdir "%PORTABLE_DIR%"
if not exist "%INSTALLER_DIR%" mkdir "%INSTALLER_DIR%"

:: Check for PowerShell (needed for GitHub API & downloads)
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] PowerShell is required to run this script.
    pause
    exit /b
)

:: Detect System OS & Architecture
set "TARGET_OS=windows"
set "OS_LABEL=Windows"

if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
    set "TARGET_ARCH=arm64"
    set "ARCH_LABEL=ARM64"
) else if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set "TARGET_ARCH=x64"
    set "ARCH_LABEL=64-bit (x64)"
) else if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" (
    set "TARGET_ARCH=x64"
    set "ARCH_LABEL=64-bit (x64)"
) else (
    set "TARGET_ARCH=x86"
    set "ARCH_LABEL=32-bit (x86)"
)

:MAIN_MENU
cls
echo ========================================================
echo         ArtCraft Apps Installer by Dyal Solutions         
echo ========================================================
echo Target Platform: %OS_LABEL% [%ARCH_LABEL%]
echo Working Directory: %BASE_DIR%
echo --------------------------------------------------------
echo  1. Browse ^& Install / Update Apps
echo  2. Rollback to a Previous Version
echo  3. Change Target OS / Architecture
echo  4. Exit
echo --------------------------------------------------------
set "choice="
set /p "choice=Select an option [1-4]: "
if not defined choice goto MAIN_MENU

if "%choice%"=="1" goto APP_LIST
if "%choice%"=="2" goto ROLLBACK_MENU
if "%choice%"=="3" goto SETTINGS_MENU
if "%choice%"=="4" exit /b
goto MAIN_MENU

:: ==========================================
:: TARGET OS / ARCH SETTINGS
:: ==========================================
:SETTINGS_MENU
cls
echo ========================================================
echo             TARGET PLATFORM CONFIGURATION               
echo ========================================================
echo Current Target: %OS_LABEL% [%ARCH_LABEL%]
echo.
echo Select Target Platform:
echo  1. Windows (x64 / 64-bit) [Default]
echo  2. Windows (ARM64)
echo  3. Windows (x86 / 32-bit)
echo  4. macOS (Universal / x64 / Apple Silicon)
echo  5. Linux (x86_64)
echo  6. Linux (ARM64 / aarch64)
echo  0. Back to Main Menu
echo --------------------------------------------------------
set "set_choice="
set /p "set_choice=Select option [0-6]: "
if not defined set_choice goto MAIN_MENU

if "%set_choice%"=="0" goto MAIN_MENU
if "%set_choice%"=="1" (
    set "TARGET_OS=windows"
    set "OS_LABEL=Windows"
    set "TARGET_ARCH=x64"
    set "ARCH_LABEL=64-bit (x64)"
)
if "%set_choice%"=="2" (
    set "TARGET_OS=windows"
    set "OS_LABEL=Windows"
    set "TARGET_ARCH=arm64"
    set "ARCH_LABEL=ARM64"
)
if "%set_choice%"=="3" (
    set "TARGET_OS=windows"
    set "OS_LABEL=Windows"
    set "TARGET_ARCH=x86"
    set "ARCH_LABEL=32-bit (x86)"
)
if "%set_choice%"=="4" (
    set "TARGET_OS=macos"
    set "OS_LABEL=macOS"
    set "TARGET_ARCH=universal"
    set "ARCH_LABEL=Universal / ARM / Intel"
)
if "%set_choice%"=="5" (
    set "TARGET_OS=linux"
    set "OS_LABEL=Linux"
    set "TARGET_ARCH=x86_64"
    set "ARCH_LABEL=x86_64"
)
if "%set_choice%"=="6" (
    set "TARGET_OS=linux"
    set "OS_LABEL=Linux"
    set "TARGET_ARCH=aarch64"
    set "ARCH_LABEL=ARM64 (aarch64)"
)
goto MAIN_MENU

:: ==========================================
:: APP SELECTION & INSTALLATION
:: ==========================================
:APP_LIST
cls
echo ========================================================
echo                     AVAILABLE APPS                      
echo ========================================================
echo Target Platform: %OS_LABEL% [%ARCH_LABEL%]
echo --------------------------------------------------------
for /l %%i in (1,1,%app_count%) do (
    for /f "tokens=1,2,3 delims=|" %%a in ("!app[%%i]!") do (
        echo  %%i. %%b
    )
)
echo  0. Back to Main Menu
echo --------------------------------------------------------
set "app_choice="
set /p "app_choice=Select an app to manage [0-%app_count%]: "
if not defined app_choice goto APP_LIST

if "%app_choice%"=="0" goto MAIN_MENU
if %app_choice% LSS 1 goto APP_LIST
if %app_choice% GTR %app_count% goto APP_LIST

:: Extract selected app info
for /f "tokens=1,2,3 delims=|" %%a in ("!app[%app_choice%]!") do (
    set "app_key=%%a"
    set "app_name=%%b"
    set "app_repo=%%c"
)

:APP_SUBMENU
cls
echo ========================================================
echo  Managing: %app_name%
echo ========================================================
echo  Platform: %OS_LABEL% [%ARCH_LABEL%]
echo --------------------------------------------------------
echo  1. Portable Version
echo  2. Installer Version
echo  3. Check Updates / Select Specific Version
echo  0. Back
echo --------------------------------------------------------
set "type_choice="
set /p "type_choice=Select deployment type [0-3]: "
if not defined type_choice goto APP_SUBMENU

if "%type_choice%"=="0" goto APP_LIST
if "%type_choice%"=="1" (
    set "install_type=Portable"
    set "target_folder=%PORTABLE_DIR%\%app_key%"
) else if "%type_choice%"=="2" (
    set "install_type=Installer"
    set "target_folder=%INSTALLER_DIR%\%app_key%"
) else if "%type_choice%"=="3" (
    goto FETCH_VERSIONS
) else (
    goto APP_SUBMENU
)

if not exist "%target_folder%" mkdir "%target_folder%"

echo.
echo [*] Fetching latest release for %app_name% (%OS_LABEL% %ARCH_LABEL%)...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$repo = '%REPO_OWNER%/%app_repo%';" ^
    "$os = '%TARGET_OS%';" ^
    "$arch = '%TARGET_ARCH%';" ^
    "$type = '%install_type%';" ^
    "$url = \"https://api.github.com/repos/$repo/releases/latest\";" ^
    "try {" ^
    "  $res = Invoke-RestMethod -Uri $url -Headers @{ 'User-Agent'='PowerShell' } -ErrorAction Stop;" ^
    "  Write-Host ('[*] Latest release: ' + $res.tag_name + ' (' + $res.name + ')');" ^
    "  $cand = $res.assets | Where-Object { $n = $_.name.ToLower(); -not ($n -like '*sha256*' -or $n -like '*.zsync' -or $n -like '*-web-*' -or $n -like '*checksums*') };" ^
    "  if ($os -eq 'windows') {" ^
    "    $cand = $cand | Where-Object { $n = $_.name.ToLower(); ($n -like '*windows*' -or $n -like '*.exe' -or $n -like '*.msi' -or $n -like '*.zip') -and -not ($n -like '*-macos*' -or $n -like '*-linux*' -or $n -like '*-freebsd*' -or $n -like '*.dmg' -or $n -like '*.deb' -or $n -like '*.rpm' -or $n -like '*.appimage' -or $n -like '*.tar.gz' -or $n -like '*-cli-*') };" ^
    "  } elseif ($os -eq 'macos') {" ^
    "    $cand = $cand | Where-Object { $n = $_.name.ToLower(); ($n -like '*-macos*' -or $n -like '*.dmg' -or $n -like '*.pkg' -or $n -like '*.app.tar.gz') -and -not ($n -like '*-cli-*' -or $n -like '*windows*' -or $n -like '*-linux*') };" ^
    "  } elseif ($os -eq 'linux') {" ^
    "    $cand = $cand | Where-Object { $n = $_.name.ToLower(); ($n -like '*-linux*' -or $n -like '*.appimage' -or $n -like '*.deb' -or $n -like '*.rpm' -or $n -like '*.flatpak' -or $n -like '*.pkg.tar.zst') -and -not ($n -like '*-macos*' -or $n -like '*windows*') };" ^
    "  }" ^
    "  if ($arch -eq 'x64') {" ^
    "    $archCand = $cand | Where-Object { $n = $_.name.ToLower(); ($n -like '*x64*' -or $n -like '*x86_64*' -or $n -like '*amd64*') -or (-not ($n -like '*arm64*' -or $n -like '*aarch64*' -or $n -like '*-x86.*' -or $n -like '*-x86-*' -or $n -like '*win32*')) };" ^
    "    $archCand = $archCand | Where-Object { $n = $_.name.ToLower(); -not ($n -like '*arm64*' -or $n -like '*aarch64*' -or $n -like '*-x86.*' -or $n -like '*-x86-*' -or $n -like '*win32*') };" ^
    "  } elseif ($arch -eq 'arm64') {" ^
    "    $archCand = $cand | Where-Object { $n = $_.name.ToLower(); $n -like '*arm64*' -or $n -like '*aarch64*' };" ^
    "  } elseif ($arch -eq 'x86') {" ^
    "    $archCand = $cand | Where-Object { $n = $_.name.ToLower(); ($n -like '*-x86.*' -or $n -like '*-x86-*' -or $n -like '*win32*' -or $n -like '*i386*') -and -not ($n -like '*x64*' -or $n -like '*x86_64*') };" ^
    "  } elseif ($arch -eq 'x86_64') {" ^
    "    $archCand = $cand | Where-Object { $n = $_.name.ToLower(); $n -like '*x86_64*' -or $n -like '*amd64*' };" ^
    "  } elseif ($arch -eq 'aarch64') {" ^
    "    $archCand = $cand | Where-Object { $n = $_.name.ToLower(); $n -like '*aarch64*' -or $n -like '*arm64*' };" ^
    "  }" ^
    "  if ($archCand -and $archCand.Count -gt 0) { $cand = $archCand; }" ^
    "  $asset = $null;" ^
    "  if ($type -eq 'Portable') {" ^
    "    $asset = $cand | Where-Object { $_.name.ToLower() -like '*portable*' } | Select-Object -First 1;" ^
    "    if (-not $asset) { $asset = $cand | Where-Object { $n = $_.name.ToLower(); $n -like '*.zip' -or $n -like '*.7z' -or $n -like '*.appimage' -or $n -like '*.tar.gz' } | Select-Object -First 1; }" ^
    "    if (-not $asset) { $asset = $cand | Where-Object { $_.name.ToLower() -like '*.exe' -or $_.name.ToLower() -like '*.dmg' } | Select-Object -First 1; }" ^
    "  } else {" ^
    "    $asset = $cand | Where-Object { $n = $_.name.ToLower(); ($n -like '*setup*.exe' -or $n -like '*.exe') -and -not ($n -like '*portable*') } | Select-Object -First 1;" ^
    "    if (-not $asset) { $asset = $cand | Where-Object { $n = $_.name.ToLower(); $n -like '*.msi' -or $n -like '*.pkg' -or $n -like '*.deb' -or $n -like '*.rpm' } | Select-Object -First 1; }" ^
    "    if (-not $asset) { $asset = $cand | Where-Object { -not ($_.name.ToLower() -like '*portable*') } | Select-Object -First 1; }" ^
    "    if (-not $asset) { $asset = $cand | Select-Object -First 1; }" ^
    "  }" ^
    "  if ($asset) {" ^
    "    $mb = [math]::Round($asset.size / 1MB, 2);" ^
    "    Write-Host ('[+] Matched OS asset: ' + $asset.name + ' (' + $mb + ' MB)');" ^
    "    Write-Host ('[*] Downloading to ' + '%target_folder%\' + $asset.name + '...');" ^
    "    $ProgressPreference = 'SilentlyContinue';" ^
    "    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile ('%target_folder%\' + $asset.name);" ^
    "    Write-Host '[OK] Download Complete.';" ^
    "    if ($type -eq 'Portable' -and ($asset.name -like '*.zip')) {" ^
    "      Write-Host ('[*] Unzipping portable archive to: ' + '%target_folder%');" ^
    "      try {" ^
    "        Expand-Archive -LiteralPath ('%target_folder%\' + $asset.name) -DestinationPath '%target_folder%' -Force;" ^
    "        Write-Host '[OK] Extraction Complete. Portable application is ready to use.';" ^
    "      } catch {" ^
    "        Write-Host ('[NOTICE] Extraction notice: ' + $_.Exception.Message);" ^
    "      }" ^
    "    }" ^
    "  } else {" ^
    "    Write-Host ('[-] No matching asset found for ' + $os + ' (' + $arch + ') in release.');" ^
    "  }" ^
    "} catch { Write-Host ('[ERROR] ' + $_.Exception.Message); }"

echo.
pause
goto APP_LIST

:: ==========================================
:: VERSION SELECTION & UPDATE CHECKING
:: ==========================================
:FETCH_VERSIONS
cls
echo ========================================================
echo  Fetching Release History for %app_name%...
echo ========================================================
echo Target Platform: %OS_LABEL% [%ARCH_LABEL%]
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$repo = '%REPO_OWNER%/%app_repo%';" ^
    "$os = '%TARGET_OS%';" ^
    "$arch = '%TARGET_ARCH%';" ^
    "$url = \"https://api.github.com/repos/$repo/releases\";" ^
    "try { $releases = Invoke-RestMethod -Uri $url -Headers @{ 'User-Agent'='PowerShell' } -ErrorAction Stop; " ^
    "  $i = 1; " ^
    "  foreach ($rel in $releases) { " ^
    "    Write-Host ('[' + $i + '] ' + $rel.tag_name + ' - ' + $rel.name); " ^
    "    $osAssets = $rel.assets | Where-Object { $n = $_.name.ToLower(); -not ($n -like '*sha256*' -or $n -like '*.zsync' -or $n -like '*-web-*' -or $n -like '*checksums*') }; " ^
    "    if ($os -eq 'windows') { $osAssets = $osAssets | Where-Object { $n = $_.name.ToLower(); ($n -like '*windows*' -or $n -like '*.exe' -or $n -like '*.msi' -or $n -like '*.zip') -and -not ($n -like '*-macos*' -or $n -like '*-linux*' -or $n -like '*-freebsd*' -or $n -like '*.dmg' -or $n -like '*.deb' -or $n -like '*.rpm' -or $n -like '*.appimage' -or $n -like '*.tar.gz' -or $n -like '*-cli-*') } } " ^
    "    elseif ($os -eq 'macos') { $osAssets = $osAssets | Where-Object { $n = $_.name.ToLower(); ($n -like '*-macos*' -or $n -like '*.dmg' -or $n -like '*.pkg' -or $n -like '*.app.tar.gz') -and -not ($n -like '*-cli-*' -or $n -like '*windows*' -or $n -like '*-linux*') } } " ^
    "    elseif ($os -eq 'linux') { $osAssets = $osAssets | Where-Object { $n = $_.name.ToLower(); ($n -like '*-linux*' -or $n -like '*.appimage' -or $n -like '*.deb' -or $n -like '*.rpm' -or $n -like '*.flatpak') -and -not ($n -like '*-macos*' -or $n -like '*windows*') } } " ^
    "    if ($arch -eq 'x64') { $f = $osAssets | Where-Object { $n = $_.name.ToLower(); -not ($n -like '*arm64*' -or $n -like '*aarch64*' -or $n -like '*-x86.*' -or $n -like '*-x86-*' -or $n -like '*win32*') }; if ($f) { $osAssets = $f } } " ^
    "    elseif ($arch -eq 'arm64' -or $arch -eq 'aarch64') { $f = $osAssets | Where-Object { $n = $_.name.ToLower(); $n -like '*arm64*' -or $n -like '*aarch64*' }; if ($f) { $osAssets = $f } } " ^
    "    elseif ($arch -eq 'x86') { $f = $osAssets | Where-Object { $n = $_.name.ToLower(); ($n -like '*-x86.*' -or $n -like '*-x86-*' -or $n -like '*win32*') -and -not ($n -like '*x64*' -or $n -like '*x86_64*') }; if ($f) { $osAssets = $f } } " ^
    "    if ($osAssets) { foreach ($ast in $osAssets) { Write-Host ('    - ' + $ast.name + ' (' + [math]::Round($ast.size / 1MB, 2) + ' MB)'); } } " ^
    "    else { Write-Host '    (No matching assets for current OS/Arch)'; } " ^
    "    $i++; " ^
    "  } " ^
    "} catch { Write-Host ('[ERROR] ' + $_.Exception.Message); }"

echo.
echo --------------------------------------------------------
set "ver_num="
set /p "ver_num=Enter the release number to download (or 0 to cancel): "
if not defined ver_num goto APP_LIST
if "%ver_num%"=="0" goto APP_LIST

:: Prompt user for Portable/Installer folder placement
echo.
echo Choose deployment type:
echo 1. Portable (%PORTABLE_DIR%\%app_key%)
echo 2. Installer (%INSTALLER_DIR%\%app_key%)
set "folder_choice="
set /p "folder_choice=Select [1-2]: "
if not defined folder_choice set "folder_choice=1"
if "%folder_choice%"=="1" (
    set "install_type=Portable"
    set "target_folder=%PORTABLE_DIR%\%app_key%"
) else (
    set "install_type=Installer"
    set "target_folder=%INSTALLER_DIR%\%app_key%"
)
if not exist "%target_folder%" mkdir "%target_folder%"

echo.
echo [*] Downloading selected version for %OS_LABEL% [%ARCH_LABEL%]...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$repo = '%REPO_OWNER%/%app_repo%';" ^
    "$os = '%TARGET_OS%';" ^
    "$arch = '%TARGET_ARCH%';" ^
    "$type = '%install_type%';" ^
    "$ver = %ver_num%;" ^
    "$url = \"https://api.github.com/repos/$repo/releases\";" ^
    "try {" ^
    "  $releases = Invoke-RestMethod -Uri $url -Headers @{ 'User-Agent'='PowerShell' } -ErrorAction Stop;" ^
    "  if ($ver -lt 1 -or $ver -gt $releases.Count) { throw 'Invalid release number selected.'; }" ^
    "  $selected = $releases[$ver - 1];" ^
    "  Write-Host ('[*] Selected release: ' + $selected.tag_name + ' (' + $selected.name + ')');" ^
    "  $cand = $selected.assets | Where-Object { $n = $_.name.ToLower(); -not ($n -like '*sha256*' -or $n -like '*.zsync' -or $n -like '*-web-*' -or $n -like '*checksums*') };" ^
    "  if ($os -eq 'windows') {" ^
    "    $cand = $cand | Where-Object { $n = $_.name.ToLower(); ($n -like '*windows*' -or $n -like '*.exe' -or $n -like '*.msi' -or $n -like '*.zip') -and -not ($n -like '*-macos*' -or $n -like '*-linux*' -or $n -like '*-freebsd*' -or $n -like '*.dmg' -or $n -like '*.deb' -or $n -like '*.rpm' -or $n -like '*.appimage' -or $n -like '*.tar.gz' -or $n -like '*-cli-*') };" ^
    "  } elseif ($os -eq 'macos') {" ^
    "    $cand = $cand | Where-Object { $n = $_.name.ToLower(); ($n -like '*-macos*' -or $n -like '*.dmg' -or $n -like '*.pkg' -or $n -like '*.app.tar.gz') -and -not ($n -like '*-cli-*' -or $n -like '*windows*' -or $n -like '*-linux*') };" ^
    "  } elseif ($os -eq 'linux') {" ^
    "    $cand = $cand | Where-Object { $n = $_.name.ToLower(); ($n -like '*-linux*' -or $n -like '*.appimage' -or $n -like '*.deb' -or $n -like '*.rpm' -or $n -like '*.flatpak' -or $n -like '*.pkg.tar.zst') -and -not ($n -like '*-macos*' -or $n -like '*windows*') };" ^
    "  }" ^
    "  if ($arch -eq 'x64') {" ^
    "    $archCand = $cand | Where-Object { $n = $_.name.ToLower(); ($n -like '*x64*' -or $n -like '*x86_64*' -or $n -like '*amd64*') -or (-not ($n -like '*arm64*' -or $n -like '*aarch64*' -or $n -like '*-x86.*' -or $n -like '*-x86-*' -or $n -like '*win32*')) };" ^
    "    $archCand = $archCand | Where-Object { $n = $_.name.ToLower(); -not ($n -like '*arm64*' -or $n -like '*aarch64*' -or $n -like '*-x86.*' -or $n -like '*-x86-*' -or $n -like '*win32*') };" ^
    "  } elseif ($arch -eq 'arm64') {" ^
    "    $archCand = $cand | Where-Object { $n = $_.name.ToLower(); $n -like '*arm64*' -or $n -like '*aarch64*' };" ^
    "  } elseif ($arch -eq 'x86') {" ^
    "    $archCand = $cand | Where-Object { $n = $_.name.ToLower(); ($n -like '*-x86.*' -or $n -like '*-x86-*' -or $n -like '*win32*' -or $n -like '*i386*') -and -not ($n -like '*x64*' -or $n -like '*x86_64*') };" ^
    "  } elseif ($arch -eq 'x86_64') {" ^
    "    $archCand = $cand | Where-Object { $n = $_.name.ToLower(); $n -like '*x86_64*' -or $n -like '*amd64*' };" ^
    "  } elseif ($arch -eq 'aarch64') {" ^
    "    $archCand = $cand | Where-Object { $n = $_.name.ToLower(); $n -like '*aarch64*' -or $n -like '*arm64*' };" ^
    "  }" ^
    "  if ($archCand -and $archCand.Count -gt 0) { $cand = $archCand; }" ^
    "  $asset = $null;" ^
    "  if ($type -eq 'Portable') {" ^
    "    $asset = $cand | Where-Object { $_.name.ToLower() -like '*portable*' } | Select-Object -First 1;" ^
    "    if (-not $asset) { $asset = $cand | Where-Object { $n = $_.name.ToLower(); $n -like '*.zip' -or $n -like '*.7z' -or $n -like '*.appimage' -or $n -like '*.tar.gz' } | Select-Object -First 1; }" ^
    "    if (-not $asset) { $asset = $cand | Where-Object { $_.name.ToLower() -like '*.exe' -or $_.name.ToLower() -like '*.dmg' } | Select-Object -First 1; }" ^
    "  } else {" ^
    "    $asset = $cand | Where-Object { $n = $_.name.ToLower(); ($n -like '*setup*.exe' -or $n -like '*.exe') -and -not ($n -like '*portable*') } | Select-Object -First 1;" ^
    "    if (-not $asset) { $asset = $cand | Where-Object { $n = $_.name.ToLower(); $n -like '*.msi' -or $n -like '*.pkg' -or $n -like '*.deb' -or $n -like '*.rpm' } | Select-Object -First 1; }" ^
    "    if (-not $asset) { $asset = $cand | Where-Object { -not ($_.name.ToLower() -like '*portable*') } | Select-Object -First 1; }" ^
    "    if (-not $asset) { $asset = $cand | Select-Object -First 1; }" ^
    "  }" ^
    "  if ($asset) {" ^
    "    $mb = [math]::Round($asset.size / 1MB, 2);" ^
    "    Write-Host ('[+] Matched OS asset: ' + $asset.name + ' (' + $mb + ' MB)');" ^
    "    Write-Host ('[*] Downloading to ' + '%target_folder%\' + $asset.name + '...');" ^
    "    $ProgressPreference = 'SilentlyContinue';" ^
    "    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile ('%target_folder%\' + $asset.name);" ^
    "    Write-Host '[OK] Download Complete.';" ^
    "    if ($type -eq 'Portable' -and ($asset.name -like '*.zip')) {" ^
    "      Write-Host ('[*] Unzipping portable archive to: ' + '%target_folder%');" ^
    "      try {" ^
    "        Expand-Archive -LiteralPath ('%target_folder%\' + $asset.name) -DestinationPath '%target_folder%' -Force;" ^
    "        Write-Host '[OK] Extraction Complete. Portable application is ready to use.';" ^
    "      } catch {" ^
    "        Write-Host ('[NOTICE] Extraction notice: ' + $_.Exception.Message);" ^
    "      }" ^
    "    }" ^
    "  } else {" ^
    "    Write-Host ('[-] No matching asset found for ' + $os + ' (' + $arch + ') in release.');" ^
    "  }" ^
    "} catch { Write-Host ('[ERROR] ' + $_.Exception.Message); }"

echo.
pause
goto APP_LIST

:: ==========================================
:: ROLLBACK MENU
:: ==========================================
:ROLLBACK_MENU
cls
echo ========================================================
echo                     ROLLBACK MANAGER                    
echo ========================================================
echo Select an app to check local archives for rollback:
echo.
for /l %%i in (1,1,%app_count%) do (
    for /f "tokens=1,2,3 delims=|" %%a in ("!app[%%i]!") do (
        echo  %%i. %%b
    )
)
echo  0. Back to Main Menu
echo --------------------------------------------------------
set "rb_choice="
set /p "rb_choice=Select app [0-%app_count%]: "
if not defined rb_choice goto MAIN_MENU

if "%rb_choice%"=="0" goto MAIN_MENU
if %rb_choice% LSS 1 goto ROLLBACK_MENU
if %rb_choice% GTR %app_count% goto ROLLBACK_MENU

for /f "tokens=1,2,3 delims=|" %%a in ("!app[%rb_choice%]!") do (
    set "app_key=%%a"
    set "app_name=%%b"
)

cls
echo ========================================================
echo  Available Archives for: %app_name%
echo ========================================================
echo [Portable Folder Files]:
if exist "%PORTABLE_DIR%\%app_key%" (
    dir /b "%PORTABLE_DIR%\%app_key%"
) else (
    echo (None found)
)
echo.
echo [Installer Folder Files]:
if exist "%INSTALLER_DIR%\%app_key%" (
    dir /b "%INSTALLER_DIR%\%app_key%"
) else (
    echo (None found)
)
echo --------------------------------------------------------
echo Folders located at:
echo - Portable:  %PORTABLE_DIR%\%app_key%
echo - Installers: %INSTALLER_DIR%\%app_key%
echo.
pause
goto MAIN_MENU