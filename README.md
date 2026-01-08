# grimaur

<img align="left" src="./base/assets/grimoire_d.svg#gh-light-mode-only" width="80" alt="grur logo">
<img align="left" src="./base/assets/grimoire_l.svg#gh-dark-mode-only" width="80" alt="grur logo">

`grimaur` or `grur` for short is a unified package management wrapper for Arch Linux that combines pacman operations, AUR package building, and an interactive TUI into a single tool. **With advanced features** like git fallback, ssh, maintenance tools, etc.

<br clear="left">

```
grur          # Pacman operations (sync, upgrade, install, search...)
grur -a       # AUR operations (search, build, install AUR packages)
grur -m       # Interactive TUI with fzf
```

## Install

### Dependencies
```bash
sudo pacman -S --needed git base-devel pacman-contrib reflector fzf
```

### Setup
```bash
git clone <url>
cd grimaur-too
./grur --help
```

> [!TIP]
> Add to your `$PATH` via `.local/bin`, shell alias, or `/opt`

---

## Pacman (`grur`)

Standard pacman wrapper with simplified commands.

### System Management
```bash
grur mirrors              # Sort mirrors using reflector
grur sync                 # Sync package databases (-Sy)
grur check                # Check for available updates (checkupdates)
grur clean                # Clean package cache (paccache -r)
grur upgrade              # Full system upgrade (-Syu)
grur upgrade --download   # Download only (-Syuw)
grur upgrade --install    # Install downloaded updates (-Su)
```

### Package Operations
```bash
grur search <term>        # Search sync repos
grur search -l <term>     # Search installed packages
grur info <package>       # Show package info
grur install <package>    # Install from sync repos
grur uninstall <package>  # Remove package
grur list                 # List installed packages
grur list --sync          # List sync repo packages
grur deps <package>       # Show dependency tree (pactree)
```

---

## AUR (`grur -a`)

AUR helper that uses the RPC API with automatic fallback to the git mirror.

> [!TIP]
> When the AUR is down, pass `--git-mirror` to bypass RPC entirely.

### Search & Browse
```bash
grur -a <term>                          # Search AUR (shorthand for search)
grur -a search <term>                   # Search AUR packages
grur -a search "pattern-*"              # Regex search (uses git mirror)
grur -a list                            # List installed foreign packages
grur -a info <package> --full           # Show full dependency info
grur -a info <pkg> --target PKGBUILD    # View PKGBUILD directly
```

### Install & Remove
```bash
grur -a install <package>               # Clone, resolve deps, build with makepkg
grur -a install <pkg> --git-mirror      # Skip AUR RPC
grur -a install <pkg> --use-ssh         # Use SSH for git
grur -a uninstall <package>             # Remove package
grur -a uninstall <pkg> --cache         # Delete cached files
```

### Custom Repositories
```bash
grur -a install <pkg> --repo-url <url>    # Build from custom git URL
grur -a fetch <pkg> --repo-url <url>      # Fetch without installing
```

Example - build `archinstall` from source:
```bash
grur -a install archinstall-latest --repo-url https://github.com/archlinux/archinstall
```

### Upgrades
```bash
grur -a upgrade                   # Rebuild outdated foreign packages
grur -a upgrade <pkg1> <pkg2>     # Upgrade specific packages only
grur -a upgrade --devel           # Include *-git packages
grur -a upgrade --global          # Sync system first, then AUR
grur -a upgrade --refresh         # Force fresh pull of all packages
```

### Additional Options

> Useful for scripting on top of or modifying.

```bash
--dest-root <path>    # Build directory useful for /tmp (default: ~/.cache/aurgit)
--no-color            # Disable colored output
--noconfirm           # Skip confirmation prompts
--limit N             # Limit search results
--no-interactive      # List results without install prompt
```

---

## TUI (`grur -m`)

> Fuzzy-finding interface powered by fzf.

```bash
grur -m                # Main menu
grur -m aur            # Search AUR packages
grur -m sync           # Search sync repo packages
grur -m installed      # Browse installed packages
```

- Type to filter, TAB to select multiple
- ENTER toggles install/remove based on package state
- Preview pane shows package info

---

## Notes

- Respects `IgnorePkg` from `/etc/pacman.conf` as `x y z`
- Default [`pacman.conf`](https://gitlab.archlinux.org/archlinux/packaging/packages/pacman/-/blob/main/pacman.conf)
- Default [mirrorlist gen](https://archlinux.org/mirrorlist/)

