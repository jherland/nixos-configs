{ nixos-hardware, config, lib, pkgs, ... }:

{
  imports = [
    # Hardware-specific
    ./hardware-configuration.nix

    # Common subsets
    ../common/base.nix
    ../common/i18n_en_nl.nix
    ../common/tailscale.nix
    ../common/user_jherland.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # F/W update daemon
  services.fwupd.enable = lib.mkDefault true;

  services.blocky = {
    enable = true;
    settings = {
      upstreams.groups.default = [
        "https://one.one.one.one/dns-query" # Using Cloudflare's DNS over HTTPS server for resolving queries.
      ];
      # For initially solving DoH/DoT Requests when no system Resolver is available.
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [ "1.1.1.1" "1.0.0.1" ];
      };
      # Enable Blocking of certain domains.
      blocking = {
        blackLists.ads = [
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
        ];
        # Configure what block categories are used
        clientGroupsBlock.default = [ "ads" ];
      };
      caching = {
        minTime = "5m";
        maxTime = "30m";
        prefetching = true;
      };
    };
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}

