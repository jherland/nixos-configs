{ nixpkgs, ... }:
let
  lib = nixpkgs.lib;
  langCode = "nl_NL";
  langVars = [
    "LC_ADDRESS"
    "LC_IDENTIFICATION"
    "LC_MONETARY"
    "LC_PAPER"
    "LC_TELEPHONE"
  ];
in {
  # Languages/formatting
  i18n = {
    defaultLocale = "C.UTF-8";
    extraLocaleSettings = lib.genAttrs langVars (var: langCode + ".UTF-8");
  };

  # Keyboard layout
  console.useXkbConfig = true;
  services.xserver = {
    layout = "us";
    xkbOptions = "eurosign:e,caps:ctrl,terminate:ctrl_alt_bksp";
  };
}
