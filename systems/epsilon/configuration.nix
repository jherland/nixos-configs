{ pkgs, ... }:
{
  imports = [
    # Hardware-specific
    # MISSING nixos-hardware module for ASUS MiniPC PN51-E1
    ./hardware-configuration.nix

    # Common subsets
    ../../common/base.nix
    ../../common/hw_logitech.nix
    ../../common/i18n_en_nl.nix
    ../../common/laptop.nix  # ???
    ../../common/user_jherland.nix
    ../../common/gui_jherland.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "auto";
  boot.loader.systemd-boot.memtest86.enable = true;

  # Try to avoid amdgpu crashes by upgrading kernel
#  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use cgroups v2 unified hierarchy only
#  boot.kernelParams = [ "systemd.unified_cgroup_hierarchy=1" ];

  # Add filesystems possibly needed after boot
#  boot.supportedFilesystems = [ "nfs" "exfat" ];

  # Make console font a little larger and more legible
  console = {
    font = "ter-v20n";
    packages = with pkgs; [ terminus_font ];
  };

  # Disable NetworkManager from common/laptop.nix
#  networking.networkmanager.enable = false;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
#  networking.useDHCP = false;
#  networking.interfaces.enp2s0.useDHCP = true;
#  networking.interfaces.wlp3s0.useDHCP = true;

  # Enable CUPS to print documents.
#  services.printing.enable = true;

#   users.users.jherland = {
#     extraGroups = [
# #      "audio"
# #      "docker"
# #      "jackaudio"
# #      "networkmanager"
#       "plugdev"
#       "wheel"
#     ];
#     uid = 1000;
#     openssh.authorizedKeys.keys = [
#       "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLJTVKcMaGbbkG1t2+GjMN1YeZL7DdQXLPxO5MlHVGXhHbXQfrxAPTM9ArxtiRNEeYvuFAxxzSlcA1kl37/S4y0= jherland@alpha"
#       "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBG6ntd6Sqhdjnf0gCV0Urwvxw5O9WOq63plMRyNnHrr9/YW0aPpbgXbl+/jNYZoFjb0fg7/bGhDnVi+R7/et3OY= jherland@beta"
#       "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPUtBTKag3FMgq68JEDtVNTBBxQJzhSJHgm9zA4OhUy5wcRBmKpj10iprq5msbN5dwLtJYRF0D4KRMZthpDcXTw= u0_a381@localhost"
#       "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBRhfBOYn7bny7f4gChbS71MOwASBnggRbUMeL6izzgMkL5Zd3IsouuRvL6HyRczpV+V6LHzIw6Y+hbYsERh7eI= u0_a37@localhost"
#     ];
#   };

  # Enable hosting containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Enable hosting VMs
  virtualisation.libvirtd.enable = true;

  # Enable the OpenSSH daemon.
# services.openssh = {
#   enable = true;
#   passwordAuthentication = false;
# };

  # Setup YubiKey support
#  services.udev.packages = [ pkgs.yubikey-personalization ];
#  services.pcscd.enable = true;

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
#  system.stateVersion = "21.05"; # Did you read the comment?

# system.autoUpgrade = {
#   enable = true;
#   allowReboot = false;
#   channel = "https://nixos.org/channels/nixos-21.05";
# };

# nix.gc.automatic = true;
# nix.gc.dates = "03:15";
}
