#!/usr/bin/env bash
# ========================================================
# ArtCraft Apps Installer for Linux by Dyal Solutions
# ========================================================

set -e

REPO_OWNER="storytold"

# Define Apps (Key|Display Name|GitHub Repo Name)
APPS=(
    "adobepdf|Adobe PDF (pdfcraft)|pdfcraft"
    "photoshop|Photoshop (photocraft)|photocraft"
    "lightroom|Lightroom (lightcraft)|lightcraft"
    "aftereffect|After Effects (effectcraft)|effectcraft"
    "illustrator|Illustrator (vectorcraft)|vectorcraft"
    "premiere|Premiere Pro (filmcraft)|filmcraft"
    "indesign|InDesign (designcraft)|designcraft"
    "word|Microsoft Word (wordcraft)|wordcraft"
    "gridcraft|Microsoft Excel (gridcraft)|gridcraft"
    "cadcraft|AutoCAD (cadcraft)|cadcraft"
    "soundcraft|Avid Pro Tools (soundcraft)|soundcraft"
    "craft-fonts|Custom Fonts (craft-fonts)|craft-fonts"
    "artcraft|ArtCraft (artcraft)|artcraft"
)

APP_COUNT=${#APPS[@]}

# Setup Working Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="${SCRIPT_DIR}/ArtCraft"
PORTABLE_DIR="${BASE_DIR}/Portable"
INSTALLER_DIR="${BASE_DIR}/Installers"

mkdir -p "${PORTABLE_DIR}" "${INSTALLER_DIR}"

# Detect Architecture
RAW_ARCH="$(uname -m)"
case "${RAW_ARCH}" in
    x86_64|amd64)
        TARGET_ARCH="x86_64"
        ARCH_LABEL="64-bit (x86_64)"
        ;;
    aarch64|arm64)
        TARGET_ARCH="aarch64"
        ARCH_LABEL="ARM64 (aarch64)"
        ;;
    riscv64)
        TARGET_ARCH="riscv64"
        ARCH_LABEL="RISC-V (riscv64)"
        ;;
    *)
        TARGET_ARCH="${RAW_ARCH}"
        ARCH_LABEL="${RAW_ARCH}"
        ;;
esac

# Detect Linux Distribution and Preferred Package Format
PREF_PKG="AppImage"
DISTRO_NAME="Linux"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_NAME="${NAME:-Linux}"
    case "${ID} ${ID_LIKE:-}" in
        *debian*|*ubuntu*|*mint*|*pop*)
            PREF_PKG="deb"
            ;;
        *fedora*|*rhel*|*centos*|*suse*|*opensuse*)
            PREF_PKG="rpm"
            ;;
        *arch*|*manjaro*)
            PREF_PKG="pkg.tar.zst"
            ;;
        *)
            PREF_PKG="AppImage"
            ;;
    esac
fi

# Check download tool (curl or wget)
DOWNLOAD_TOOL=""
if command -v curl >/dev/null 2>&1; then
    DOWNLOAD_TOOL="curl"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOAD_TOOL="wget"
else
    echo "[ERROR] Neither curl nor wget is installed. Please install curl or wget."
    exit 1
fi

# Check JSON parser (python3 or jq)
JSON_TOOL=""
if command -v python3 >/dev/null 2>&1; then
    JSON_TOOL="python3"
elif command -v jq >/dev/null 2>&1; then
    JSON_TOOL="jq"
else
    echo "[ERROR] Either python3 or jq is required to parse GitHub releases."
    echo "Please install python3 or jq (e.g. sudo apt install python3 or sudo dnf install python3)."
    exit 1
fi

# Download Helper Function
fetch_url() {
    local url="$1"
    if [ "${DOWNLOAD_TOOL}" = "curl" ]; then
        curl -s -H "User-Agent: Linux-ArtCraft-Installer" "${url}"
    else
        wget -qO- --header="User-Agent: Linux-ArtCraft-Installer" "${url}"
    fi
}

download_file() {
    local url="$1"
    local dest="$2"
    echo "[*] Downloading to: ${dest}"
    if [ "${DOWNLOAD_TOOL}" = "curl" ]; then
        curl -L --progress-bar -H "User-Agent: Linux-ArtCraft-Installer" -o "${dest}" "${url}"
    else
        wget --show-progress -q -O "${dest}" "${url}"
    fi
}

# Python Filter Function to select OS-specific asset
filter_asset_py() {
    local json_data="$1"
    local arch="$2"
    local install_type="$3"
    local pref_pkg="$4"

    python3 -c '
import sys, json

try:
    data = json.loads(sys.argv[1])
    arch = sys.argv[2].lower()
    install_type = sys.argv[3]
    pref_pkg = sys.argv[4].lower()

    assets = data.get("assets", [])
    if not assets:
        sys.exit(0)

    # 1. Reject non-linux, checksums, zsync, web builds
    candidates = []
    for a in assets:
        name = a.get("name", "").lower()
        if any(bad in name for bad in ["sha256", "checksum", ".zsync", "-web-", "macos", "darwin", ".dmg", ".app.tar.gz", "windows", ".exe", ".msi", "freebsd", "-cli-"]):
            continue
        candidates.append(a)

    # 2. Filter by architecture
    arch_cand = []
    for a in candidates:
        name = a.get("name", "").lower()
        if arch in ["x86_64", "amd64"]:
            if ("x86_64" in name or "amd64" in name) and not any(other in name for other in ["aarch64", "arm64", "riscv64"]):
                arch_cand.append(a)
            elif not any(other in name for other in ["aarch64", "arm64", "riscv64", "x86_64"]):
                arch_cand.append(a)
        elif arch in ["aarch64", "arm64"]:
            if "aarch64" in name or "arm64" in name:
                arch_cand.append(a)
        elif arch == "riscv64":
            if "riscv64" in name:
                arch_cand.append(a)
        else:
            arch_cand.append(a)

    pool = arch_cand if arch_cand else candidates

    chosen = None
    if install_type == "Portable":
        # Prefer .AppImage
        for a in pool:
            if a["name"].lower().endswith(".appimage"):
                chosen = a
                break
        if not chosen:
            # Prefer .tar.gz
            for a in pool:
                if a["name"].lower().endswith(".tar.gz"):
                    chosen = a
                    break
        if not chosen and pool:
            chosen = pool[0]
    else:
        # Package / Installer: prefer user preferred format (deb, rpm, etc.)
        for a in pool:
            if a["name"].lower().endswith("." + pref_pkg):
                chosen = a
                break
        if not chosen:
            # Fallback preference order: .deb -> .rpm -> .flatpak -> .pkg.tar.zst -> .appimage -> any
            for ext in [".deb", ".rpm", ".flatpak", ".pkg.tar.zst", ".appimage"]:
                for a in pool:
                    if a["name"].lower().endswith(ext):
                        chosen = a
                        break
                if chosen:
                    break
        if not chosen and pool:
            chosen = pool[0]

    if chosen:
        size_mb = round(chosen.get("size", 0) / (1024 * 1024), 2)
        print(f"{chosen[\"name\"]}\t{chosen[\"browser_download_url\"]}\t{size_mb}")
except Exception as e:
    sys.exit(1)
' "$json_data" "$arch" "$install_type" "$pref_pkg"
}

# Python Release Lister Function
list_releases_py() {
    local json_data="$1"
    local arch="$2"

    python3 -c '
import sys, json

try:
    releases = json.loads(sys.argv[1])
    arch = sys.argv[2].lower()

    for idx, rel in enumerate(releases, 1):
        tag = rel.get("tag_name", "")
        name = rel.get("name", "") or tag
        print(f"[{idx}] {tag} - {name}")

        assets = rel.get("assets", [])
        linux_assets = []
        for a in assets:
            aname = a.get("name", "").lower()
            if any(bad in aname for bad in ["sha256", "checksum", ".zsync", "-web-", "macos", "darwin", ".dmg", ".app.tar.gz", "windows", ".exe", ".msi", "freebsd", "-cli-"]):
                continue
            # Check architecture
            if arch in ["x86_64", "amd64"]:
                if ("x86_64" in aname or "amd64" in aname) and not any(other in aname for other in ["aarch64", "arm64", "riscv64"]):
                    linux_assets.append(a)
                elif not any(other in aname for other in ["aarch64", "arm64", "riscv64"]):
                    linux_assets.append(a)
            elif arch in ["aarch64", "arm64"]:
                if "aarch64" in aname or "arm64" in aname:
                    linux_assets.append(a)
            elif arch == "riscv64":
                if "riscv64" in aname:
                    linux_assets.append(a)
            else:
                linux_assets.append(a)

        if linux_assets:
            for a in linux_assets:
                size_mb = round(a.get("size", 0) / (1024 * 1024), 2)
                print(f"    - {a[\"name\"]} ({size_mb} MB)")
        else:
            print("    (No matching Linux assets for this architecture)")
except Exception as e:
    sys.exit(1)
' "$json_data" "$arch"
}

# ==========================================
# MAIN MENU
# ==========================================
show_main_menu() {
    while true; do
        clear
        echo "========================================================"
        echo "         ArtCraft Apps Installer by Dyal Solutions      "
        echo "========================================================"
        echo "Target Platform: Linux [${ARCH_LABEL}]"
        echo "Distro Detected: ${DISTRO_NAME} (Preferred: .${PREF_PKG})"
        echo "Working Folder:  ${BASE_DIR}"
        echo "--------------------------------------------------------"
        echo " 1. Browse & Install / Update Apps"
        echo " 2. Rollback to a Previous Version"
        echo " 3. Change Target Architecture / Package Format"
        echo " 4. Exit"
        echo "--------------------------------------------------------"
        read -rp "Select an option [1-4]: " choice
        case "$choice" in
            1) show_app_list ;;
            2) show_rollback_menu ;;
            3) show_settings_menu ;;
            4) exit 0 ;;
            *) ;;
        esac
    done
}

# ==========================================
# SETTINGS MENU
# ==========================================
show_settings_menu() {
    clear
    echo "========================================================"
    echo "             TARGET CONFIGURATION (LINUX)               "
    echo "========================================================"
    echo "Current Architecture:   ${ARCH_LABEL}"
    echo "Current Package Format: .${PREF_PKG}"
    echo "--------------------------------------------------------"
    echo "Architecture:"
    echo "  1. x86_64 / amd64 [Standard 64-bit PC]"
    echo "  2. aarch64 / arm64 [ARM64 / Raspberry Pi 4/5]"
    echo "  3. riscv64 [RISC-V 64-bit]"
    echo ""
    echo "Preferred Package Format:"
    echo "  4. AppImage [Universal Portable]"
    echo "  5. .deb [Debian / Ubuntu / Linux Mint / Pop!_OS]"
    echo "  6. .rpm [Fedora / RHEL / CentOS / openSUSE]"
    echo "  7. .flatpak"
    echo "  8. .tar.gz [Tarball archive]"
    echo "  9. .pkg.tar.zst [Arch Linux / Manjaro]"
    echo "  0. Back to Main Menu"
    echo "--------------------------------------------------------"
    read -rp "Select an option [0-9]: " set_choice
    case "$set_choice" in
        1) TARGET_ARCH="x86_64"; ARCH_LABEL="64-bit (x86_64)" ;;
        2) TARGET_ARCH="aarch64"; ARCH_LABEL="ARM64 (aarch64)" ;;
        3) TARGET_ARCH="riscv64"; ARCH_LABEL="RISC-V (riscv64)" ;;
        4) PREF_PKG="AppImage" ;;
        5) PREF_PKG="deb" ;;
        6) PREF_PKG="rpm" ;;
        7) PREF_PKG="flatpak" ;;
        8) PREF_PKG="tar.gz" ;;
        9) PREF_PKG="pkg.tar.zst" ;;
        0) return ;;
        *) ;;
    esac
}

# ==========================================
# APP LIST
# ==========================================
show_app_list() {
    while true; do
        clear
        echo "========================================================"
        echo "                     AVAILABLE APPS                     "
        echo "========================================================"
        echo "Target Platform: Linux [${ARCH_LABEL}] (.${PREF_PKG})"
        echo "--------------------------------------------------------"
        for i in "${!APPS[@]}"; do
            IFS='|' read -r key name repo <<< "${APPS[$i]}"
            printf " %2d. %s\n" "$((i + 1))" "$name"
        done
        echo "  0. Back to Main Menu"
        echo "--------------------------------------------------------"
        read -rp "Select an app to manage [0-${APP_COUNT}]: " app_choice

        if [ "$app_choice" = "0" ]; then
            return
        fi

        if [[ "$app_choice" =~ ^[0-9]+$ ]] && [ "$app_choice" -ge 1 ] && [ "$app_choice" -le "$APP_COUNT" ]; then
            local selected_idx=$((app_choice - 1))
            IFS='|' read -r SELECTED_KEY SELECTED_NAME SELECTED_REPO <<< "${APPS[$selected_idx]}"
            show_app_submenu
        fi
    done
}

# ==========================================
# APP SUBMENU
# ==========================================
show_app_submenu() {
    while true; do
        clear
        echo "========================================================"
        echo " Managing: ${SELECTED_NAME}"
        echo "========================================================"
        echo " Target Platform: Linux [${ARCH_LABEL}] (.${PREF_PKG})"
        echo "--------------------------------------------------------"
        echo " 1. Portable Version (AppImage / tar.gz)"
        echo " 2. Package / Installer Version (.${PREF_PKG} / native)"
        echo " 3. Check Updates / Select Specific Version"
        echo " 0. Back"
        echo "--------------------------------------------------------"
        read -rp "Select deployment type [0-3]: " type_choice

        case "$type_choice" in
            0) return ;;
            1)
                download_latest "Portable" "${PORTABLE_DIR}/${SELECTED_KEY}"
                read -rp "Press Enter to continue..."
                ;;
            2)
                download_latest "Installer" "${INSTALLER_DIR}/${SELECTED_KEY}"
                read -rp "Press Enter to continue..."
                ;;
            3)
                show_version_history
                ;;
            *) ;;
        esac
    done
}

# Unpack / configure portable packages
unpack_portable() {
    local dest_file="$1"
    local target_folder="$2"
    local asset_name="$3"
    local install_type="$4"

    # If AppImage, make it executable
    if [[ "${asset_name}" == *.AppImage ]]; then
        chmod +x "${dest_file}"
        echo "[*] Marked ${asset_name} as executable (chmod +x)."
    fi

    # Unpack portables if zip or tar.gz
    if [ "${install_type}" = "Portable" ]; then
        if [[ "${asset_name}" == *.zip ]]; then
            echo "[*] Unzipping portable archive to: ${target_folder}..."
            if command -v unzip >/dev/null 2>&1; then
                unzip -q -o "${dest_file}" -d "${target_folder}"
            else
                python3 -c "import zipfile, sys; zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])" "${dest_file}" "${target_folder}"
            fi
            echo "[OK] Extraction Complete! Portable application is ready to use."
        elif [[ "${asset_name}" == *.tar.gz ]] || [[ "${asset_name}" == *.tgz ]]; then
            echo "[*] Extracting tarball archive to: ${target_folder}..."
            tar -xzf "${dest_file}" -C "${target_folder}"
            echo "[OK] Extraction Complete! Portable application is ready to use."
        fi
    fi
}

# ==========================================
# DOWNLOAD LATEST
# ==========================================
download_latest() {
    local install_type="$1"
    local target_folder="$2"

    mkdir -p "${target_folder}"

    echo ""
    echo "[*] Fetching latest release for ${SELECTED_NAME} (Linux ${TARGET_ARCH})..."
    local api_url="https://api.github.com/repos/${REPO_OWNER}/${SELECTED_REPO}/releases/latest"
    local json_res
    json_res="$(fetch_url "${api_url}")" || {
        echo "[ERROR] Failed to connect to GitHub API."
        return 1
    }

    if echo "${json_res}" | grep -q '"message": "Not Found"'; then
        echo "[-] No releases found for ${SELECTED_NAME}."
        return 1
    fi

    local match_info
    match_info="$(filter_asset_py "${json_res}" "${TARGET_ARCH}" "${install_type}" "${PREF_PKG}")"

    if [ -z "${match_info}" ]; then
        echo "[-] No matching Linux (${TARGET_ARCH}) asset found in latest release."
        return 1
    fi

    IFS=$'\t' read -r asset_name asset_url asset_size <<< "${match_info}"
    echo "[+] Matched Linux Asset: ${asset_name} (${asset_size} MB)"
    local dest_file="${target_folder}/${asset_name}"

    download_file "${asset_url}" "${dest_file}"
    echo "[OK] Download Complete: ${dest_file}"

    unpack_portable "${dest_file}" "${target_folder}" "${asset_name}" "${install_type}"
}

# ==========================================
# VERSION HISTORY & SELECTIVE DOWNLOAD
# ==========================================
show_version_history() {
    clear
    echo "========================================================"
    echo " Fetching Release History for ${SELECTED_NAME}..."
    echo "========================================================"
    echo "Target Platform: Linux [${ARCH_LABEL}]"
    echo ""

    local api_url="https://api.github.com/repos/${REPO_OWNER}/${SELECTED_REPO}/releases"
    local json_res
    json_res="$(fetch_url "${api_url}")" || {
        echo "[ERROR] Failed to connect to GitHub API."
        read -rp "Press Enter to continue..."
        return 1
    }

    if echo "${json_res}" | grep -q '"message": "Not Found"'; then
        echo "[-] No releases found for ${SELECTED_NAME}."
        read -rp "Press Enter to continue..."
        return 1
    fi

    list_releases_py "${json_res}" "${TARGET_ARCH}"

    echo ""
    echo "--------------------------------------------------------"
    read -rp "Enter the release number to download (or 0 to cancel): " ver_num

    if [ "$ver_num" = "0" ] || [ -z "$ver_num" ]; then
        return
    fi

    echo ""
    echo "Choose deployment type:"
    echo "1. Portable (${PORTABLE_DIR}/${SELECTED_KEY})"
    echo "2. Package / Installer (${INSTALLER_DIR}/${SELECTED_KEY})"
    read -rp "Select [1-2]: " folder_choice

    local install_type="Portable"
    local target_folder="${PORTABLE_DIR}/${SELECTED_KEY}"
    if [ "$folder_choice" = "2" ]; then
        install_type="Installer"
        target_folder="${INSTALLER_DIR}/${SELECTED_KEY}"
    fi

    mkdir -p "${target_folder}"

    # Extract selected release JSON
    local selected_rel_json
    selected_rel_json="$(python3 -c '
import sys, json
try:
    releases = json.loads(sys.argv[1])
    num = int(sys.argv[2]) - 1
    if 0 <= num < len(releases):
        print(json.dumps(releases[num]))
except:
    sys.exit(1)
' "${json_res}" "${ver_num}")"

    if [ -z "${selected_rel_json}" ]; then
        echo "[ERROR] Invalid release number selected."
        read -rp "Press Enter to continue..."
        return 1
    fi

    local match_info
    match_info="$(filter_asset_py "${selected_rel_json}" "${TARGET_ARCH}" "${install_type}" "${PREF_PKG}")"

    if [ -z "${match_info}" ]; then
        echo "[-] No matching Linux (${TARGET_ARCH}) asset found in the selected release."
        read -rp "Press Enter to continue..."
        return 1
    fi

    IFS=$'\t' read -r asset_name asset_url asset_size <<< "${match_info}"
    echo ""
    echo "[+] Matched Linux Asset: ${asset_name} (${asset_size} MB)"
    local dest_file="${target_folder}/${asset_name}"

    download_file "${asset_url}" "${dest_file}"
    echo "[OK] Download Complete: ${dest_file}"

    unpack_portable "${dest_file}" "${target_folder}" "${asset_name}" "${install_type}"

    echo ""
    read -rp "Press Enter to continue..."
}

# ==========================================
# ROLLBACK MENU
# ==========================================
show_rollback_menu() {
    clear
    echo "========================================================"
    echo "                     ROLLBACK MANAGER                   "
    echo "========================================================"
    echo "Select an app to check local archives for rollback:"
    echo ""
    for i in "${!APPS[@]}"; do
        IFS='|' read -r key name repo <<< "${APPS[$i]}"
        printf " %2d. %s\n" "$((i + 1))" "$name"
    done
    echo "  0. Back to Main Menu"
    echo "--------------------------------------------------------"
    read -rp "Select app [0-${APP_COUNT}]: " rb_choice

    if [ "$rb_choice" = "0" ] || [ -z "$rb_choice" ]; then
        return
    fi

    if [[ "$rb_choice" =~ ^[0-9]+$ ]] && [ "$rb_choice" -ge 1 ] && [ "$rb_choice" -le "$APP_COUNT" ]; then
        local selected_idx=$((rb_choice - 1))
        IFS='|' read -r rb_key rb_name rb_repo <<< "${APPS[$selected_idx]}"

        clear
        echo "========================================================"
        echo " Available Archives for: ${rb_name}"
        echo "========================================================"
        echo "[Portable Folder Files]:"
        if [ -d "${PORTABLE_DIR}/${rb_key}" ] && [ "$(ls -A "${PORTABLE_DIR}/${rb_key}" 2>/dev/null)" ]; then
            ls -1 "${PORTABLE_DIR}/${rb_key}"
        else
            echo "(None found)"
        fi
        echo ""
        echo "[Installer / Package Folder Files]:"
        if [ -d "${INSTALLER_DIR}/${rb_key}" ] && [ "$(ls -A "${INSTALLER_DIR}/${rb_key}" 2>/dev/null)" ]; then
            ls -1 "${INSTALLER_DIR}/${rb_key}"
        else
            echo "(None found)"
        fi
        echo "--------------------------------------------------------"
        echo "Folders located at:"
        echo "- Portable:   ${PORTABLE_DIR}/${rb_key}"
        echo "- Installers: ${INSTALLER_DIR}/${rb_key}"
        echo ""
        read -rp "Press Enter to continue..."
    fi
}

# Run Main Menu
show_main_menu
