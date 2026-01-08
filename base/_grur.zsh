#compdef grur
# Completion for grur (unified grimaur/gpmwrap wrapper)
# grur [...] runs gpmwrap (pacman operations)
# grur -a [...] runs grimaur (AUR operations)

_grur() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    # Check if -a is in the command line (AUR mode)
    if [[ ${words[(i)-a]} -le ${#words} ]]; then
        _grur_aur "$@"
    else
        _grur_pacman "$@"
    fi
}

_grur_aur() {
    local -a global_opts
    global_opts=(
        '--dest-root[Directory to store cloned packages]:directory:_directories'
        '--refresh[Refresh existing clones before use]'
        '--no-color[Disable colored output]'
        '--aur-rpc[Use AUR RPC API (default)]'
        '--git-mirror[Use git mirror instead of AUR RPC]'
        '--use-ssh[Use SSH instead of HTTPS]'
    )

    _arguments -C \
        '-a[AUR mode (grimaur)]' \
        $global_opts \
        '1: :->command' \
        '*:: :->args' \
        && return 0

    case $state in
        command)
            local -a commands
            commands=(
                'fetch:Clone the package branch locally'
                'install:Resolve dependencies and build/install a package'
                'uninstall:Remove an installed package'
                'upgrade:Upgrade installed foreign packages'
                'search:Search packages via the configured backend'
                'info:Show PKGBUILD or dependency information'
                'list:List installed foreign (AUR) packages'
            )
            _describe -t commands 'grimaur command' commands
            ;;
        args)
            case $line[1] in
                fetch)
                    _arguments \
                        $global_opts \
                        '--force[Reclone even if directory exists]' \
                        '--repo-url[Clone from custom Git URL]:url:' \
                        '1:package:_grur_aur_packages'
                    ;;
                install)
                    _arguments \
                        $global_opts \
                        '--noconfirm[Pass --noconfirm to pacman/makepkg]' \
                        '--repo-url[Clone from custom Git URL]:url:' \
                        '1:package:_grur_aur_packages'
                    ;;
                uninstall)
                    _arguments \
                        $global_opts \
                        '--noconfirm[Pass --noconfirm to pacman]' \
                        '--remove-cache[Also remove the cached clone]' \
                        '1:package:_grur_foreign_packages'
                    ;;
                upgrade)
                    _arguments \
                        $global_opts \
                        '--noconfirm[Pass --noconfirm to pacman/makepkg]' \
                        '--devel[Include VCS/devel packages]' \
                        '--global[Sync official repositories first]' \
                        '*:packages:_grur_foreign_packages'
                    ;;
                search)
                    _arguments \
                        $global_opts \
                        '--limit[Limit results]:number:(10 20 50 100)' \
                        '--no-interactive[Disable interactive selection]' \
                        '--noconfirm[Skip confirmation prompts]' \
                        '1:pattern:'
                    ;;
                info)
                    _arguments \
                        $global_opts \
                        '--target[Which data to show]:target:(info PKGBUILD SRCINFO)' \
                        '--full[Include make/check/optional dependencies]' \
                        '--repo-url[Inspect from custom Git URL]:url:' \
                        '1:package:_grur_aur_packages'
                    ;;
                list)
                    _arguments $global_opts
                    ;;
            esac
            ;;
    esac
}

_grur_pacman() {
    _arguments -C \
        '-a[AUR mode (grimaur)]' \
        '--no-color[Disable colored output]' \
        '1: :->command' \
        '*:: :->args' \
        && return 0

    case $state in
        command)
            local -a commands
            commands=(
                'mirrors:Sort mirrors using reflector'
                'sync:Sync package databases (pacman -Sy)'
                'upgrade:Full system upgrade (pacman -Syu)'
                'check:Check for available updates'
                'clean:Clean old packages from cache'
                'deps:Show dependency tree for a package'
                'list:List packages and their files'
                'search:Search for packages'
                'info:Show detailed package information'
                'install:Install a package from sync repos'
                'uninstall:Uninstall a package'
            )
            _describe -t commands 'gpmwrap command' commands
            ;;
        args)
            case $line[1] in
                mirrors)
                    _arguments \
                        '--no-color[Disable colored output]' \
                        '(-p --protocol)'{-p,--protocol}'[Mirror protocol]:protocol:(https http)' \
                        '(-l --latest)'{-l,--latest}'[Number of latest mirrors]:number:' \
                        '(-s --sort)'{-s,--sort}'[Sort method]:method:(rate age score country)' \
                        '(-c --country)'{-c,--country}'[Filter by country]:country:'
                    ;;
                sync)
                    _arguments \
                        '--no-color[Disable colored output]' \
                        '--noconfirm[Do not ask for confirmation]'
                    ;;
                upgrade)
                    _arguments \
                        '--no-color[Disable colored output]' \
                        '--noconfirm[Do not ask for confirmation]' \
                        '(-w --download)'{-w,--download}'[Download without installing]' \
                        '(-u --install)'{-u,--install}'[Install already-downloaded packages]'
                    ;;
                check|clean)
                    _arguments '--no-color[Disable colored output]'
                    ;;
                deps)
                    _arguments \
                        '--no-color[Disable colored output]' \
                        '1:package:_grur_all_packages'
                    ;;
                list)
                    _arguments \
                        '--no-color[Disable colored output]' \
                        '(-s --sync)'{-s,--sync}'[List from sync repos instead of installed]'
                    ;;
                search)
                    _arguments \
                        '--no-color[Disable colored output]' \
                        '(-l --local)'{-l,--local}'[Search installed packages]' \
                        '(-e --exact)'{-e,--exact}'[Exact match on installed packages]' \
                        '1:pattern:'
                    ;;
                info)
                    _arguments \
                        '--no-color[Disable colored output]' \
                        '(-l --local)'{-l,--local}'[Query installed package]' \
                        '1:package:_grur_all_packages'
                    ;;
                install)
                    _arguments \
                        '--no-color[Disable colored output]' \
                        '1:package:_grur_sync_packages'
                    ;;
                uninstall)
                    _arguments \
                        '--no-color[Disable colored output]' \
                        '--no-deps[Do not remove orphaned dependencies]' \
                        '1:package:_grur_installed_packages'
                    ;;
            esac
            ;;
    esac
}

# Helper: AUR package names
_grur_aur_packages() {
    local -a packages
    local prefix="$PREFIX"
    if [[ ${#prefix} -ge 2 ]]; then
        packages=(${(f)"$(grimaur complete install "$prefix" 2>/dev/null)"})
        _describe -t packages 'AUR package' packages
    fi
}

# Helper: installed foreign packages
_grur_foreign_packages() {
    local -a packages
    packages=(${(f)"$(pacman -Qmq 2>/dev/null)"})
    _describe -t packages 'foreign package' packages
}

# Helper: all installed packages
_grur_installed_packages() {
    local -a packages
    packages=(${(f)"$(pacman -Qq 2>/dev/null)"})
    _describe -t packages 'installed package' packages
}

# Helper: sync repo packages
_grur_sync_packages() {
    local -a packages
    packages=(${(f)"$(pacman -Slq 2>/dev/null)"})
    _describe -t packages 'package' packages
}

# Helper: all packages (sync)
_grur_all_packages() {
    _grur_sync_packages
}

_grur "$@"
