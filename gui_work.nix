{ pkgs, ...}:

{
  nixpkgs.overlays = [
    (import "${builtins.fetchTarball https://github.com/vlaci/openconnect-sso/archive/master.tar.gz}/overlay.nix")
  ];

  home = {
    file = {
      ".ssh/kill-ssh-control-masters.sh".source = ./kill-ssh-control-masters.sh;
#      ".config/openconnect-sso".source = ./openconnect-sso;
    };

    packages = with pkgs; [
      # VPN
#      openconnect-sso

      # Webex
#      (callPackage ./webex-linux-nix {})
    ];
  };

  programs.ssh = {
    controlMaster = "auto";
    controlPersist = "no";
    matchBlocks = {
      jherland-nix = {
        hostname = "jherland-nix.rd.cisco.com";
        forwardAgent = true;
        serverAliveInterval = 60;
      };
      rdbuild = {
        hostname = "rdbuild31.rd.cisco.com";
        forwardAgent = true;
        serverAliveInterval = 60;
      };
      lys-git = {
        hostname = "lys-git.cisco.com";
        forwardAgent = true;
        serverAliveInterval = 60;
      };
    };
  };
}
