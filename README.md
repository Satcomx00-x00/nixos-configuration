# NixOS Configuration

Full NixOS system configuration with **Hyprland** (Wayland compositor), **NVIDIA** proprietary drivers, developer tools, and gaming support (Steam, Discord).

## Features

- **Hyprland** — tiling Wayland compositor with smooth animations
- **NVIDIA** — proprietary driver with Wayland environment variables
- **Waybar** — minimal status bar with workspaces, clock, system monitors
- **Wofi** — application launcher
- **Kitty** — GPU-accelerated terminal
- **PipeWire** — audio (replaces PulseAudio)
- **greetd + tuigreet** — lightweight TUI login manager
- **Home Manager** — declarative user-level configuration
- **Dev tools** — git, neovim, gcc, python, node, rust, go, docker, and more
- **Gaming** — Steam, Discord, Lutris, Heroic, MangoHud, Gamemode, Gamescope

## Repository Structure

```
.
├── flake.nix                          # Flake entry point
├── hosts/
│   └── default/
│       ├── configuration.nix          # Main system configuration
│       └── hardware-configuration.nix # Hardware (replace with yours)
├── home/
│   └── default/
│       ├── home.nix                   # Home Manager user config
│       ├── hyprland.conf              # Hyprland window manager config
│       └── waybar/
│           ├── config.jsonc           # Waybar modules and layout
│           └── style.css              # Waybar theme
└── modules/
    ├── nvidia.nix                     # NVIDIA driver module
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
| `Super + Space` | App launcher (Wofi) |
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + V` | Toggle floating |
| `Super + B` | Open Firefox |
| `Super + E` | File manager (Nautilus) |
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Super + Mouse drag` | Move / resize window |
| `Print` | Screenshot (region) |
| `Shift + Print` | Screenshot (full screen) |
| `Super + M` | Exit Hyprland |

## NVIDIA Notes

- The config uses the **proprietary** NVIDIA driver with Wayland workarounds
- If you experience cursor glitches, `WLR_NO_HARDWARE_CURSORS=1` is already set
- For newer GPUs (Ampere+), you can try `hardware.nvidia.open = true` in `modules/nvidia.nix`
- Check [Hyprland NVIDIA wiki](https://wiki.hyprland.org/Nvidia/) for the latest tips

## License

MIT
