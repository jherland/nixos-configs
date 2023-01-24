{ nixos-hardware, ... }:
{
  imports = [
    # Hardware-specific
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
    ./hardware-configuration.nix

    # Common subsets
    ../common/base.nix
    ../common/hw_logitech.nix
    ../common/i18n_en_nl.nix
    ../common/laptop.nix
    ../common/user_jherland.nix
    ../common/gui_jherland.nix
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
  boot.initrd.luks.devices."luks-a05d550b-a0ed-482d-9a18-3fc608c355a4".device = "/dev/disk/by-uuid/a05d550b-a0ed-482d-9a18-3fc608c355a4";
  boot.initrd.luks.devices."luks-a05d550b-a0ed-482d-9a18-3fc608c355a4".keyFile = "/crypto_keyfile.bin";

  # Enable fingerprint reader
#  services.fprintd.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;  # override common/laptop.nix
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable hosting containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  users.users.jherland.extraGroups = [ "podman" ];
}
