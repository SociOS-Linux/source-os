{ self, pkgs, ... }:
{
  imports = [
    ../../profiles/linux-candidate/default.nix
  ];

  networking.hostName = "canary-x86_64";

  sourceos.build = {
    role = "canary-x86_64";
    channel = "candidate";
  };

  sourceos.mesh.runtime = {
    enable = true;
    meshdPackage = self.packages.${pkgs.system}.meshd;
    linkdPackage = self.packages.${pkgs.system}.meshd-linkd;
  };
}
