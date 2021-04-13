{ pkgs, ...}:

{
  home.packages = with pkgs; [
    # Browsers
    (vivaldi.override {
      proprietaryCodecs = true;
      enableWidevine = true;
    })
    vivaldi-ffmpeg-codecs
    vivaldi-widevine

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
    libreoffice
    okular
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
