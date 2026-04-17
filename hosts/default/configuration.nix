# Main system configuration
{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/nvidia.nix
    ../../modules/gaming.nix
    ../../modules/dev.nix
    ../../modules/hyprland.nix
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
    # Use the upstream flake package instead of the nixpkgs snapshot so we
    # get the version that matches the wiki docs (recommended by upstream).
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # XDG portal — the hyprland portal is wired up via portalPackage above;
  # xdg-desktop-portal-gtk is added for GTK file pickers and colour choosers.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
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
