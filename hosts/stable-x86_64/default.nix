{ self, pkgs, ... }:
{
  imports = [
    ../../profiles/linux-stable/default.nix
  ];

  networking.hostName = "stable-x86_64";

  sourceos.build = {
    role = "stable-x86_64";
    channel = "stable";
  };

  sourceos.mesh.runtime = {
    enable = true;
    meshdPackage = self.packages.${pkgs.system}.meshd;
    linkdPackage = self.packages.${pkgs.system}.meshd-linkd;
  };
}
