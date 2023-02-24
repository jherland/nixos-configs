{ nixos-hardware, pkgs, ... }:
{
  imports = [
    # Hardware-specific
    # nixos-hardware.nixosModules.framework-12th-gen-intel
    ./hardware-configuration.nix

    # Common subsets
    ../common/base.nix
    ../common/hw_logitech.nix
    ../common/i18n_en_nl.nix
    ../common/laptop.nix
    ../common/user_turid.nix
    ../common/gui_turid.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "auto";
  boot.loader.systemd-boot.memtest86.enable = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-fbf03eef-d00f-4e25-9870-5f2b6b498722".device = "/dev/disk/by-uuid/fbf03eef-d00f-4e25-9870-5f2b6b498722";
  boot.initrd.luks.devices."luks-fbf03eef-d00f-4e25-9870-5f2b6b498722".keyFile = "/crypto_keyfile.bin";
}
