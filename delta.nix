{ ... }:
{
  nixpkgs.config.allowUnfree = true;  # DOES NOT WORK!
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  imports = [
    ./common.nix
    ./gui.nix
    ./gui_home.nix
    ./vim.nix
  ];

#     barrier.client = {
#       enable = false;
#       server = "100.72.20.98";
#     };

#    ssh.enable = true;
}
