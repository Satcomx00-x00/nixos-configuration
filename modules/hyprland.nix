# Hyprland ecosystem: screen locker, idle daemon, Wayland tools, polkit agent
{ config, pkgs, inputs, ... }:

{
  # ---------- Screen Locker ----------
  # Enables hyprlock and adds the required PAM entry so it can authenticate.
  programs.hyprlock.enable = true;

  # ---------- Hyprland Ecosystem Packages ----------
  environment.systemPackages = with pkgs; [
    # Idle management daemon (starts automatically as a user service)
    hypridle

    # Color picker (Wayland-native)
    hyprpicker

    # Clipboard manager — fed by wl-paste, queried via rofi
    cliphist

    # Wayland-native Rofi — richer app launcher / dmenu replacement
    rofi-wayland

    # Session / logout menu
    wlogout
  ];

  # ---------- Polkit Authentication Agent ----------
  # Run polkit-gnome as a systemd user service so the correct Nix store path
  # is used (the /usr/lib FHS path does not exist on NixOS).
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants    = [ "graphical-session.target" ];
    after    = [ "graphical-session.target" ];
    serviceConfig = {
      Type            = "simple";
      ExecStart       = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart         = "on-failure";
      RestartSec      = 1;
      TimeoutStopSec  = 10;
    };
  };
}
