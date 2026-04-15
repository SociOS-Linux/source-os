{ ... }:
{
  imports = [
    ../hosts/stable-x86_64/default.nix
  ];

  sourceos.build.role = "stable-x86_64-image";
}
