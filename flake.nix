{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    nixos-hardware.url = github:NixOS/nixos-hardware;
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
  let
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  in {
    nixosConfigurations = {
      beta = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs // { hostname = "beta"; };
        modules = [ ./beta/configuration.nix ];
      };

      chi = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs // { hostname = "chi"; };
        modules = [ ./chi/configuration.nix ];
      };

      delta = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs // { hostname = "delta"; };
        modules = [ ./delta/configuration.nix ];
      };

      epsilon = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs // { hostname = "epsilon"; };
        modules = [ ./epsilon/configuration.nix ];
      };
    };

    homeConfigurations = {
      "jherland@chi" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./chi/home.nix ];
      };

      "jherland@delta" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./delta/home.nix ];
      };

      "jherland@epsilon" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./epsilon/home.nix ];
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
