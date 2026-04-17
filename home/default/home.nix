# Home Manager configuration
{ config, pkgs, ... }:

{
  home.username = "user";
  home.homeDirectory = "/home/user";

  # ---------- Hyprland user config ----------
  xdg.configFile."hypr/hyprland.conf".source = ./hyprland.conf;
  xdg.configFile."waybar/config.jsonc".source = ./waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source = ./waybar/style.css;

  # ---------- Shell ----------
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "eza -la --icons";
      ls = "eza --icons";
      cat = "bat";
      cd = "z";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#default";
      update = "nix flake update /etc/nixos";
    };
    initExtra = ''
      eval "$(starship init zsh)"
      eval "$(zoxide init zsh)"
      eval "$(direnv hook zsh)"
    '';
  };

  # ---------- Git ----------
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "you@example.com";
  };

  # ---------- Terminal ----------
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 12;
      background_opacity = "0.92";
      confirm_os_window_close = 0;
    };
  };

  # ---------- Starship prompt ----------
  programs.starship = {
    enable = true;
  };

  # ---------- User packages ----------
  home.packages = with pkgs; [
    spotify
    obsidian
    vlc
    gimp
    libreoffice
  ];

  home.stateVersion = "24.11";
}
