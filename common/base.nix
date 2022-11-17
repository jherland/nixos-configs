{ self, hostname, nixpkgs, pkgs, ...}:
{
  boot.loader.timeout = 1;

  environment.systemPackages = with pkgs; [
    htop
    vim
  ];

  networking.hostName = hostname;

  nix = {
    registry.nixpkgs.flake = nixpkgs;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.config.allowUnfree = true;

  system = {
    configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    stateVersion = "22.05"; # Did you read the comment?
  };
}
