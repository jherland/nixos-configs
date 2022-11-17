{ pkgs, nixos-hardware, ... }:
{
  imports = [
    # Hardware-specific
    nixos-hardware.nixosModules.samsung-np900x3c
    ./hardware-configuration.nix

    # Common subsets
    ../../common/base.nix
    ../../common/laptop.nix
    ../../common/user_jherland.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Disable touchpad
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="event[0-9]*", \
    ENV{ID_INPUT_TOUCHPAD}=="1", \
    ENV{ID_INPUT_TOUCHPAD_INTEGRATION}=="internal", \
    ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

  # Make it "fully" norwegian
  i18n.defaultLocale = "nb_NO.UTF-8";
  time.timeZone = "Europe/Oslo";

  # Setup kiosk mode running as my mother:
  users.users.berit = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
  };
  services.cage = {
      enable = true;
      extraArguments = [ "-s" ];
      user = "berit";
      program = "${pkgs.firefox}/bin/firefox --new-window https://ssf.no/logg-inn";
  };
  systemd.services."cage-tty1" = {
    environment.XKB_DEFAULT_LAYOUT = "no";  # Norwegian keyboard layout
    after = [ "network-online.target"];  # Wait until we're online
    serviceConfig.Restart = "always";  # Restart on close/crash
  };

  # Extra system packages
  environment.systemPackages = with pkgs; [
    bat
    firefox
  ];
}
