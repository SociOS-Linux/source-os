#!/usr/bin/env bash
set -euo pipefail

# Harden and classify an existing NetworkManager WireGuard profile for full-tunnel exit use.
# Usage:
#   ./harden-existing-wireguard-profile.sh wg-mesh

NAME="${1:-wg-mesh}"

nmcli connection modify "$NAME" ipv4.route-table 120 ipv6.route-table 120
nmcli connection modify "$NAME" wireguard.ip4-auto-default-route yes
nmcli connection modify "$NAME" wireguard.ip6-auto-default-route yes
nmcli connection modify "$NAME" +ipv4.routing-rules "priority 10020 fwmark 0x120 table 120"
nmcli connection modify "$NAME" +ipv6.routing-rules "priority 10020 fwmark 0x120 table 120"
nmcli connection modify "$NAME" ipv4.ignore-auto-dns yes ipv6.ignore-auto-dns yes
nmcli connection modify "$NAME" ipv4.dns-priority -32768 ipv6.dns-priority -32768
nmcli connection modify "$NAME" ipv4.never-default no ipv6.never-default no

echo "Profile '$NAME' updated. Review with:"
echo "  nmcli -f connection.id,ipv4.route-table,ipv6.route-table,wireguard.ip4-auto-default-route,wireguard.ip6-auto-default-route,ipv4.dns-priority,ipv6.dns-priority connection show $NAME"
