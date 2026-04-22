{ ... }:
{
  imports = [
    ../../modules/build/default.nix
    ../../profiles/linux-dev/sourceos-shell.nix
  ];

  sourceos.build = {
    role = "linux-dev";
    channel = "dev";
  };
}
