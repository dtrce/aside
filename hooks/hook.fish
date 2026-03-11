function __aside_check --on-variable PWD
    if git rev-parse --is-inside-work-tree &>/dev/null
        set -l count (aside count 2>/dev/null)
        if test -n "$count" -a "$count" -gt 0
            set_color --bold blue
            echo -n "[aside] "
            set_color yellow
            echo "$count file(s) found."
            set_color normal
        end
    end
end
