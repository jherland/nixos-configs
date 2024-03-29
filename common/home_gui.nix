{ pkgs, ...}:
{
  home.packages = with pkgs; [
    # IDEs
    kate  # kwrite
    vscode

    # Media consumption
    gwenview
    vlc

    # KVM software
    barrier

    # Misc.
    ark
    libreoffice-qt
    okular
    peek
    spectacle
    yubikey-manager-qt

    # Fonts
    font-awesome
    powerline-fonts
  ];

  # Allow fontconfig to discover fonts and configurations installed through
  # home.packages and nix-env
  fonts.fontconfig.enable = true;

  programs = {
    chromium = {
      enable = true;
      package = (pkgs.vivaldi.override {
        # Enable DRM media playback
        proprietaryCodecs = true;
        enableWidevine = true;
      });
    };
    firefox.enable = true;
  };

  services = {
  };
}
