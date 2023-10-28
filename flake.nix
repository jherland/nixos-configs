{
  description = "jherland's NixOS Flake";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    nixos-hardware.url = github:NixOS/nixos-hardware;
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    nixosConfigurations = {
      beta = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs // { hostname = "beta"; };
        modules = [ ./beta/configuration.nix ];
      };

      chi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs // { hostname = "chi"; };
        modules = [
          ./chi/configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jherland = import ./chi/home.nix;
          }
        ];
      };

      delta = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs // { hostname = "delta"; };
        modules = [
          ./delta/configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jherland = {
              imports = [
                common/home_base.nix
                common/home_gui.nix
                common/home_gui_personal.nix
                common/home_vim.nix
              ];
            };
          }
        ];
      };

      epsilon = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs // { hostname = "epsilon"; };
        modules = [
          ./epsilon/configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jherland = import ./epsilon/home.nix;
          }
        ];
      };
    };

    devShells.x86_64-linux.default = pkgs.mkShell {
      name = "nixos-configs";
      buildInputs = with pkgs; [
        git
        python311
        python311Packages.venvShellHook
      ];
      venvDir = "./.venv";
      postShellHook = ''
        unset SOURCE_DATE_EPOCH
        pip install --upgrade pip
        pip install -r ./requirements.txt
      '';
    };
  };
}
