{
  description = "Основная конфигурация NixOS";

  inputs = {
    secret.url = "git+ssh://git@github.com/Damima3369/nixos-secret.git?ref=refs/heads/main";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apple-emoji.url = "github:oxcl/nix-flake-apple-emoji";
    pineconemc = {
      url = "github:Damima3369/PineconeMC";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      secret,
      plasma-manager,
      apple-emoji,
      pineconemc,
      nix-index-database,
      ...
    }:

    let
      system = "x86_64-linux";
      system-aarch64 = "aarch64-linux";

    in
    {
      nixosConfigurations = {
        acemagic-s1 = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit secret apple-emoji;
            pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
          };
          modules = [
            ./hosts/acemagic-s1/configuration.nix

            {
              nixpkgs.overlays = [ pineconemc.overlays.default ];
            }

            nix-index-database.nixosModules.nix-index
            {
              programs.nix-index-database.comma.enable = true;
            }

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.damima = ./desktops/users/damima/home.nix;
              home-manager.sharedModules = [
                plasma-manager.homeModules.plasma-manager
              ];
            }
          ];
        };
        orangepi4 = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit secret apple-emoji;
            pkgs-unstable = nixpkgs-unstable.legacyPackages.${system-aarch64};
          };
          modules = [
            ./hosts/orangepi4/configuration.nix
            nix-index-database.nixosModules.nix-index
            {
              programs.nix-index-database.comma.enable = true;
            }
          ];
        };
      };
    };
}
