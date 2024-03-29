{ nixos-hardware, pkgs, ... }:
{
  imports = [
    # Hardware-specific
    nixos-hardware.nixosModules.framework-12th-gen-intel
    ./hardware-configuration.nix

    # Common subsets
    ../common/base.nix
    ../common/hw_logitech.nix
    ../common/i18n_en_nl.nix
    ../common/laptop.nix
    ../common/tailscale.nix
    ../common/user_jherland.nix
    ../common/gui_jherland.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  # Make console font a little larger and more legible
  console = {
    font = "ter-v20n";
    packages = with pkgs; [ terminus_font ];
  };

  # Printing support
  services.printing = {
    enable = true;
    cups-pdf.enable = true;
  };

  # Disable fingerprint reader
  services.fprintd.enable = false;

  # Enable cross-building Raspberry Pi systems on this machine
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
