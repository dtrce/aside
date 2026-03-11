__aside_check() {
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local count
        count=$(aside count 2>/dev/null)
        if [ -n "$count" ] && [ "$count" -gt 0 ]; then
            printf '\033[1;34m[aside] \033[0;33m%s file(s) found.\033[0m\n' "$count"
        fi
    fi
}

cd() {
    builtin cd "$@" && __aside_check
}

pushd() {
    builtin pushd "$@" && __aside_check
}

popd() {
    builtin popd "$@" && __aside_check
}
