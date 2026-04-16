# Upstream Workstreams

## Workstream A — zero-kernel-delta MVP
Ship entirely in user space.
Use existing WireGuard, existing netlink, existing nftables, and existing network managers.

This is the default and preferred path.

## Workstream B — Linux estate integration
Deliver:
- systemd units
- systemd-networkd templates
- NetworkManager profile or dispatcher integration
- nftables policy templates
- packaging notes and future package specs
- SELinux/AppArmor policy later

## Workstream C — censorship-resistance edge
Deliver separately:
- Tor bridge or pluggable-transport helper
- optional anonymous ingress
- workstation-focused packaging

## Workstream D — mix rail
Defer until the first three workstreams are stable.

## Rule of thumb
If a feature can remain in user space without harming correctness or performance materially, keep it in user space.
