# Brandon’s Arch Linux dotfiles

Snapshot taken 2026-09-22 on the HP Victus laptop. Intended GitHub visibility: private.

## What is included

- Hyprland **0.56.2 Lua** configuration, custom bindings, idle/lock configuration.
- Quickshell 0.3.1 with Illogical Impulse and the Pibble wallpaper picker, including local modifications.
- Fish, Starship, Kitty/Foot, GTK/KDE themes, Matugen, launchers and portal settings.
- Custom calendar/deadline scripts and their user systemd units, without calendar data or the private feed URL.
- Pibble settings in `settings/pibble-settings.json` and generated shell/terminal colors.
- Package inventories, versions, enabled services and reference system configuration.

## Package lists

`packages/official-explicit.txt` lists explicitly installed native packages according to pacman.
`packages/foreign-explicit.txt` lists explicitly installed foreign packages; these are **not guaranteed to be available in the AUR**. Illogical Impulse metapackages may require the original project’s packaging/setup.
`packages/explicit.txt` combines both, and the version inventories record all installed packages, including dependencies.

Install official packages with pacman after reviewing the list:

```fish
sudo pacman -S --needed (cat packages/official-explicit.txt)
```

Review foreign packages individually; use yay only for packages whose AUR source you trust. Version lists are a snapshot, not a guarantee that older binaries remain available.

## Restore

Run from this repository:

```fish
python restore.py
python restore.py --apply
```

The first command previews destinations. The second backs up every existing destination beneath `~/.local/state/dotfiles-backups/` before copying. It does not install packages, enable services, restart your session or alter boot/system configuration. Existing unrelated files are preserved.

Review the configs first on another machine. This snapshot is from an NVIDIA RTX 4050 laptop with eDP-1, 1920×1080 at 144 Hz, scale 1. Brandon’s desktop instead uses DP-2 on the left at 0×0 and HDMI-A-1 on the right at 1920×0, both 1080p. Hardware and display settings must be adapted to the target machine. Do not copy bootloader, partition, NVIDIA or sleep settings blindly.

Some custom commands and wallpaper paths contain `/home/brandon`. Adjust those when restoring under another username. Wallpapers themselves, installed icon/font themes, private calendar feeds, browser/Discord sessions, keyrings, SSH/GPG keys, command histories, caches and old backups are excluded. Install the listed theme/font packages and choose an available wallpaper after restoring.

Pibble’s settings directory is derived from the config path. Launch Pibble once on the target machine, locate its `settings.json` under `~/.local/state/quickshell/by-shell/`, then restore `settings/pibble-settings.json` to that matching directory while Pibble is stopped. It is intentionally not blindly installed into a machine-specific hashed directory.

The MyLS scripts need your own private `~/.config/myls-calendar/feed.url`. Never commit it. Review the included timer/service before enabling it.

`system/` is reference material only. Enabled-service lists do not imply every service should be enabled on another machine. No disk layout, UUIDs, boot entries or network credentials are included.

## Local fixes retained

- Workspace icons use an Image texture with the existing color effect. If icons become stale after installing apps/themes, restart Quickshell to refresh its icon cache.
- Wallpaper changes retain the previous image visibly during loading, preventing the older wallpaper layer from flashing through.

## Upstream projects and licenses

This is a configuration snapshot containing upstream source and Brandon’s local modifications, not a claim of authorship over upstream code.

- Illogical Impulse: https://github.com/end-4/dots-hyprland
- Pibble: https://github.com/kianblakley/pibble (included LICENSE and font license retained)
- Existing bundled component license files are retained. Upstream components remain under their respective licenses.

## Sharing

A sanitized `.tar.gz` beside this repository is suitable to attach to a Discord DM. A private GitHub URL alone will not give your friend access; invite their GitHub account if you want repository access. No GitHub account for Missilepenguin has been assumed.
