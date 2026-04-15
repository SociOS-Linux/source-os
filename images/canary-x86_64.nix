{ ... }:
{
  imports = [
    ../hosts/canary-x86_64/default.nix
  ];

  sourceos.build.role = "canary-x86_64-image";
}
