{ nixos-hardware, config, lib, pkgs, ... }:

{
  imports = [
    # Hardware-specific
    nixos-hardware.nixosModules.raspberry-pi-4
    ./hardware-configuration.nix

    # Common subsets
    ../common/base.nix
    ../common/i18n_en_nl.nix
    ../common/tailscale.nix
    ../common/user_jherland.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  hardware = {
    raspberry-pi."4" = {
      apply-overlays-dtmerge.enable = true;
      fkms-3d.enable = true;
    };
    deviceTree = {
      enable = true;
      # filter = "*rpi-4-*.dtb";
    };
  };
  console.enable = false;

  # Sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  # hardware.raspberry-pi."4".audio.enable = true;
  boot.kernelParams = [ "snd_bcm2835.enable_hdmi=1" ];

  # F/W update daemon
  services.fwupd.enable = lib.mkDefault true;

  # Kodi via cage/wayland
  users.extraUsers.kodi.isNormalUser = true;
  services.cage = {
    enable = true;
    user = "kodi";
    program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
  };
  systemd.services."cage-tty1" = {
    environment.WLR_LIBINPUT_NO_DEVICES = "1";
    requires = [ "network-online.target"];  # Wait until we're online
    serviceConfig.Restart = "always";  # Restart on close/crash
  };

  # Allow connecting to Kodi from tailnet
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 8080 ];
    allowedUDPPorts = [ 8080 ];
  };

  # Kodi accesses media from zeta via NFS.
  # Automount with disconnect after ~3h idle
  fileSystems = let commonOpts = {
    fsType = "nfs";
    options = [
      # Lazy mount, disconnect after ~3h idle
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=10000"
    ];
  };
  in
  {
    "/mnt/downloads" = commonOpts // { device = "zeta:/volume1/downloads"; };
    "/mnt/music" = commonOpts // { device = "zeta:/volume1/music"; };
    "/mnt/photo" = commonOpts // { device = "zeta:/volume1/photo"; };
    "/mnt/video" = commonOpts // { device = "zeta:/volume1/video"; };
  };

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  system.stateVersion = "24.05"; # Did you read the comment?
}

