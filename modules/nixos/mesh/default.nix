{ config, lib, ... }:
let
  cfg = config.sourceos.mesh;

  unique = values:
    lib.length values == lib.length (lib.unique values);

  netdevTemplate =
    lib.replaceStrings
      [
        "Name=mesh0"
        "PrivateKey=@mesh0"
        "FirewallMark=0x110"
        "RouteTable=110"
      ]
      [
        "Name=${cfg.interfaceName}"
        "PrivateKey=@${cfg.interfaceName}"
        "FirewallMark=${cfg.fwmarks.private}"
        "RouteTable=${toString cfg.routeTables.private}"
      ]
      (builtins.readFile ../../../linux/systemd-networkd/50-mesh0.netdev);

  networkTemplate =
    lib.replaceStrings
      [
        "Name=mesh0"
        "Table=110"
        "FirewallMark=0x110"
        "Table=120"
        "FirewallMark=0x120"
      ]
      [
        "Name=${cfg.interfaceName}"
        "Table=${toString cfg.routeTables.private}"
        "FirewallMark=${cfg.fwmarks.private}"
        "Table=${toString cfg.routeTables.exit}"
        "FirewallMark=${cfg.fwmarks.exit}"
      ]
      (builtins.readFile ../../../linux/systemd-networkd/50-mesh0.network);

  nmTemplate =
    lib.replaceStrings
      [
        "id=wg-mesh"
        "interface-name=wg-mesh"
        "route-table=120"
        "routing-rule1=priority 10020 fwmark 0x120 table 120"
      ]
      [
        "id=${cfg.interfaceName}"
        "interface-name=${cfg.interfaceName}"
        "route-table=${toString cfg.routeTables.exit}"
        "routing-rule1=priority 10020 fwmark ${cfg.fwmarks.exit} table ${toString cfg.routeTables.exit}"
      ]
      (builtins.readFile ../../../linux/networkmanager/wg-mesh.nmconnection);

  manifestJson = builtins.toJSON {
    version = "sourceos-mesh-realization/v0";
    role = cfg.role;
    manager = cfg.manager;
    interface = cfg.interfaceName;
    routeTables = cfg.routeTables;
    fwmarks = cfg.fwmarks;
    activateTemplates = cfg.activateTemplates;
    pathTemplates = [ "P0-direct" "P1-relay" "P2-microcascade" "P3-onion" "P4-mix" ];
  };
in
{
  options.sourceos.mesh = {
    enable = lib.mkEnableOption "SourceOS mesh Linux estate realization";

    role = lib.mkOption {
      type = lib.types.enum [ "peer" "relay" "exit" "bridge" "introducer" "service" "builder" ];
      default = "peer";
      description = "Logical mesh role carried by this realized host profile.";
    };

    manager = lib.mkOption {
      type = lib.types.enum [ "networkd" "networkmanager" ];
      default = "networkd";
      description = "Primary Linux network manager expected to realize the mesh templates on this host.";
    };

    interfaceName = lib.mkOption {
      type = lib.types.str;
      default = "mesh0";
      description = "Logical WireGuard interface name for the mesh underlay.";
    };

    activateTemplates = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install realized template files into active manager locations in /etc in addition to the SourceOS mesh scaffold path.";
    };

    routeTables = {
      private = lib.mkOption {
        type = lib.types.ints.positive;
        default = 110;
        description = "Route table for direct private mesh traffic.";
      };

      exit = lib.mkOption {
        type = lib.types.ints.positive;
        default = 120;
        description = "Route table for full-tunnel exit traffic.";
      };

      onion = lib.mkOption {
        type = lib.types.ints.positive;
        default = 130;
        description = "Reserved route table for the onion rail.";
      };

      mix = lib.mkOption {
        type = lib.types.ints.positive;
        default = 140;
        description = "Reserved route table for the mix rail.";
      };
    };

    fwmarks = {
      private = lib.mkOption {
        type = lib.types.str;
        default = "0x110";
        description = "fwmark used for direct private mesh traffic.";
      };

      exit = lib.mkOption {
        type = lib.types.str;
        default = "0x120";
        description = "fwmark used for full-tunnel exit traffic.";
      };

      onion = lib.mkOption {
        type = lib.types.str;
        default = "0x130";
        description = "Reserved fwmark for the onion rail.";
      };

      mix = lib.mkOption {
        type = lib.types.str;
        default = "0x140";
        description = "Reserved fwmark for the mix rail.";
      };
    };

    realize = {
      networkTemplates = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Realize the network-manager-facing mesh template files under /etc/sourceos/mesh/.";
      };

      systemdUnits = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Realize the merged systemd unit templates under /etc/sourceos/mesh/.";
      };

      nftablesExit = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Realize the nftables exit template when the host role is exit.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = unique [ cfg.routeTables.private cfg.routeTables.exit cfg.routeTables.onion cfg.routeTables.mix ];
        message = "sourceos.mesh.routeTables values must be unique.";
      }
      {
        assertion = unique [ cfg.fwmarks.private cfg.fwmarks.exit cfg.fwmarks.onion cfg.fwmarks.mix ];
        message = "sourceos.mesh.fwmarks values must be unique.";
      }
    ];

    environment.etc = lib.mkMerge [
      {
        "sourceos/mesh/manifest.json".text = manifestJson;
        "sourceos/mesh/README".text = ''
          SourceOS mesh realization scaffold.
          Role: ${cfg.role}
          Manager: ${cfg.manager}
          Interface: ${cfg.interfaceName}
        '';
      }
      (lib.optionalAttrs cfg.realize.networkTemplates {
        "sourceos/mesh/systemd-networkd/50-${cfg.interfaceName}.netdev".text = netdevTemplate;
        "sourceos/mesh/systemd-networkd/50-${cfg.interfaceName}.network".text = networkTemplate;
        "sourceos/mesh/networkmanager/${cfg.interfaceName}.nmconnection".text = nmTemplate;
      })
      (lib.optionalAttrs cfg.realize.systemdUnits {
        "sourceos/mesh/systemd/meshd.service".source = ../../../linux/systemd/meshd.service;
        "sourceos/mesh/systemd/meshd-linkd.service".source = ../../../linux/systemd/meshd-linkd.service;
        "sourceos/mesh/systemd/meshd-exitd.service".source = ../../../linux/systemd/meshd-exitd.service;
      })
      (lib.optionalAttrs (cfg.role == "exit" && cfg.realize.nftablesExit) {
        "sourceos/mesh/nftables/mesh-exit.nft".source = ../../../linux/nftables/mesh-exit.nft;
      })
      (lib.optionalAttrs (cfg.activateTemplates && cfg.manager == "networkd") {
        "systemd/network/50-${cfg.interfaceName}.netdev".text = netdevTemplate;
        "systemd/network/50-${cfg.interfaceName}.network".text = networkTemplate;
      })
      (lib.optionalAttrs (cfg.activateTemplates && cfg.manager == "networkmanager") {
        "NetworkManager/system-connections/${cfg.interfaceName}.nmconnection".text = nmTemplate;
      })
      (lib.optionalAttrs (cfg.activateTemplates && cfg.realize.systemdUnits) {
        "systemd/system/meshd.service".source = ../../../linux/systemd/meshd.service;
        "systemd/system/meshd-linkd.service".source = ../../../linux/systemd/meshd-linkd.service;
        "systemd/system/meshd-exitd.service".source = ../../../linux/systemd/meshd-exitd.service;
      })
      (lib.optionalAttrs (cfg.activateTemplates && cfg.role == "exit" && cfg.realize.nftablesExit) {
        "nftables.d/mesh-exit.nft".source = ../../../linux/nftables/mesh-exit.nft;
      })
    ];
  };
}
