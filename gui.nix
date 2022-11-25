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
#    libreoffice
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

  # Manual installed under /nix/store/*-html-manual/share/doc/home-manager/
  # Accessed with home-manager-help command
  # manual.html.enable = true;

  programs = {
    chromium = {
      enable = true;
      package = (pkgs.vivaldi.override {
        # Enable DRM media playback
        proprietaryCodecs = true;
        enableWidevine = true;
        # Make WebGL work when upgrading from v5.2 to v5.4
        commandLineArgs = "--use-gl=desktop";
      });
    };
    firefox.enable = true;
  };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };

    # network-manager-applet.enable = true;
  };

  # xsession = {
      # enable = true;
      # numlock.enable = true;
  # };
}
