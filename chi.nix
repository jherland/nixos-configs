{ ... }:

{
  imports = [
    ./common.nix
    ./gui.nix
    ./gui_home.nix
    ./gui_work.nix
    ./vim.nix
  ];

#     barrier.client = {
#       enable = false;
#       server = "100.72.20.98";
#     };

#    ssh.enable = true;
}
