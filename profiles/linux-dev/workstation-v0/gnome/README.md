# GNOME baseline (workstation-v0)

This directory contains a **minimal GNOME baseline** for the workstation profile.

Principles:

- Behavioral configuration via **GSettings**.
- Conservative defaults that are stable across GNOME upgrades.
- Avoid invasive keybinding rewrites until we pin and validate a full shortcut map.
- Mac-like behavior is implemented as bounded GNOME defaults, helper scripts, and packaged GNOME components.

## Apply

```bash
./apply.sh
./extensions-install.sh
./mac-defaults.sh
```

## Current baseline (v0)

- Enable window buttons: close/minimize/maximize (left)
- Touchpad: tap-to-click + natural scrolling
- Show battery percentage
- Show weekday/date in clock
- Enable dynamic workspaces
- Dash-to-Dock and AppIndicator extension pinset
- SourceOS palette on `Super+Space`
- Files on `Super+E`
- Terminal on `Super+Return`

## Mac polish v1

- Quick preview through Fedora's `sushi` package
- Screenshot helper wrapper installed as `~/.local/bin/mac-screenshot.sh`
- Screenshot output directory at `~/Pictures/Screenshots`
- `Super+Shift+3` full-screen screenshot
- `Super+Shift+4` area screenshot
- `Super+Shift+5` interactive screenshot UI
- `Super+Shift+6` open screenshot directory

## Follow-on work

- Wayland-safe keyboard remap lane expansion
- Optional bounded icon/cursor/font appearance pack
- More complete macOS-style shortcut map after validation
