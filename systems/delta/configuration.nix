{ nixos-hardware, ... }:
{
  imports = [
    # Hardware-specific
    nixos-hardware.nixosModules.framework-12th-gen-intel
    ./hardware-configuration.nix

    # Common subsets
    ../../common/base.nix
    ../../common/hw_logitech.nix
    ../../common/i18n_en_nl.nix
    ../../common/laptop.nix
    ../../common/user_jherland.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "auto";
  boot.loader.systemd-boot.memtest86.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
