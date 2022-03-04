{ pkgs, ...}:

let
  unstable = import (builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs/";
    ref = "nixos-unstable";
  }) {};
in
{
  home.packages = with pkgs; [
    # Media consumption
    spotify

    # Media production
    audacity
    gimp-with-plugins
    unstable.musescore
    obs-studio

    # Messaging
    unstable.signal-desktop
    unstable.discord
  ];

  programs.ssh.matchBlocks = {
    phi = {
      hostname = "phi.herland";
      user = "johan";
    };
    sigma = {
      hostname = "sigma.herland";
      user = "root";
    };
  };

  services.dropbox.enable = true;
}
