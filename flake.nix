{
  description = "Основная конфигурация NixOS";

  inputs = {
    secret.url = "git+ssh://git@github.com/Damima3369/nixos-secret.git?ref=refs/heads/main";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-prismlauncher-9-4.url = "github:nixos/nixpkgs/e6f23dc08d3624daab7094b701aa3954923c6bbb";

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
    pineconemc.url = "github:Damima3369/PineconeMC";
  };

  outputs = {
    self, 
    nixpkgs, 
    nixpkgs-unstable, 
    home-manager, 
    secret, 
    plasma-manager, 
    nixos-generators, 
    nixpkgs-prismlauncher-9-4, 
    apple-emoji, 
    pineconemc,
    ... 
  }:

  let
    system = "x86_64-linux";

    overlay-prismlauncher = final: prev: {
      prismlauncher = let
        # Чисто собираем старую версию 9.4 без ломающего систему prev.config
        oldPrism = (import nixpkgs-prismlauncher-9-4 {
          inherit system;
          config = { allowUnfree = true; };
        }).prismlauncher;
      in prev.symlinkJoin {
        name = "prismlauncher-9.4-fixed";
        paths = [ oldPrism ];
        nativeBuildInputs = [ prev.makeWrapper ];
        # Нагло перехватываем запуск и прокидываем новые либы Mesa 26.05 и драйверы Intel
        postBuild = ''
          rm $out/bin/prismlauncher
          makeWrapper ${oldPrism}/bin/prismlauncher $out/bin/prismlauncher \
            --prefix LD_LIBRARY_PATH : "${prev.libGL}/lib:${prev.libglvnd}/lib:/run/opengl-driver/lib"
        '';
      };
    };

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
            nixpkgs.overlays = [ overlay-prismlauncher pineconemc.overlays.default ];
          }

          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.damima = ./desktops/users/damima/home.nix;
            home-manager.sharedModules = [ 
              plasma-manager.homeModules.plasma-manager 
            ];
          }
        ];
      };
    };
  };
}
