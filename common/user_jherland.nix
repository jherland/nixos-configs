{ ... }:
{
  users.users.jherland = {
    isNormalUser = true;
    description = "Johan Herland";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    uid = 1000;
  };
}
