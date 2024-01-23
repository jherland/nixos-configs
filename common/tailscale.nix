{ nixpkgs, ...}:
let
  lib = nixpkgs.lib;
in {
  # Networking
  services.tailscale.enable = lib.mkDefault true;
  # Allow Tailscale SSH (enable with `tailscale up --ssh`)
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.mkDefault [ 22 ];
}
