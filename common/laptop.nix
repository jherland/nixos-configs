{ nixpkgs, ...}:
let
  lib = nixpkgs.lib;
in {
  # Networking via NetworkManager
  networking.networkmanager.enable = lib.mkDefault true;

  # Sound via pulseaudio
  sound.enable = lib.mkDefault true;
  hardware.pulseaudio.enable = lib.mkDefault true;

  # F/W update daemon
  services.fwupd.enable = lib.mkDefault true;
}
