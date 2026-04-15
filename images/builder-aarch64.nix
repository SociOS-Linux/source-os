{ ... }:
{
  imports = [
    ../hosts/builder-aarch64/default.nix
  ];

  sourceos.build.role = "builder-aarch64-image";
}
