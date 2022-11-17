{ ...}:
{
  # Enable the KDE Plasma Desktop Environment.
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Cache SSH keys via gnupg agent
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
