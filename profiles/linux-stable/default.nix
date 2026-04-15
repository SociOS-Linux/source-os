{ ... }:
{
  imports = [
    ../../modules/build/default.nix
  ];

  sourceos.build = {
    role = "linux-stable";
    channel = "stable";
  };
}
