# Developer tools and packages
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Version control
    git
    gh

    # Editors
    vim
    neovim

    # Languages and runtimes
    gcc
    gnumake
    cmake
    python3
    nodejs
    rustup
    go

    # Build tools
    pkg-config
    openssl

    # Containers and virtualisation
    docker-compose

    # Terminal utilities
    tmux
    htop
    btop
    ripgrep
    fd
    jq
    unzip
    zip
    wget
    curl
    tree
    bat
    eza
    fzf
    zoxide
    starship
    lazygit
    direnv
  ];

  # Docker
  virtualisation.docker.enable = true;

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
}
