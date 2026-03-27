# Bash completion for grur (unified grimaur/gpmwrap wrapper)
# grur [...] runs gpmwrap (pacman operations)
# grur -a [...] runs grimaur (AUR operations)

_grur_completion()
{
    local cur prev words cword
    if ! _init_completion -n = 2>/dev/null; then
        words=("${COMP_WORDS[@]}")
        cword="${COMP_CWORD}"
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Check if -a flag is present (AUR mode)
    local aur_mode=false
    for word in "${words[@]}"; do
        if [[ "$word" == "-a" ]]; then
            aur_mode=true
            break
        fi
    done

    # Find the subcommand (first non-option word after grur and potential -a)
    local subcmd=""
    local subcmd_idx=0
    for ((i=1; i<${#words[@]}; i++)); do
        if [[ "${words[i]}" == "-a" ]]; then
            continue
        fi
        if [[ "${words[i]}" != -* ]] && [[ "${words[i]}" != "" ]]; then
            subcmd="${words[i]}"
            subcmd_idx=$i
            break
        fi
    done

    # If completing first arg and it starts with -, offer -a
    if [[ $cword -eq 1 ]] && [[ "$cur" == -* ]]; then
        mapfile -t COMPREPLY < <(compgen -W "-a" -- "$cur")
        return 0
    fi

    if $aur_mode; then
        # AUR mode (grimaur) completions
        local global_opts="--dest-root --refresh --no-color --aur-rpc --git-mirror --use-ssh"

        if [[ "$prev" == "--dest-root" ]]; then
            mapfile -t COMPREPLY < <(compgen -d -- "$cur")
            return 0
        fi

        if [[ "$cur" == -* ]]; then
            local opts="$global_opts"
            case "$subcmd" in
                fetch)
                    opts="$global_opts --force --repo-url"
                    ;;
                install)
                    opts="$global_opts --noconfirm --repo-url"
                    ;;
                uninstall)
                    opts="$global_opts --noconfirm --remove-cache"
                    ;;
                upgrade)
                    opts="$global_opts --noconfirm --devel --global"
                    ;;
                search)
                    opts="$global_opts --limit --no-interactive --noconfirm"
                    ;;
                info)
                    opts="$global_opts --target --full --repo-url"
                    ;;
            esac
            mapfile -t COMPREPLY < <(compgen -W "$opts" -- "$cur")
            return 0
        fi

        if [[ "$prev" == "--target" ]] && [[ "$subcmd" == "info" ]]; then
            mapfile -t COMPREPLY < <(compgen -W "info PKGBUILD SRCINFO" -- "$cur")
            return 0
        fi

        if [[ "$prev" == "--limit" ]]; then
            mapfile -t COMPREPLY < <(compgen -W "10 20 50 100" -- "$cur")
            return 0
        fi

        if [[ -z "$subcmd" ]]; then
            local subcmds="fetch install uninstall upgrade search info list"
            mapfile -t COMPREPLY < <(compgen -W "$subcmds" -- "$cur")
            return 0
        fi

        case "$subcmd" in
            install|fetch|info)
                if [[ -n "$cur" ]] && [[ ${#cur} -ge 2 ]]; then
                    local results
                    results=$(grimaur complete install "$cur" 2>/dev/null)
                    mapfile -t COMPREPLY < <(compgen -W "$results" -- "$cur")
                fi
                ;;
            uninstall|upgrade)
                local packages
                packages=$(pacman -Qmq 2>/dev/null)
                mapfile -t COMPREPLY < <(compgen -W "$packages" -- "$cur")
                ;;
        esac
    else
        # Default mode (gpmwrap) completions
        if [[ "$cur" == -* ]]; then
            local opts="--no-color"
            case "$subcmd" in
                mirrors)
                    opts="--no-color --protocol --latest --sort --country"
                    ;;
                sync)
                    opts="--no-color --noconfirm"
                    ;;
                upgrade)
                    opts="--no-color --noconfirm --download --install"
                    ;;
                list)
                    opts="--no-color --sync"
                    ;;
                search)
                    opts="--no-color --local --exact"
                    ;;
                info)
                    opts="--no-color --local"
                    ;;
                uninstall)
                    opts="--no-color --no-deps"
                    ;;
            esac
            mapfile -t COMPREPLY < <(compgen -W "$opts" -- "$cur")
            return 0
        fi

        if [[ "$prev" == "--sort" ]]; then
            mapfile -t COMPREPLY < <(compgen -W "rate age score country" -- "$cur")
            return 0
        fi

        if [[ "$prev" == "--protocol" ]]; then
            mapfile -t COMPREPLY < <(compgen -W "https http" -- "$cur")
            return 0
        fi

        if [[ -z "$subcmd" ]]; then
            local subcmds="mirrors sync upgrade check clean deps list search info install uninstall"
            mapfile -t COMPREPLY < <(compgen -W "$subcmds" -- "$cur")
            return 0
        fi

        case "$subcmd" in
            deps|info|install)
                # Complete with all packages (sync)
                local packages
                packages=$(pacman -Slq 2>/dev/null)
                mapfile -t COMPREPLY < <(compgen -W "$packages" -- "$cur")
                ;;
            uninstall)
                # Complete with installed packages
                local packages
                packages=$(pacman -Qq 2>/dev/null)
                mapfile -t COMPREPLY < <(compgen -W "$packages" -- "$cur")
                ;;
            search)
                # No completion for search pattern
                ;;
        esac
    fi
}

complete -F _grur_completion grur
