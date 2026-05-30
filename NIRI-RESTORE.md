# Restoring niri to a working state

Niri (Wayland compositor) was set up on 2026-05-05 and then partially torn down
the same day because `xdg-desktop-portal-wlr` was breaking Slack screen-share
under awesomewm (X11). The niri configs themselves are intact — only the
host-level pieces that affected the X11 session were rolled back.

This document explains how to bring niri back to the state it was in before
the rollback, so screen-share, screenshots, and the rest of the desktop
integration work again under niri.

## What is still on the system (no action needed)

- `/home/akingston/.cargo/bin/niri` — built from source, untouched
- `/usr/local/bin/niri-session` — wrapper that exports
  `XDG_SESSION_TYPE=wayland`, `XDG_CURRENT_DESKTOP=niri`,
  `XDG_SESSION_DESKTOP=niri`, then execs niri
- `/usr/share/wayland-sessions/niri.desktop` — login-manager session entry
- `~/.config/niri/` — config.kdl + scripts (sidebar.py, start-sidebar.sh,
  timezone.sh, install.sh, install-session.sh)
- `~/.config/waybar/`, `~/.config/wofi/`, `~/.config/alacritty/`,
  `~/.config/mako/`, `~/.config/swaylock/` — direct dirs (not yet migrated
  into `~/dots/16-niri` … `21-swaylock` per the earlier migration plan)
- Apt packages: waybar, wofi, alacritty, mako-notifier, swaylock,
  wl-clipboard, grim, slurp, brightnessctl, pavucontrol, etc.

## What was rolled back (must redo to get niri healthy)

### 1. Reinstall the wlroots portal backend

```bash
sudo apt install -y xdg-desktop-portal-wlr
```

This is the actual reason niri's screen-share broke our awesome session: the
package's `wlr.portal` advertises `ScreenCast` for `wlroots/sway/Hyprland/etc`,
and once *any* portal advertises ScreenCast, Chromium's
`WebRTCPipeWireCapturer` (Slack uses it) tries the portal route on X11 too
and refuses to fall back to native X11 capture. Removing the package
restores the X11 fallback.

Under niri, this package is required for screen-share / screenshot portals
to work.

### 2. Recreate the niri-only portals.conf

```bash
mkdir -p ~/.config/xdg-desktop-portal
cat > ~/.config/xdg-desktop-portal/niri-portals.conf <<'EOF'
[preferred]
default=gtk
org.freedesktop.impl.portal.ScreenCast=wlr
org.freedesktop.impl.portal.Screenshot=wlr
EOF
```

The filename matters: `niri-portals.conf` is per-desktop and is only consulted
when `XDG_CURRENT_DESKTOP=niri`. Do **not** use a non-suffixed `portals.conf`
(global) — that's what poisoned the awesome session.

### 3. Re-mask autorandr under niri (only when actually using niri)

autorandr was wiping `swww` wallpaper state on every HDMI hotplug under niri.
Under awesome, autorandr is useful and should stay unmasked. So this step is
only needed when actively running niri:

```bash
sudo systemctl mask autorandr.service autorandr-lid-listener.service
sudo systemctl stop autorandr-lid-listener.service
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/autorandr.desktop <<'EOF'
[Desktop Entry]
Hidden=true
EOF
```

A cleaner long-term fix would be to drive masking from the niri-session
wrapper or from a niri systemd target, so autorandr is only suppressed while
niri is actually the active session. Not done yet.

## What was deleted because it was wrong (do NOT recreate)

### `~/.config/environment.d/niri.conf`

Contained:

```
XDG_SESSION_TYPE=wayland
XDG_CURRENT_DESKTOP=niri
```

This file is read by the systemd `--user` manager at startup and propagates to
every session — including awesome. It told the portal manager to behave as if
niri was active even when awesome was. The `niri-session` wrapper already
exports these correctly when niri actually runs, so the file was redundant
and harmful.

### Stale `xdg-desktop-portal-hyprland` symlink

`/usr/share/xdg-desktop-portal/portals/hyprland.portal` was a symlink to
`~/.local/share/xdg-desktop-portal/portals/hyprland.portal` which never
existed. Leftover from a hyprland experiment. Removed.

## Other guardrails

### `~/dots/01-zsh/.zshrc` Wayland fallback

The block:

```bash
if [ "$XDG_SESSION_TYPE" = "wayland" ] && [ -z "$WAYLAND_DISPLAY" ] && [ -S "/run/user/$(id -u)/wayland-1" ]; then
    export WAYLAND_DISPLAY=wayland-1
fi
```

is now gated on `XDG_SESSION_TYPE=wayland` (was previously gated only on the
socket existing, which leaked `WAYLAND_DISPLAY` into awesome shells when a
stale socket was on disk). Leave the gate in place.

### Slack flatpak override

```
flatpak override --user --show com.slack.Slack
```

…hardcodes `XDG_SESSION_TYPE=x11`, `XDG_CURRENT_DESKTOP=awesome`,
`ELECTRON_OZONE_PLATFORM_HINT=x11`, and `sockets=x11;!wayland;!fallback-x11`.
For niri, this would force Slack into XWayland mode — fine for now but if you
want native-Wayland Slack later, edit with:

```bash
flatpak override --user com.slack.Slack \
    --env=XDG_SESSION_TYPE=wayland \
    --env=XDG_CURRENT_DESKTOP=niri \
    --env=ELECTRON_OZONE_PLATFORM_HINT=auto \
    --socket=wayland --nosocket=fallback-x11
```

## Quick checklist to re-enter niri later

1. `sudo apt install -y xdg-desktop-portal-wlr`
2. Recreate `~/.config/xdg-desktop-portal/niri-portals.conf` (block above)
3. Mask autorandr (block above)
4. Log out, pick "Niri" at the display manager
5. Test: `grim` for screenshot, OBS or Slack for ScreenCast
6. When done with niri and going back to awesome:
   - `sudo apt remove -y xdg-desktop-portal-wlr`
   - `sudo systemctl unmask autorandr.service autorandr-lid-listener.service`
   - `rm ~/.config/autostart/autorandr.desktop`
   - `systemctl --user restart xdg-desktop-portal.service`
