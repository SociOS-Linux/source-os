# Mesh Linux Estate Upstream Plan

## Goal

Integrate the mesh into a Linux estate in a way that is upstream-friendly, operationally sane, and survivable under hostile or degraded networks.

The design separates four concerns:
1. control-plane provenance and admission
2. transport reachability
3. traffic-class-specific data paths
4. egress and censorship-resistance edge behavior

## Linux-native constraints

Release 1 should avoid inventing a bespoke in-kernel anonymous network stack.

Use existing Linux primitives for what they already do well:
- WireGuard for the encrypted underlay
- rtnetlink / generic netlink / iproute2 for link and route control
- nftables for exit NAT and policy enforcement
- systemd-networkd and NetworkManager as first-class estate front-ends
- systemd units, credentials, and local sockets for lifecycle and secret delivery

Do not put onion routing, mix scheduling, rendezvous mailboxes, or trust policy into the kernel in Release 1.

## Privilege split

Use separate processes instead of one omnipotent daemon:

### `meshd`
Unprivileged control-plane daemon for identity, enrollment, capability manifests, operator API, and replayable audit data.

### `meshd-linkd`
Privileged network mutator for WireGuard interfaces, peers, route tables, rules, and fwmarks.

### `meshd-exitd`
Privileged edge helper for forwarding, nftables NAT/filter policy, and exit-role health/accounting.

### `mesh-ptd` / bridge helper
Optional user-space censorship-resistance edge for anonymous ingress, bridge integration, or pluggable transports.

## Estate split

### Headless servers and relays
Prefer `systemd-networkd` for server roles, exits, relays, and appliances.

### Workstations and roaming devices
Prefer NetworkManager for laptops and operator-facing devices because it already handles Wi-Fi, roaming, DNS policy, and WireGuard profiles well.

### Mixed estate rule
Do not force one network manager everywhere. Treat manager choice as a role decision.

## Release-1 scope

### In scope
- cryptographic node identity
- signed capability manifests
- direct plus relay-assisted WireGuard underlay
- route policy via fwmark and dedicated route tables
- optional exit role
- Linux templates, units, and packaging notes
- observability and replayable control-plane records

### Out of scope
- kernel-resident mixnet or onion routing
- global cover traffic by default
- bespoke kernel modules
- full Tor clone inside the Linux realization repo

## Repo placement in `source-os`

- `docs/mesh/` — design and rollout docs
- `linux/systemd-networkd/` — networkd templates
- `linux/systemd/` — service units for helper daemons
- `linux/networkmanager/` — NM profile templates
- `linux/nftables/` — exit policy templates
- `linux/packaging/` — packaging notes and future spec stubs

Shared schemas belong in `SocioProphet/socioprophet-agent-standards`, not here.
