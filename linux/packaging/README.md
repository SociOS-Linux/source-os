# Packaging Notes

Recommended package split:

- `meshd`
- `meshd-linkd`
- `meshd-exitd`
- `meshctl`
- `meshd-networkd`
- `meshd-networkmanager`
- `meshd-nftables`
- `meshd-selinux` (optional)
- `meshd-apparmor` (optional)
- `meshd-onion` (optional)
- `meshd-mix` (optional)

Deb/RPM/Nix packaging should converge on the same runtime surfaces:
- `/etc/meshd/`
- `/usr/libexec/`
- `/usr/lib/systemd/system/`
- `/usr/lib/systemd/network/` or `/etc/systemd/network/`
- `/usr/share/doc/meshd/`
