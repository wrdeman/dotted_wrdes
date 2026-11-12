# sway & waybar config

Reference for the sway (`sway/config`) and waybar (`waybar/`) setup in this repo. sway
replaced i3 (which needed Xorg); the config is a port of the old i3 one. Both are
Linux-only and symlinked by `install.sh` (`~/.config/sway/config`, `~/.config/waybar`).

> Keep this file in sync when you change `sway/config` or anything under `waybar/`.

Start it from a TTY with `sway`, or pick **Sway** at the login screen.

## Basics

- **`Mod` is Super** (the Windows key). Directions are vim keys: `h` left, `j` down,
  `k` up, `l` right. The arrow keys work in resize mode too.
- Keyboard layout `gb`; touchpad has tap-to-click and natural scrolling.
- Wallpaper: drop an image at `~/.wallpaper`, or you get a solid `#2f343f`.
- Dialogs and pop-ups from XWayland apps float automatically. GIMP always opens on the
  `gimp` workspace.
- Check devices with `swaymsg -t get_inputs` / `swaymsg -t get_outputs`. For HiDPI, add
  e.g. `output DP-1 scale 2`.

## Keybindings

### Launching & session

| Key | Action |
|-----|--------|
| `Mod+Enter` | terminal (`x-terminal-emulator`) |
| `Mod+d` | fuzzel app launcher |
| `Mod+Shift+d` | fuzzel: run any program on `$PATH` |
| `Mod+c` / `Mod+i` / `Mod+Shift+s` | Chrome / Firefox / Spotify |
| `Mod+Shift+q` | close focused window |
| `Ctrl+Alt+l` | lock screen (swaylock) |
| `Mod+Shift+c` | reload config (sway has no in-place restart; reload is enough) |
| `Mod+Shift+e` | power menu (swaynag): exit sway / reboot / shut down |

### Focus, moving & layout

| Key | Action |
|-----|--------|
| `Mod+h/j/k/l` | focus left / down / up / right |
| `Mod+Shift+h/j/k/l` | move focused window |
| `Mod+;` | next window opens to the side (split h) |
| `Mod+v` | next window opens below (split v) |
| `Mod+f` | fullscreen toggle |
| `Mod+w` / `Mod+s` | tabbed / stacked layout |
| `Mod+e` | back to split, toggling side-by-side ↔ top-and-bottom |
| `Mod+a` | focus parent container |
| `Mod+Shift+Space` | float / unfloat window |
| `Mod+Space` | toggle focus between tiled and floating windows |
| `Mod`+drag | move a floating window (right-drag resizes) |
| `Mod+Shift+-` / `Mod+-` | send window to scratchpad / show scratchpad |

### Workspaces & monitors

| Key | Action |
|-----|--------|
| `Mod+1`..`Mod+0` | switch to workspace 1–10 |
| `Mod+Shift+1`..`0` | send window to workspace 1–10 |
| `Mod+Shift+<` / `Mod+Shift+>` | send window to the monitor on the left / right |

### Resize mode

`Mod+r` enters resize mode (shown in waybar). `h`/`l` shrink/grow width, `k`/`j`
shrink/grow height, 10px per press. Leave with `Enter`, `Esc` or `Mod+r`.

### Media & screenshots

| Key | Action |
|-----|--------|
| `Mod+Ctrl+Left` / `Mod+Ctrl+Right` (or `Up`) | volume down / up (capped at 100%) |
| `Mod+Ctrl+Down` | mute toggle |
| `XF86Audio*` keys | volume / mute / mic mute (work on the lock screen too) |
| `Mod+Print` | screenshot a selected area (grim + slurp) |
| `Ctrl+Print` | screenshot the whole screen |

Screenshots are saved to `~/Pictures/YYYYMMDD_HHMMSS.png`. The `pss` alias in `.aliases`
does the same area capture from a shell. `xclip` is aliased to `wl-copy`, so
`cat file | xclip` copies to the Wayland clipboard.

## Common examples

- **Two terminals side by side, one below the right one:** `Mod+Enter`, `Mod+Enter`, then
  `Mod+v`, `Mod+Enter`.
- **Browser on its own workspace:** `Mod+2`, `Mod+i`; then `Mod+1` / `Mod+2` to flip back
  and forth.
- **Move a window to another workspace:** focus it, `Mod+Shift+3`.
- **Several windows in one slot:** `Mod+w` makes the container tabbed; `Mod+h`/`Mod+l`
  switch tabs. `Mod+e` returns to split.
- **Quick scratch terminal:** open a terminal, `Mod+Shift+-` hides it; `Mod+-` toggles it
  over whatever you're doing.
- **Resize a split:** `Mod+r`, tap `l` a few times, `Esc`.
- **Grab a region to share:** `Mod+Print`, drag a box, then pick it up from `~/Pictures`.

## Autostart & idle

- **swayidle:** locks after 10 min idle, turns screens off after 15 min (any input turns
  them back on), and locks before suspend.
- **nm-applet** sits in the waybar tray for Wi-Fi/network.
- **blueman-applet** sits in the tray for Bluetooth (pairing, connect/disconnect).
- `dbus-update-activation-environment` passes the Wayland session to portals
  (`xdg-desktop-portal-wlr`), so screen sharing and file pickers work.
- `/etc/sway/config.d/*` (distro defaults) is included last.

## waybar (`waybar/config.jsonc`, `waybar/style.css`)

Top bar, launched by sway via `bar { swaybar_command waybar }`.

- **Left:** workspaces (clickable), current mode (e.g. `resize`).
- **Right:** volume (click to mute), memory, network (SSID + IP), bluetooth, CPU, battery, clock,
  tray.
- **Bluetooth module:** just the icon when on with nothing connected, shows the device name
  (+ battery if reported) when connected, greyed `off` when powered down. Left-click
  opens `blueman-manager`; right-click toggles power. If it shows off after a reboot,
  the adapter is rfkill-blocked: `rfkill unblock bluetooth`.
- Font is DejaVu Sans Mono with Font Awesome for icons (`fonts-font-awesome`).
- After editing waybar files, `Mod+Shift+c` reloads sway, which restarts the bar.
