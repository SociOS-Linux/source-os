{ ... }:
{
  imports = [
    ../../profiles/linux-stable/default.nix
  ];

  networking.hostName = "stable-x86_64";

  sourceos.build = {
    role = "stable-x86_64";
    channel = "stable";
  };
}
