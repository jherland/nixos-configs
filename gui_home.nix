{ pkgs, ...}:

let
  unstablePkgs = import <nixos-unstable> {};
in
{
  home.packages = with pkgs; [
    # Media consumption
    spotify

    # Media production
    audacity
    gimp-with-plugins
    unstablePkgs.musescore
    obs-studio
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
