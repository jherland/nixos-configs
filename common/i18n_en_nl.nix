{ ... }:
{
  # Languages/formatting
  i18n = {
    defaultLocale = "C.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "nl_NL.UTF-8";
      LC_IDENTIFICATION = "nl_NL.UTF-8";
      LC_MONETARY = "nl_NL.UTF-8";
      LC_PAPER = "nl_NL.UTF-8";
      LC_TELEPHONE = "nl_NL.UTF-8";
    };
  };

  # Keyboard layout
  console.useXkbConfig = true;
  services.xserver = {
    layout = "us";
    xkbOptions = "eurosign:e,caps:ctrl,terminate:ctrl_alt_bksp";
  };

  # Time zone
  time.timeZone = "Europe/Amsterdam";
}