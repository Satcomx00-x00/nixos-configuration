{
  description = "NixOS configuration with Hyprland, NVIDIA, dev tools, and gaming";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Official Hyprland flake — provides the latest Hyprland, its portal, and
    # the NixOS / Home Manager modules recommended by the upstream wiki.
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # Hyprland NixOS module (provides programs.hyprland options backed by
        # the upstream flake package instead of the nixpkgs snapshot)
        hyprland.nixosModules.default

        ./hosts/default/configuration.nix
        ./hosts/default/hardware-configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.user = import ./home/default/home.nix;
          # Make flake inputs available inside Home Manager modules
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };
  };
}
