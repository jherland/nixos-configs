# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
#  unstable = import (builtins.fetchGit {
#    url = "https://github.com/NixOS/nixpkgs/";
#    ref = "nixos-unstable";
#  }) {};
   unstable = import <nixos-unstable> {};
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Accelerated VMs
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

  # Try to avoid amdgpu crashes by upgrading kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use cgroups v2 unified hierarchy only
  boot.kernelParams = [ "systemd.unified_cgroup_hierarchy=1" ];

  # Add filesystems possibly needed after boot
  boot.supportedFilesystems = [ "nfs" "exfat" ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "epsilon"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Oslo";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "C.UTF-8";
    supportedLocales = [ "C.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" "nb_NO.UTF-8/UTF-8" ];
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  # hardware.pulseaudio.package = pkgs.pulseaudio.override { jackaudioSupport = true; };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  users.users.jherland = {
    isNormalUser = true;
    description = "Johan Herland";
    extraGroups = [
#      "audio"
#      "docker"
#      "jackaudio"
#      "networkmanager"
      "plugdev"
      "wheel"
    ];
    uid = 1000;
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLJTVKcMaGbbkG1t2+GjMN1YeZL7DdQXLPxO5MlHVGXhHbXQfrxAPTM9ArxtiRNEeYvuFAxxzSlcA1kl37/S4y0= jherland@alpha"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBG6ntd6Sqhdjnf0gCV0Urwvxw5O9WOq63plMRyNnHrr9/YW0aPpbgXbl+/jNYZoFjb0fg7/bGhDnVi+R7/et3OY= jherland@beta"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPUtBTKag3FMgq68JEDtVNTBBxQJzhSJHgm9zA4OhUy5wcRBmKpj10iprq5msbN5dwLtJYRF0D4KRMZthpDcXTw= u0_a381@localhost"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBRhfBOYn7bny7f4gChbS71MOwASBnggRbUMeL6izzgMkL5Zd3IsouuRvL6HyRczpV+V6LHzIw6Y+hbYsERh7eI= u0_a37@localhost"
    ];
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  #   firefox
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Enable VMs
  virtualisation.libvirtd.enable = true;

  # List services that you want to enable:

  # F/W update daemon
  services.fwupd.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  services.tailscale = {
    enable = true;
    package = unstable.tailscale;
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us(intl-unicode),no(nodeadkeys)";
    xkbOptions = "eurosign:e,caps:ctrl_modifier";

    # Enable the Plasma 5 Desktop Environment.
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };

  # Setup YubiKey support
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    24800  # barrier
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    channel = "https://nixos.org/channels/nixos-21.05";
  };

  nix.gc.automatic = true;
  nix.gc.dates = "03:15";
}

