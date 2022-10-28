{
  inputs.nixos-hardware.url = github:NixOS/nixos-hardware;

  outputs = { self, nixpkgs, ...}@attrs: {
    nixosConfigurations.beta = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ ./configuration.nix ];
    };
  };
}
