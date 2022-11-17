{ nixpkgs, ...}:
let
  lib = nixpkgs.lib;
in {
  # Networking
  networking = {
    networkmanager.enable = lib.mkDefault true;

    # Allow Tailscale SSH (enable with `tailscale up --ssh`)
    firewall.interfaces.tailscale0.allowedTCPPorts = lib.mkDefault [ 22 ];
  };
  services.tailscale.enable = lib.mkDefault true;

  # Sound via pulseaudio
  sound.enable = lib.mkDefault true;
  hardware.pulseaudio.enable = lib.mkDefault true;

  # F/W update daemon
  services.fwupd.enable = lib.mkDefault true;
}
