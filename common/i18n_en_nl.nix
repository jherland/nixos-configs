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
    xkbOptions = "eurosign:e,caps:ctrl_modifier,terminate:ctrl_alt_bksp";
    xkbVariant = "altgr-intl";
  };

  # Time zone
  time.timeZone = "Europe/Amsterdam";
}
