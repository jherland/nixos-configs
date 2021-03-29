{ pkgs, ...}:

{
  home.packages = with pkgs; [
    # Media consumption
    spotify

    # Media production
    audacity
    gimp-with-plugins
    musescore
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
