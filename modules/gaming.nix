# Gaming packages and configuration
{ config, pkgs, ... }:

{
  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # Allow unfree packages (required for Steam, Discord, NVIDIA, etc.)
  nixpkgs.config.allowUnfree = true;

  # Gamemode for performance optimisation
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    # Chat / social
    discord

    # Game launchers and tools
    lutris
    heroic
    mangohud
    gamescope
    protonup-qt

    # Controller support
    gamepad-tool
  ];
}
