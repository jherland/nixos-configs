{ nixos-hardware, config, lib, pkgs, ... }:

{
  imports = [
    # Hardware-specific
    nixos-hardware.nixosModules.raspberry-pi-4
    ./hardware-configuration.nix

    # Common subsets
    ../common/base.nix
    ../common/i18n_en_nl.nix
    ../common/user_jherland.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # Tailscale w/SSH (enable with `tailscale up --ssh`)
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.mkDefault [ 22 ];
  services.tailscale.enable = lib.mkDefault true;

  # F/W update daemon
  services.fwupd.enable = lib.mkDefault true;

  system.stateVersion = "24.05"; # Did you read the comment?
}

