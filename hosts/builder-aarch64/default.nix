{ ... }:
{
  imports = [
    ../../profiles/linux-dev/default.nix
  ];

  networking.hostName = "builder-aarch64";

  sourceos.build = {
    role = "builder-aarch64";
    channel = "dev";
  };
}
