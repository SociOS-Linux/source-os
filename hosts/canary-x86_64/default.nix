{ ... }:
{
  imports = [
    ../../profiles/linux-candidate/default.nix
  ];

  networking.hostName = "canary-x86_64";

  sourceos.build = {
    role = "canary-x86_64";
    channel = "candidate";
  };
}
