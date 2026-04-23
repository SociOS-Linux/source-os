{ config, lib, pkgs, ... }:
let
  cfg = config.sourceos.shell;
in
{
  options.sourceos.shell = {
    enable = lib.mkEnableOption "SourceOS shell Linux realization";

    packageRoot = lib.mkOption {
      type = lib.types.str;
      default = "/opt/sourceos-shell";
      description = "Filesystem root where the sourceos-shell runtime is expected to be installed.";
    };

    shellPort = lib.mkOption {
      type = lib.types.port;
      default = 4173;
      description = "Default local port for the sourceos-shell web runtime.";
    };

    routerPort = lib.mkOption {
      type = lib.types.port;
      default = 7071;
      description = "Local port for the sourceos-shell router bridge service.";
    };

    pdfSecurePort = lib.mkOption {
      type = lib.types.port;
      default = 7072;
      description = "Local port for the sourceos-shell pdf-secure service.";
    };

    docdPort = lib.mkOption {
      type = lib.types.port;
      default = 7073;
      description = "Local port for the sourceos-shell derive/docd service.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."sourceos-shell/README".text = ''
      SourceOS shell Linux realization scaffold.
      packageRoot=${cfg.packageRoot}
      shellPort=${toString cfg.shellPort}
      routerPort=${toString cfg.routerPort}
      pdfSecurePort=${toString cfg.pdfSecurePort}
      docdPort=${toString cfg.docdPort}
    '';

    systemd.services.sourceos-shell = {
      description = "SourceOS shell runtime scaffold";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.coreutils}/bin/echo sourceos-shell runtime placeholder root=${cfg.packageRoot} port=${toString cfg.shellPort}";
      };
    };

    systemd.services.sourceos-router = {
      description = "SourceOS shell router scaffold";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.coreutils}/bin/echo sourceos-router placeholder port=${toString cfg.routerPort}";
      };
    };

    systemd.services.sourceos-pdf-secure = {
      description = "SourceOS shell pdf-secure scaffold";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.coreutils}/bin/echo sourceos-pdf-secure placeholder port=${toString cfg.pdfSecurePort}";
      };
    };

    systemd.services.sourceos-docd = {
      description = "SourceOS shell docd scaffold";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.coreutils}/bin/echo sourceos-docd placeholder port=${toString cfg.docdPort}";
      };
    };
  };
}
