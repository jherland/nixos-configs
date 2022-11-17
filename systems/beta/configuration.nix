{ config, pkgs, nixpkgs, nixos-hardware, ... }:

{
  imports = [
    # Hardware-specific
    nixos-hardware.nixosModules.samsung-np900x3c
    ./hardware-configuration.nix

    # Common subsets
    ../../common/base.nix
    ../../common/user_jherland.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Oslo";

  # Select internationalisation properties.
  i18n.defaultLocale = "nb_NO.UTF-8";

  # Disable touchpad
  # services.xserver.synaptics.enable = false;  # NECESSARY?!
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="event[0-9]*", \
    ENV{ID_INPUT_TOUCHPAD}=="1", \
    ENV{ID_INPUT_TOUCHPAD_INTEGRATION}=="internal", \
    ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.users.berit = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
  };

  environment.systemPackages = with pkgs; [
    bat
    firefox
    wget
  ];

  services.fwupd.enable = true;

  services.tailscale.enable = true;
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ]; # Allow Tailscale SSH

  # Setup kiosk mode running as my mother:
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
}

