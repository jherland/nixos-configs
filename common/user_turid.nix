{ ... }:
{
  users.users.turid = {
    isNormalUser = true;
    description = "Turid Herland";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
}
