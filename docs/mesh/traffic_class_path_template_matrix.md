# Traffic-Class / Path-Template Matrix

The mesh should not pretend that all traffic shares one path discipline. Different traffic classes need different routing semantics.

## Traffic classes

### Admission
Purpose: invites, introducer handshakes, first-contact rendezvous, peer metadata provisioning.

Preferred path:
- wormhole-like or introducer-mediated channel
- short-lived
- never a generic exit path

Linux expression:
- local `meshd` control socket
- ordinary outbound host networking until enrollment completes

### Control-plane replication
Purpose: capability manifest updates, revocation, policy distribution, anti-entropy.

Preferred path:
- direct mesh first
- 2-hop microcascade fallback when observation risk rises

Linux expression:
- table 100
- fwmark `0x100`

### Private service traffic
Purpose: RPC, replication, admin operations, internal APIs.

Preferred path:
- direct mesh
- relay fallback
- optional microcascade when policy demands operator or jurisdiction separation

Linux expression:
- table 110
- fwmark `0x110`

### Full-tunnel exit traffic
Purpose: public internet egress, remote IP locality, public-Wi-Fi posture.

Preferred path:
- direct trusted exit for low-risk traffic
- microcascade to exit for medium-risk traffic

Linux expression:
- table 120
- fwmark `0x120`
- catch-all routes plus nftables NAT on the exit node

### Interactive anonymous traffic
Purpose: sessions needing anonymity rather than only transport privacy.

Preferred path:
- onion rail
- bridge or pluggable-transport entry when required

Linux expression:
- local proxy or helper process
- table 130
- fwmark `0x130`

### Async high-risk traffic
Purpose: delayed messaging, store-and-forward, control replication under active observation.

Preferred path:
- mix rail only
- not the default for ordinary traffic

Linux expression:
- user-space app or gateway path first
- table 140 only if emitted as IP

## Path templates

- `P0-direct` — single peer path over the WireGuard underlay
- `P1-relay` — one relay for reachability, not anonymity
- `P2-microcascade` — two or three constrained hops from policy-approved nodes
- `P3-onion` — low-latency layered anonymity path
- `P4-mix` — delayed metadata-resistance path for high-risk asynchronous traffic only

## Default stance

- servers use `P0` for service traffic and `P2` only where policy requires harder separation
- laptops use `P0` when trusted and `P2` or `P3` when roaming or censored
- exits must not self-select as both client and exit in the same risk context
