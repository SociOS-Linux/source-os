# workstation-v0 macOS shortcut map

This document is the **bounded shortcut contract** for the workstation-v0 Mac-on-Linux lane.
It distinguishes bindings that are **currently active** (enforced by existing helpers) from
bindings that are **proposed / future work** (not yet applied to any configuration).

---

## Active bindings

The bindings below are applied by `profiles/linux-dev/workstation-v0/gnome/mac-defaults.sh`
and `profiles/linux-dev/workstation-v0/gnome/palette-hotkey.sh`.
They can be verified at any time with
`profiles/linux-dev/workstation-v0/doctor.sh`.

| Shortcut         | Action                          | GNOME slot  | Enforced by              |
|------------------|---------------------------------|-------------|--------------------------|
| `Super+Space`    | Open SourceOS palette           | custom0     | `palette-hotkey.sh`      |
| `Super+E`        | Open Files (Nautilus)           | custom1     | `mac-defaults.sh`        |
| `Super+Return`   | Open Terminal (gnome-terminal)  | custom2     | `mac-defaults.sh`        |
| `Super+Shift+3`  | Full-screen screenshot          | custom3     | `mac-defaults.sh`        |
| `Super+Shift+4`  | Area screenshot                 | custom4     | `mac-defaults.sh`        |
| `Super+Shift+5`  | Interactive screenshot UI       | custom5     | `mac-defaults.sh`        |
| `Super+Shift+6`  | Open Screenshots folder         | custom6     | `mac-defaults.sh`        |

Screenshot commands are delegated to `mac-screenshot.sh`; output lands in
`~/Pictures/Screenshots`.

Input-source switching is moved out of `Super+Space` to avoid collision:
- `Alt+Shift_L` → switch input source forward
- `Alt+Shift_R` → switch input source backward

---

## Proposed / future bindings (non-active)

> **These bindings are NOT currently enforced.**
> They are recorded here as planned macOS-parity work for a future lane.
> No keybinding files, remap daemons, or GSettings entries reference them yet.

| Shortcut              | macOS equivalent         | Proposed action                         | Status        |
|-----------------------|--------------------------|-----------------------------------------|---------------|
| `Super+C`             | `Cmd+C`                  | Copy (system clipboard)                 | future        |
| `Super+V`             | `Cmd+V`                  | Paste (system clipboard)                | future        |
| `Super+X`             | `Cmd+X`                  | Cut                                     | future        |
| `Super+Z`             | `Cmd+Z`                  | Undo                                    | future        |
| `Super+Shift+Z`       | `Cmd+Shift+Z`            | Redo                                    | future        |
| `Super+A`             | `Cmd+A`                  | Select all                              | future        |
| `Super+W`             | `Cmd+W`                  | Close window/tab                        | future        |
| `Super+Q`             | `Cmd+Q`                  | Quit application                        | future        |
| `Super+Tab`           | `Cmd+Tab`                | Switch application (app switcher)       | future        |
| ``Super+` ``          | `` Cmd+` ``               | Switch window within application        | future        |
| `Super+Shift+3`       | `Cmd+Shift+3`            | Full-screen screenshot (already active) | **active**    |
| `Super+Shift+4`       | `Cmd+Shift+4`            | Area screenshot (already active)        | **active**    |
| `Super+Shift+Control+3` | `Cmd+Ctrl+Shift+3`     | Screenshot to clipboard                 | future        |
| `Super+Shift+Control+4` | `Cmd+Ctrl+Shift+4`     | Area screenshot to clipboard            | future        |

Proposed bindings that overlap active bindings are listed for completeness only.

---

## Helpers that enforce active bindings

| Helper                                           | Responsibility                                                           |
|--------------------------------------------------|--------------------------------------------------------------------------|
| `gnome/palette-hotkey.sh`                        | Sets `Super+Space` → `sourceos palette`; moves input-source switch       |
| `gnome/mac-defaults.sh`                          | Sets Files, Terminal, and all screenshot shortcuts (custom1–custom6)     |
| `doctor.sh` (`check_mac_defaults`)               | Smoke-checks that custom-keybinding slots are populated                  |

---

## Validation

```bash
# Document exists and is non-empty
test -s docs/workstation/shortcut-map.md

# Key shortcuts are present in the document
grep -R "Super+Shift+3" docs/workstation profiles/linux-dev/workstation-v0/gnome

# Active bindings are enforced by helper scripts
grep -q '<Super><Shift>3' profiles/linux-dev/workstation-v0/gnome/mac-defaults.sh
grep -q '<Super>space'    profiles/linux-dev/workstation-v0/gnome/palette-hotkey.sh
```

---

## Non-goals (v0)

- Do not change keybindings in this document.
- Do not modify remap daemon behavior.
- Do not modify package manifests.
- Do not claim parity with macOS beyond the active bindings listed above.
- Proposed bindings require a separate remap-lane validation pass before activation.
