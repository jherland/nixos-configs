{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    nixos-hardware.url = github:NixOS/nixos-hardware;
  };


  outputs = { self, ... }@inputs:
  let
    common-system-config = (hostname: {
      boot.loader.timeout = 1;
      networking.hostName = hostname;

      nix = {
        registry.nixpkgs.flake = inputs.nixpkgs;
        settings.experimental-features = [ "nix-command" "flakes" ];
      };

      nixpkgs.config.allowUnfree = true;

      system = {
        configurationRevision = inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;

        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        stateVersion = "22.05"; # Did you read the comment?
      };
    });
  in {
    nixosConfigurations.beta = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs // {self = self; };
        modules = [
          (common-system-config "beta")
          ./systems/beta/configuration.nix
        ];
    };

    nixosConfigurations.chi = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs // {self = self; };
        modules = [
          (common-system-config "chi")
          ./systems/chi/configuration.nix
        ];
    };

    nixosConfigurations.delta = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs // {self = self; };
        modules = [
          (common-system-config "delta")
          ./systems/delta/configuration.nix
        ];
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
