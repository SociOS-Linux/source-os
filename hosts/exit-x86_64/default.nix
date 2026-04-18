{ self, pkgs, ... }:
{
  imports = [
    ../../profiles/linux-stable/default.nix
  ];

  networking.hostName = "exit-x86_64";

  sourceos.build = {
    role = "exit-x86_64";
    channel = "stable";
  };

  sourceos.mesh = {
    role = "exit";
    runtime = {
      enable = true;
      meshdPackage = self.packages.${pkgs.system}.meshd;
      linkdPackage = self.packages.${pkgs.system}.meshd-linkd;
      exitdPackage = self.packages.${pkgs.system}.meshd-exitd;
    };
  };
}
