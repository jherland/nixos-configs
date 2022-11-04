{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    nixos-hardware.url = github:NixOS/nixos-hardware;
  };

  outputs = { self, ... }@inputs: {
    nixosConfigurations.delta = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [
        ./configuration.nix
        ({pkgs, ...}: {
          system.configurationRevision = inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;
        })
      ];
    };
  };
}
