{ ... }:
{
  imports = [
    ../../modules/nixos/sourceos-shell/default.nix
  ];

  sourceos.shell = {
    enable = true;
    shellPort = 4173;
    routerPort = 7071;
    pdfSecurePort = 7072;
    docdPort = 7073;
  };
}
