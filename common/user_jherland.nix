{ ... }:
{
  users.users.jherland = {
    isNormalUser = true;
    description = "Johan Herland";
    extraGroups = [
      "dialout"
      "networkmanager"
      "wheel"
    ];
  };
}
