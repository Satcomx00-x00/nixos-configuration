#!/usr/bin/env bash
# install.sh — Deploy this NixOS configuration to the target system.
#
# Usage:
#   sudo ./install.sh              # Install to a running NixOS system (/etc/nixos)
#   sudo ./install.sh /mnt         # Install to a mounted NixOS root (fresh install)
#
# After running the script:
#   Fresh install:  nixos-install --flake /mnt/etc/nixos#default
#   Running system: sudo nixos-rebuild switch --flake /etc/nixos#default

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Colour

info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ── Root check ───────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    err "This script must be run as root (use sudo)."
    exit 1
fi

# ── Resolve paths ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_ROOT="${1:-}"                 # e.g. /mnt for fresh installs, empty for running system
NIXOS_DIR="${TARGET_ROOT}/etc/nixos"

info "Source directory : ${SCRIPT_DIR}"
info "Target directory : ${NIXOS_DIR}"

# ── Verify source looks correct ──────────────────────────────────────
if [[ ! -f "${SCRIPT_DIR}/flake.nix" ]]; then
    err "Cannot find flake.nix in ${SCRIPT_DIR}. Run this script from the repository root."
    exit 1
fi

# ── If fresh install, check that the mount point exists ──────────────
if [[ -n "${TARGET_ROOT}" && ! -d "${TARGET_ROOT}" ]]; then
    err "Target root ${TARGET_ROOT} does not exist. Did you forget to mount your disks?"
    exit 1
fi

# ── Back up existing configuration ───────────────────────────────────
if [[ -d "${NIXOS_DIR}" ]]; then
    BACKUP="${NIXOS_DIR}.bak.$(date +%Y%m%d%H%M%S)"
    warn "Existing configuration found at ${NIXOS_DIR}"
    info "Backing up to ${BACKUP}"
    cp -a "${NIXOS_DIR}" "${BACKUP}"
    ok "Backup created."
fi

# ── Create target directory ──────────────────────────────────────────
mkdir -p "${NIXOS_DIR}"

# ── Files and directories to install ─────────────────────────────────
# Each entry is a path relative to the repo root.
FILES=(
    flake.nix
    hosts/default/configuration.nix
    hosts/default/hardware-configuration.nix
    home/default/home.nix
    home/default/hyprland.conf
    home/default/waybar/config.jsonc
    home/default/waybar/style.css
    modules/nvidia.nix
    modules/gaming.nix
    modules/dev.nix
)

for file in "${FILES[@]}"; do
    src="${SCRIPT_DIR}/${file}"
    dest="${NIXOS_DIR}/${file}"

    if [[ ! -f "${src}" ]]; then
        warn "Skipping missing file: ${file}"
        continue
    fi

    mkdir -p "$(dirname "${dest}")"
    cp -v "${src}" "${dest}"
done

ok "All configuration files installed to ${NIXOS_DIR}"

# ── Preserve hardware-configuration.nix if one was generated ─────────
GENERATED_HW="${TARGET_ROOT}/etc/nixos/hardware-configuration.nix"
if [[ -n "${TARGET_ROOT}" && -f "${GENERATED_HW}" ]]; then
    # nixos-generate-config may have placed hardware-configuration.nix at the
    # top level; copy it into our host directory so the flake can find it.
    HW_DEST="${NIXOS_DIR}/hosts/default/hardware-configuration.nix"
    if ! diff -q "${GENERATED_HW}" "${HW_DEST}" &>/dev/null; then
        info "Copying generated hardware-configuration.nix into hosts/default/"
        cp -v "${GENERATED_HW}" "${HW_DEST}"
    fi
fi

# ── Summary ──────────────────────────────────────────────────────────
echo ""
info "──────────────────────────────────────────────"
info " Installation complete!"
info "──────────────────────────────────────────────"
echo ""

if [[ -n "${TARGET_ROOT}" ]]; then
    info "Next steps (fresh install):"
    echo "  1. Review / edit ${NIXOS_DIR}/hosts/default/hardware-configuration.nix"
    echo "  2. Customise hostname, timezone, and user in configuration.nix"
    echo "  3. Run:  nixos-install --flake ${NIXOS_DIR}#default"
    echo "  4. Reboot into your new system."
else
    info "Next steps (running system):"
    echo "  1. Review any changes you want to make in ${NIXOS_DIR}/"
    echo "  2. Run:  sudo nixos-rebuild switch --flake ${NIXOS_DIR}#default"
fi

echo ""
ok "Done."
