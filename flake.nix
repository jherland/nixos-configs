{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    nixos-hardware.url = github:NixOS/nixos-hardware;
  };

  outputs = inputs:
  {
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

    devShell.x86_64-linux =
    let
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    in pkgs.mkShell {
      buildInputs = with pkgs; [
        git
        python311
      ];
    };
  };
}
