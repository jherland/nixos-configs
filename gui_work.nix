{ pkgs, ...}:

let
  webexPkgs = import (pkgs.fetchFromGitHub {
    owner = "myme";
    repo = "nixpkgs";
    rev = "29d6b2257a6eeb43dc6b8b7c1576288825250a11";
    sha256 = "0wd57ryhsc90kvv0qbrd5l96v1ac4s18yzpc6bn3vppx76xfxj5z";
  }) {};
in {
  nixpkgs.overlays = [
    (import "${builtins.fetchTarball https://github.com/vlaci/openconnect-sso/archive/master.tar.gz}/overlay.nix")
  ];

  home = {
    file = {
      ".ssh/kill-ssh-control-masters.sh".source = ./kill-ssh-control-masters.sh;
      ".config/openconnect-sso".source = ./openconnect-sso;
    };

    packages = with pkgs; [
      # VPN
      openconnect-sso

      # Webex
      webexPkgs.webex
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
