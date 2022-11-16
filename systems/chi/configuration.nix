{ config, pkgs, nixpkgs, nixos-hardware, ... }:

{
  imports = [
    # Hardware-specific
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
    ./hardware-configuration.nix

    # Common subsets
    ../../common/base.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-a05d550b-a0ed-482d-9a18-3fc608c355a4".device = "/dev/disk/by-uuid/a05d550b-a0ed-482d-9a18-3fc608c355a4";
  boot.initrd.luks.devices."luks-a05d550b-a0ed-482d-9a18-3fc608c355a4".keyFile = "/crypto_keyfile.bin";

  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.utf8";
    extraLocaleSettings = {
      LC_ADDRESS = "nl_NL.utf8";
      LC_IDENTIFICATION = "nl_NL.utf8";
      LC_MEASUREMENT = "C.utf8";
      LC_MONETARY = "nl_NL.utf8";
      LC_NAME = "nl_NL.utf8";
      LC_NUMERIC = "nl_NL.utf8";
      LC_PAPER = "nl_NL.utf8";
      LC_TELEPHONE = "nl_NL.utf8";
      LC_TIME = "C.utf8";
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbOptions = "eurosign:e,caps:ctrl";
    xkbVariant = "altgr-intl";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
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

  # Enable udev rules + solaar for configuring Logitech wireless peripherals.
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jherland = {
    isNormalUser = true;
    description = "Johan Herland";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.fwupd.enable = true;
  services.tailscale.enable = true;
}
