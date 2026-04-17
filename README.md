# NixOS Configuration

Full NixOS system configuration with **Hyprland** (Wayland compositor), **NVIDIA** proprietary drivers, developer tools, and gaming support (Steam, Discord).

## Features

- **Hyprland** — tiling Wayland compositor (upstream flake, latest version)
- **NVIDIA** — proprietary driver with full Wayland env vars and VA-API support
- **hyprlock** — GPU-accelerated screen locker with blurred screenshot background
- **hypridle** — idle management (dim → lock → DPMS off → suspend)
- **Waybar** — minimal status bar with workspaces, clock, system monitors
- **Rofi (Wayland)** — application launcher and clipboard picker
- **cliphist** — clipboard history manager (text + images)
- **wlogout** — session / logout menu
- **hyprpicker** — Wayland-native colour picker
- **Kitty** — GPU-accelerated terminal
- **PipeWire** — audio (replaces PulseAudio)
- **greetd + tuigreet** — lightweight TUI login manager
- **Home Manager** — declarative user-level configuration
- **Dev tools** — git, neovim, gcc, python, node, rust, go, docker, and more
- **Gaming** — Steam, Discord, Lutris, Heroic, MangoHud, Gamemode, Gamescope

## Repository Structure

```
.
├── flake.nix                          # Flake entry point (includes hyprland input)
├── hosts/
│   └── default/
│       ├── configuration.nix          # Main system configuration
│       └── hardware-configuration.nix # Hardware (replace with yours)
├── home/
│   └── default/
│       ├── home.nix                   # Home Manager user config
│       ├── hyprland.conf              # Hyprland window manager config
│       ├── hyprlock.conf              # hyprlock screen locker config
│       ├── hypridle.conf              # hypridle idle daemon config
│       └── waybar/
│           ├── config.jsonc           # Waybar modules and layout
│           └── style.css              # Waybar theme
└── modules/
    ├── nvidia.nix                     # NVIDIA driver module (VA-API, env vars)
    ├── hyprland.nix                   # Hyprland ecosystem tools and polkit agent
    ├── gaming.nix                     # Steam, Discord, gaming tools
    └── dev.nix                        # Developer tools and packages
```

## Installation

### 1. Boot the NixOS installer

Download the [NixOS minimal ISO](https://nixos.org/download) and boot from it.

### 2. Partition and mount your disks

```bash
# Example for a simple EFI setup (adjust to your hardware)
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary ext4 512MiB 100%

mkfs.fat -F 32 -n boot /dev/sda1
mkfs.ext4 -L nixos /dev/sda2

mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

### 3. Generate hardware config

```bash
nixos-generate-config --root /mnt
# Copy the generated file over the placeholder:
cp /mnt/etc/nixos/hardware-configuration.nix hosts/default/hardware-configuration.nix
```

### 4. Customise

- Edit `hosts/default/configuration.nix` — set your hostname, timezone, locale
- Edit `home/default/home.nix` — set your git name/email, username
- Edit `home/default/hyprland.conf` — adjust monitor, keybindings

### 5. Install using the installer script

The included `install.sh` copies all configuration files to their target paths.

```bash
# Clone this repo somewhere temporary
git clone <your-repo-url> /tmp/nixos-configuration
cd /tmp/nixos-configuration

# Fresh install (files are placed under /mnt/etc/nixos)
sudo ./install.sh /mnt

# Then run the NixOS installer
nixos-install --flake /mnt/etc/nixos#default
```

<details>
<summary>Manual install (without the script)</summary>

```bash
git clone <your-repo-url> /mnt/etc/nixos
cd /mnt/etc/nixos
nixos-install --flake .#default
```

</details>

### 6. Reboot and enjoy

```bash
reboot
```

## Post-Install

### Rebuild after changes

```bash
sudo nixos-rebuild switch --flake /etc/nixos#default
```

### Re-run the installer on a running system

```bash
cd /path/to/nixos-configuration
sudo ./install.sh          # installs to /etc/nixos and backs up the previous config
sudo nixos-rebuild switch --flake /etc/nixos#default
```

### Update all inputs

```bash
cd /etc/nixos
nix flake update
sudo nixos-rebuild switch --flake .#default
```

## Key Bindings (Hyprland)

| Key | Action |
|-----|--------|
| `Super + Return` | Open terminal (Kitty) |
| `Super + Space` | App launcher (Rofi) |
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + V` | Toggle floating |
| `Super + T` | Toggle split |
| `Super + Y` | Pseudo-tile |
| `Super + B` | Open Firefox |
| `Super + E` | File manager (Nautilus) |
| `Super + L` | Lock screen (hyprlock) |
| `Super + C` | Clipboard history picker |
| `Super + P` | Colour picker (hyprpicker) |
| `Super + S` | Toggle scratchpad workspace |
| `Super + Shift + S` | Move window to scratchpad |
| `Super + Shift + M` | Logout menu (wlogout) |
| `Super + 1-9,0` | Switch workspace |
| `Super + Shift + 1-9,0` | Move window to workspace |
| `Super + Alt + Arrows` | Resize window (keyboard) |
| `Super + Mouse drag` | Move / resize window |
| `Super + H/J/K/L` | Move focus (vim keys) |
| `Print` | Screenshot (region → clipboard) |
| `Shift + Print` | Screenshot (full screen → clipboard) |
| `Super + M` | Exit Hyprland |

## NVIDIA Notes

- The config uses the **proprietary** NVIDIA driver with all Wayland workarounds
- Hardware cursors are disabled via `cursor { no_hardware_cursors = true }` in `hyprland.conf`
- `WLR_NO_HARDWARE_CURSORS=1` is also set as a session variable for belt-and-braces safety
- `nvidia-vaapi-driver` is installed for hardware video decode/encode (VA-API)
- `NVD_BACKEND=direct` uses the stable direct VA-API backend
- For newer GPUs (Ampere+), you can try `hardware.nvidia.open = true` in `modules/nvidia.nix`
- `GBM_BACKEND=nvidia-drm` is set but can be removed if a specific app crashes
- See the [Hyprland NVIDIA wiki](https://wiki.hypr.land/Nvidia/) for the latest tips

## License

MIT
