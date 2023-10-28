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

    # Messaging
    signal-desktop
    discord
  ];

  services.dropbox.enable = true;
}
