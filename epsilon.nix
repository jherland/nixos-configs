{ ... }:

{
  imports = [
    ./common.nix
    ./gui.nix
    ./gui_home.nix
    ./gui_work.nix
    ./vim.nix
  ];

  programs = {
    ssh.enable = true;
  };
}
