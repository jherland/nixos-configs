{ self, hostname, nixpkgs, pkgs, ...}:
let
  lib = nixpkgs.lib;
in {
  # Shorten the boot wait by default
  boot.loader.timeout = lib.mkDefault 1;

  # Some useful system utils to be installed everywhere
  environment.systemPackages = with pkgs; [
    htop
    vim
  ];

  # Propagate our hostname into the generated system
  networking.hostName = hostname;

  nix = {
    # Run periodic garbage collection inside the generated system
    gc.automatic = true;
    gc.dates = "weekly";

    # Pin nixpkgs inside the generated system, to speed up installs
    # (see https://www.tweag.io/blog/2020-07-31-nixos-flakes/ for rationale)
    registry.nixpkgs.flake = nixpkgs;

    # Look to the future
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  system = {
    # Include the commit ID of this repo in `nixos-version --json`
    configurationRevision = lib.mkIf (self ? rev) self.rev;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    stateVersion = "22.05"; # Did you read the comment?
  };
}
