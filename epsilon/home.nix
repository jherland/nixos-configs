{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;  # DOES NOT WORK!
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  imports = [
    ../common/home_base.nix
    ../common/home_gui.nix
    ../common/home_gui_personal.nix
    ../common/home_vim.nix
  ];

  programs.ssh.enable = true;
}
