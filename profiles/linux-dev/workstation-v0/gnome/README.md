# GNOME baseline (workstation-v0)

This directory contains a **minimal GNOME baseline** for the workstation profile.

Principles:

- Behavioral configuration via **GSettings** (no GNOME core forks).
- Conservative defaults that are stable across GNOME upgrades.
- Avoid invasive keybinding rewrites until we pin and validate a full shortcut map.

## Apply

```bash
./apply.sh
```

## Current baseline (v0)

- Enable window buttons: close/minimize/maximize (left)
- Touchpad: tap-to-click + natural scrolling
- Show battery percentage
- Show weekday in clock
- Enable dynamic workspaces

Future work:

- Extension pinset (dash-to-dock, appindicator, etc.)
- Albert hotkey binding (Super+Space) once the command surface is confirmed
- Wayland-safe keyboard remap lane (keyd/xremap) in addition to Kinto
