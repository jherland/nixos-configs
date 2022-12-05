{ pkgs, ... }:
{
  imports = [
    # Hardware-specific
    # MISSING nixos-hardware module for ASUS MiniPC PN51-E1
    ./hardware-configuration.nix

    # Common subsets
    ../common/base.nix
    ../common/hw_logitech.nix
    ../common/i18n_en_nl.nix
    ../common/laptop.nix  # ???
    ../common/user_jherland.nix
    ../common/gui_jherland.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "auto";
  boot.loader.systemd-boot.memtest86.enable = true;

  # Use cgroups v2 unified hierarchy only
#  boot.kernelParams = [ "systemd.unified_cgroup_hierarchy=1" ];

  # Make console font a little larger and more legible
  console = {
    font = "ter-v20n";
    packages = with pkgs; [ terminus_font ];
  };

  # Enable hosting containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Enable hosting VMs
  virtualisation.libvirtd.enable = true;

  # Setup YubiKey support
#  services.udev.packages = [ pkgs.yubikey-personalization ];
#  services.pcscd.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    24800  # barrier
  ];
}
