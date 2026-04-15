{ ... }:
{
  imports = [
    ../../modules/build/default.nix
  ];

  sourceos.build = {
    role = "linux-dev";
    channel = "dev";
  };
}
