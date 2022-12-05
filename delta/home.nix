{ ... }:
{
  nixpkgs.config.allowUnfree = true;  # DOES NOT WORK!
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  imports = [
    ../common/home_base.nix
    ../common/home_gui.nix
    ../common/home_gui_personal.nix
    ../common/home_vim.nix
  ];

#     barrier.client = {
#       enable = false;
#       server = "100.72.20.98";
#     };

#    ssh.enable = true;
}
