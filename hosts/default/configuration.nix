# Main system configuration
{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/nvidia.nix
    ../../modules/gaming.nix
    ../../modules/dev.nix
  ];

  # ---------- Boot ----------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ---------- Networking ----------
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # ---------- Locale & Time ----------
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # ---------- Hyprland ----------
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # XDG portal for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # ---------- Audio (PipeWire) ----------
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ---------- Display / Login ----------
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # ---------- Security ----------
  security.polkit.enable = true;
  security.rtkit.enable = true;

  # ---------- System Packages ----------
  environment.systemPackages = with pkgs; [
    # Wayland essentials
    kitty
    waybar
    wofi
    dunst
    libnotify
    swww
    wl-clipboard
    grim
    slurp
    wlsunset

    # File manager
    nautilus

    # Browser
    firefox

    # System utilities
    networkmanagerapplet
    pavucontrol
    brightnessctl
    playerctl
    polkit_gnome
  ];

  # ---------- Fonts ----------
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # ---------- User ----------
  users.users.user = {
    isNormalUser = true;
    description = "User";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  # ---------- Misc ----------
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}
