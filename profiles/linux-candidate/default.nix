{ ... }:
{
  imports = [
    ../../modules/build/default.nix
  ];

  sourceos.build = {
    role = "linux-candidate";
    channel = "candidate";
  };
}
