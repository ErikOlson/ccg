# ccg bash completion

_ccg() {
    local cur prev words cword
    _init_completion || return

    if [ "$cword" -eq 1 ]; then
        COMPREPLY=($(compgen -W "init add status commit push remote --version --help" -- "$cur"))
        return
    fi

    case "${words[1]}" in
        add)
            _filedir
            ;;
        commit)
            if [ "${prev}" = "-m" ]; then
                # message arg — no completion
                return
            fi
            COMPREPLY=($(compgen -W "-m" -- "$cur"))
            ;;
    esac
}

complete -F _ccg ccg
