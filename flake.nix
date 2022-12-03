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
    nixosConfigurations.beta = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs // { hostname = "beta"; };
      modules = [ ./systems/beta/configuration.nix ];
    };

    nixosConfigurations.chi = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs // { hostname = "chi"; };
      modules = [ ./systems/chi/configuration.nix ];
    };

    nixosConfigurations.delta = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs // { hostname = "delta"; };
      modules = [ ./systems/delta/configuration.nix ];
    };

    nixosConfigurations.epsilon = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs // { hostname = "epsilon"; };
      modules = [ ./systems/epsilon/configuration.nix ];
    };

    homeConfigurations."jherland@chi" = inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./chi.nix ];
    };

    homeConfigurations."jherland@epsilon" = inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./epsilon.nix ];
    };

    homeConfigurations."jherland@delta" = inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./delta.nix ];
    };

    devShell.x86_64-linux = pkgs.mkShell {
      buildInputs = with pkgs; [
        git
        python311
      ];
    };
  };
}
