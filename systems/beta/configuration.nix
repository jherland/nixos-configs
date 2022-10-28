# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nixos-hardware, ... }:

{
  imports =
    [
      nixos-hardware.nixosModules.samsung-np900x3c
      ./hardware-configuration.nix # Include the results of the hardware scan.
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.loader.timeout = 1;

  networking.hostName = "beta"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Oslo";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "nb_NO.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    # keyMap = "no";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver = {
  #   layout = "no";
  #   xkbOptions = "eurosign:e"; # "caps:escape" # map caps to escape.
  # };

  # Disable touchpad
  # services.xserver.synaptics.enable = false;  # NECESSARY?!
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="event[0-9]*", \
    ENV{ID_INPUT_TOUCHPAD}=="1", \
    ENV{ID_INPUT_TOUCHPAD_INTEGRATION}=="internal", \
    ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jherland = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # enable ‘sudo’ for the user.
      "networkmanager"
    ];
  };

  users.users.berit = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bat
    firefox
    htop
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  services.fwupd.enable = true;

  services.tailscale.enable = true;
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ]; # Allow Tailscale SSH

  # Setup kiosk mode running as my mother:
  services.cage = {
      enable = true;
      extraArguments = [ "-s" ];
      user = "berit";
      program = "${pkgs.firefox}/bin/firefox --private-window https://ssf.no";
  };
  systemd.services."cage-tty1" = {
    environment.XKB_DEFAULT_LAYOUT = "no";  # Norwegian keyboard layout
    after = [ "network-online.target"];  # Wait until we're online
    serviceConfig.Restart = "always";  # Restart on close/crash
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

